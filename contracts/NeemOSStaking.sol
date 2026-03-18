// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title NeemOSStaking
 * @dev Multi-tier staking pool for NEEM tokens with tiered rewards and governance
 * Features: Variable APY, Lock periods, Delegation, Early unstaking penalties
 */
contract NeemOSStaking is Ownable, AccessControl, ReentrancyGuard {
  // Role definitions
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant REWARD_DISTRIBUTOR = keccak256("REWARD_DISTRIBUTOR");

  // Staking tier structure
  struct StakingTier {
    uint256 minAmount; // Minimum stake for this tier
    uint256 maxAmount; // Maximum stake (0 = unlimited)
    uint256 apyPercentage; // APY in basis points (1000 = 10%)
    uint256 lockPeriodSeconds; // Minimum lock period
    bool active;
  }

  // Staker information structure
  struct StakerInfo {
    uint256 stakedAmount;
    uint256 stakeStartTime;
    uint256 lockEndTime;
    uint8 tierIndex;
    uint256 pendingRewards;
    uint256 lastRewardCalculationTime;
    bool delegatedTo; // Is this staker delegating?
  }

  // Reward tracking
  struct RewardRecord {
    uint256 timestamp;
    uint256 amount;
    address recipient;
  }

  // Storage mappings
  IERC20 public immutable neemToken;
  IERC20 public rewardToken;

  StakingTier[] public stakingTiers;
  mapping(address => StakerInfo) public stakers;
  mapping(address => address) public delegations; // delegator -> delegate
  mapping(address => uint256) public delegatedPower; // amount delegated to address
  mapping(address => RewardRecord[]) public rewardHistory;

  uint256 public totalStaked;
  uint256 public totalRewardsDistributed;
  uint256 public minimumStakeAmount = 1e18; // 1 token minimum
  uint256 public penaltyPercentage = 1000; // 10% early unstaking penalty

  bool public stakingActive = true;

  // Events
  event Staked(address indexed user, uint256 amount, uint8 tier, uint256 lockEndTime);
  event Unstaked(address indexed user, uint256 amount, uint256 penalty);
  event RewardClaimed(address indexed user, uint256 amount);
  event RewardsDistributed(uint256 totalAmount, uint256 timestamp);
  event TierAdded(uint8 tierIndex, uint256 minAmount, uint256 maxAmount, uint256 apy);
  event TierUpdated(uint8 tierIndex, uint256 newApy);
  event DelegationCreated(address indexed delegator, address indexed delegate);
  event DelegationRevoked(address indexed delegator, address indexed delegate);
  event PenaltyWithdrawn(address indexed recipient, uint256 amount);

  /**
   * @dev Constructor
   * @param _neemToken Address of NEEM token
   * @param _rewardToken Address of reward token (can be same as NEEM)
   */
  constructor(address _neemToken, address _rewardToken) Ownable(msg.sender) {
    require(_neemToken != address(0), "Invalid NEEM token");
    require(_rewardToken != address(0), "Invalid reward token");

    neemToken = IERC20(_neemToken);
    rewardToken = IERC20(_rewardToken);

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(ADMIN_ROLE, msg.sender);
    _grantRole(REWARD_DISTRIBUTOR, msg.sender);

    // Initialize default tiers
    _initializeDefaultTiers();
  }

  /**
   * @dev Initialize default staking tiers
   */
  function _initializeDefaultTiers() internal {
    // Tier 1: Bronze (flexible, lower rewards)
    stakingTiers.push(
      StakingTier({
        minAmount: 1e18,
        maxAmount: 1000e18,
        apyPercentage: 500, // 5% APY
        lockPeriodSeconds: 0, // No lock
        active: true
      })
    );

    // Tier 2: Silver (30 days lock, better rewards)
    stakingTiers.push(
      StakingTier({
        minAmount: 1000e18,
        maxAmount: 10000e18,
        apyPercentage: 1000, // 10% APY
        lockPeriodSeconds: 30 days,
        active: true
      })
    );

    // Tier 3: Gold (90 days lock, excellent rewards)
    stakingTiers.push(
      StakingTier({
        minAmount: 10000e18,
        maxAmount: 100000e18,
        apyPercentage: 1500, // 15% APY
        lockPeriodSeconds: 90 days,
        active: true
      })
    );

    // Tier 4: Platinum (180 days lock, premium rewards)
    stakingTiers.push(
      StakingTier({
        minAmount: 100000e18,
        maxAmount: 0, // Unlimited
        apyPercentage: 2000, // 20% APY
        lockPeriodSeconds: 180 days,
        active: true
      })
    );
  }

  /**
   * @dev Stake tokens
   * @param amount Amount to stake
   * @param tierIndex Index of tier to stake in
   */
  function stake(uint256 amount, uint8 tierIndex)
    external
    nonReentrant
    returns (uint256 lockEndTime)
  {
    require(stakingActive, "Staking disabled");
    require(tierIndex < stakingTiers.length, "Invalid tier");
    require(amount >= minimumStakeAmount, "Below minimum stake");

    StakingTier memory tier = stakingTiers[tierIndex];
    require(tier.active, "Tier inactive");
    require(amount >= tier.minAmount, "Below tier minimum");
    if (tier.maxAmount > 0) {
      require(amount <= tier.maxAmount, "Exceeds tier maximum");
    }

    // Transfer tokens from user to contract
    require(
      neemToken.transferFrom(msg.sender, address(this), amount),
      "Stake transfer failed"
    );

    // Update staker info
    if (stakers[msg.sender].stakedAmount > 0) {
      // Claim pending rewards before updating stake
      _claimRewards(msg.sender);
    }

    lockEndTime = block.timestamp + tier.lockPeriodSeconds;

    stakers[msg.sender] = StakerInfo({
      stakedAmount: stakers[msg.sender].stakedAmount + amount,
      stakeStartTime: block.timestamp,
      lockEndTime: lockEndTime,
      tierIndex: tierIndex,
      pendingRewards: 0,
      lastRewardCalculationTime: block.timestamp,
      delegatedTo: false
    });

    totalStaked += amount;

    emit Staked(msg.sender, amount, tierIndex, lockEndTime);

    return lockEndTime;
  }

  /**
   * @dev Unstake tokens
   * @param amount Amount to unstake
   */
  function unstake(uint256 amount) external nonReentrant {
    StakerInfo storage info = stakers[msg.sender];
    require(info.stakedAmount >= amount, "Insufficient staked amount");

    // Calculate rewards before unstaking
    uint256 pendingReward = _calculatePendingReward(msg.sender);
    info.pendingRewards += pendingReward;
    info.lastRewardCalculationTime = block.timestamp;

    uint256 penalty = 0;

    // Check if still in lock period
    if (block.timestamp < info.lockEndTime) {
      // Early unstaking penalty
      penalty = (amount * penaltyPercentage) / 10000;
    }

    uint256 transferAmount = amount - penalty;

    info.stakedAmount -= amount;
    totalStaked -= amount;

    // Transfer tokens back to user
    require(neemToken.transfer(msg.sender, transferAmount), "Unstake transfer failed");

    // Send penalty to owner
    if (penalty > 0) {
      require(neemToken.transfer(owner(), penalty), "Penalty transfer failed");
      emit PenaltyWithdrawn(owner(), penalty);
    }

    emit Unstaked(msg.sender, amount, penalty);
  }

  /**
   * @dev Internal function to calculate pending rewards
   * @param user User address
   * @return Pending reward amount
   */
  function _calculatePendingReward(address user) internal view returns (uint256) {
    StakerInfo memory info = stakers[user];
    if (info.stakedAmount == 0) return 0;

    StakingTier memory tier = stakingTiers[info.tierIndex];

    uint256 timeElapsed = block.timestamp - info.lastRewardCalculationTime;
    uint256 yearlyReward = (info.stakedAmount * tier.apyPercentage) / 10000;
    uint256 reward = (yearlyReward * timeElapsed) / 365 days;

    return reward;
  }

  /**
   * @dev Get pending rewards for a user
   * @param user User address
   * @return Pending reward amount
   */
  function getPendingReward(address user) external view returns (uint256) {
    StakerInfo memory info = stakers[user];
    uint256 pending = info.pendingRewards + _calculatePendingReward(user);
    return pending;
  }

  /**
   * @dev Internal claim rewards function
   * @param user User address
   */
  function _claimRewards(address user) internal {
    StakerInfo storage info = stakers[user];

    uint256 totalReward = info.pendingRewards + _calculatePendingReward(user);
    require(totalReward > 0, "No rewards to claim");

    info.pendingRewards = 0;
    info.lastRewardCalculationTime = block.timestamp;

    // Transfer rewards
    require(rewardToken.transfer(user, totalReward), "Reward transfer failed");

    totalRewardsDistributed += totalReward;

    rewardHistory[user].push(
      RewardRecord({timestamp: block.timestamp, amount: totalReward, recipient: user})
    );

    emit RewardClaimed(user, totalReward);
  }

  /**
   * @dev Claim pending rewards
   */
  function claimRewards() external nonReentrant {
    _claimRewards(msg.sender);
  }

  /**
   * @dev Admin function to distribute rewards
   * @param recipients Array of recipient addresses
   * @param amounts Array of reward amounts
   */
  function distributeRewards(address[] calldata recipients, uint256[] calldata amounts)
    external
    onlyRole(REWARD_DISTRIBUTOR)
    nonReentrant
  {
    require(recipients.length == amounts.length, "Array length mismatch");

    uint256 totalAmount = 0;
    for (uint256 i = 0; i < amounts.length; i++) {
      totalAmount += amounts[i];
      stakers[recipients[i]].pendingRewards += amounts[i];
    }

    require(rewardToken.transferFrom(msg.sender, address(this), totalAmount), "Transfer failed");

    emit RewardsDistributed(totalAmount, block.timestamp);
  }

  /**
   * @dev Delegate voting power to another address
   * @param delegate Delegate address
   */
  function delegatePower(address delegate) external {
    require(delegate != address(0), "Invalid delegate");
    require(stakers[msg.sender].stakedAmount > 0, "No stake to delegate");

    // Remove previous delegation
    if (delegations[msg.sender] != address(0)) {
      delegatedPower[delegations[msg.sender]] -= stakers[msg.sender].stakedAmount;
    }

    delegations[msg.sender] = delegate;
    delegatedPower[delegate] += stakers[msg.sender].stakedAmount;
    stakers[msg.sender].delegatedTo = true;

    emit DelegationCreated(msg.sender, delegate);
  }

  /**
   * @dev Revoke delegation
   */
  function revokeDelegation() external {
    address currentDelegate = delegations[msg.sender];
    require(currentDelegate != address(0), "No delegation");

    delegatedPower[currentDelegate] -= stakers[msg.sender].stakedAmount;
    delegations[msg.sender] = address(0);
    stakers[msg.sender].delegatedTo = false;

    emit DelegationRevoked(msg.sender, currentDelegate);
  }

  /**
   * @dev Get staker information
   * @param user User address
   * @return Staker info struct
   */
  function getStakerInfo(address user) external view returns (StakerInfo memory) {
    return stakers[user];
  }

  /**
   * @dev Get all tiers
   * @return Array of staking tiers
   */
  function getTiers() external view returns (StakingTier[] memory) {
    return stakingTiers;
  }

  /**
   * @dev Add a new staking tier
   * @param minAmount Minimum stake amount
   * @param maxAmount Maximum stake amount (0 = unlimited)
   * @param apyPercentage APY in basis points
   * @param lockPeriodSeconds Lock period in seconds
   */
  function addTier(
    uint256 minAmount,
    uint256 maxAmount,
    uint256 apyPercentage,
    uint256 lockPeriodSeconds
  ) external onlyRole(ADMIN_ROLE) {
    stakingTiers.push(
      StakingTier({
        minAmount: minAmount,
        maxAmount: maxAmount,
        apyPercentage: apyPercentage,
        lockPeriodSeconds: lockPeriodSeconds,
        active: true
      })
    );

    emit TierAdded(uint8(stakingTiers.length - 1), minAmount, maxAmount, apyPercentage);
  }

  /**
   * @dev Update tier APY
   * @param tierIndex Tier index to update
   * @param newApy New APY in basis points
   */
  function updateTierAPY(uint8 tierIndex, uint256 newApy) external onlyRole(ADMIN_ROLE) {
    require(tierIndex < stakingTiers.length, "Invalid tier");
    stakingTiers[tierIndex].apyPercentage = newApy;
    emit TierUpdated(tierIndex, newApy);
  }

  /**
   * @dev Set penalty percentage
   * @param newPenalty New penalty in basis points
   */
  function setPenaltyPercentage(uint256 newPenalty) external onlyRole(ADMIN_ROLE) {
    require(newPenalty <= 5000, "Penalty too high"); // Max 50%
    penaltyPercentage = newPenalty;
  }

  /**
   * @dev Toggle staking active status
   */
  function toggleStakingActive() external onlyRole(ADMIN_ROLE) {
    stakingActive = !stakingActive;
  }

  /**
   * @dev Emergency withdraw
   */
  function emergencyWithdraw(uint256 amount) external onlyOwner {
    require(rewardToken.transfer(owner(), amount), "Withdraw failed");
  }

  /**
   * @dev Get voting power of address
   * @param user User address
   * @return Voting power (staked amount + delegated amount)
   */
  function getVotingPower(address user) external view returns (uint256) {
    return stakers[user].stakedAmount + delegatedPower[user];
  }

  /**
   * @dev Get reward history for a user
   * @param user User address
   * @return Array of reward records
   */
  function getRewardHistory(address user)
    external
    view
    returns (RewardRecord[] memory)
  {
    return rewardHistory[user];
  }
}

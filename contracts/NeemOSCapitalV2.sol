// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title NeemOSCapitalV2
 * @dev Advanced RWA tokenization with Chainlink price feeds, staking, and yield distribution
 * Features: Fractional ownership, Automated yield distribution, Staking rewards, Vesting schedules
 */
contract NeemOSCapitalV2 is ERC20, Ownable, AccessControl {
  // Role definitions
  bytes32 public constant YIELD_MANAGER_ROLE = keccak256("YIELD_MANAGER_ROLE");
  bytes32 public constant VESTING_MANAGER_ROLE = keccak256("VESTING_MANAGER_ROLE");

  // Chainlink oracle interface
  AggregatorV3Interface public immutable priceFeed;

  // Stablecoin for yield distribution (USDC or similar)
  IERC20 public immutable stablecoin;

  // Dividend tracking (scaled by 1e18 to avoid rounding issues)
  uint256 public dividendPerShare;
  mapping(address => uint256) public withdrawnDividends;

  // Staking mechanism
  struct StakingInfo {
    uint256 stakedAmount;
    uint256 stakingStartTime;
    uint256 lastRewardTime;
    uint256 rewardDebtPerShare;
  }

  mapping(address => StakingInfo) public stakingInfo;
  uint256 public totalStaked;
  uint256 public stakingRewardPerShare;
  uint256 public stakingAPY = 1000; // 10% APY (basis points: 100 = 1%)

  // Vesting schedules
  struct VestingSchedule {
    uint256 totalAmount;
    uint256 startTime;
    uint256 duration;
    uint256 claimed;
    bool revocable;
  }

  mapping(address => VestingSchedule) public vestingSchedules;

  // Asset metadata
  string public assetName;
  string public assetCategory; // e.g., "Real Estate", "Commodities", "Equity"
  uint256 public totalInvestment;
  uint256 public assetValuation; // Updated by oracle or admin
  uint256 public lastValuationUpdate;

  // Historical dividend tracking
  struct DividendRecord {
    uint256 timestamp;
    uint256 amount;
    uint256 usdPrice;
  }

  DividendRecord[] public dividendHistory;

  // Events
  event DividendDistributed(
    uint256 indexed timestamp,
    uint256 totalAmount,
    uint256 priceUsed,
    uint256 dividendPerShare
  );
  event DividendWithdrawn(address indexed investor, uint256 amount);
  event Staked(address indexed user, uint256 amount);
  event Unstaked(address indexed user, uint256 amount);
  event StakingRewardClaimed(address indexed user, uint256 reward);
  event VestingScheduleCreated(address indexed beneficiary, uint256 totalAmount, uint256 duration);
  event VestingClaimed(address indexed beneficiary, uint256 amount);
  event AssetValuationUpdated(uint256 newValuation, uint256 timestamp);

  /**
   * @dev Constructor to initialize the contract
   * @param _assetName Name of the real-world asset
   * @param _assetCategory Category/type of asset
   * @param _priceFeed Chainlink price feed aggregator address
   * @param _stablecoin Stablecoin token address (USDC, USDT, etc)
   */
  constructor(
    string memory _assetName,
    string memory _assetCategory,
    address _priceFeed,
    address _stablecoin
  ) ERC20("NeemOS Capital Share", "NCAP") Ownable(msg.sender) {
    require(_priceFeed != address(0), "Invalid price feed");
    require(_stablecoin != address(0), "Invalid stablecoin");

    assetName = _assetName;
    assetCategory = _assetCategory;
    priceFeed = AggregatorV3Interface(_priceFeed);
    stablecoin = IERC20(_stablecoin);

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(YIELD_MANAGER_ROLE, msg.sender);
    _grantRole(VESTING_MANAGER_ROLE, msg.sender);
  }

  /**
   * @dev Get the latest ETH price from Chainlink oracle
   * @return Price in USD (8 decimal places)
   */
  function getLatestPrice() public view returns (uint256) {
    (
      ,
      int256 answer,
      ,
      uint256 updatedAt,

    ) = priceFeed.latestRoundData();

    require(answer > 0, "Invalid price from oracle");
    require(block.timestamp - updatedAt <= 1 days, "Price feed stale");

    return uint256(answer);
  }

  /**
   * @dev Investors deposit ETH to receive fractional shares
   * Shares are priced dynamically based on asset valuation
   */
  function invest() external payable {
    require(msg.value > 0, "Send ETH to invest");

    uint256 price = getLatestPrice();
    uint256 ethValueInUsd = (msg.value * price) / 1e8; // Convert to USD

    // Calculate shares based on current valuation
    uint256 sharesToMint;
    if (assetValuation == 0) {
      sharesToMint = msg.value / 1e15; // Default: 0.001 ETH = 1 share
    } else {
      sharesToMint = (ethValueInUsd * 1e18) / assetValuation;
    }

    require(sharesToMint > 0, "Investment too small");

    _mint(msg.sender, sharesToMint);
    totalInvestment += msg.value;

    emit Staked(msg.sender, sharesToMint);
  }

  /**
   * @dev Update asset valuation (only authorized role)
   * @param newValuation New USD valuation of the asset
   */
  function updateAssetValuation(uint256 newValuation)
    external
    onlyRole(YIELD_MANAGER_ROLE)
  {
    require(newValuation > 0, "Invalid valuation");
    assetValuation = newValuation;
    lastValuationUpdate = block.timestamp;
    emit AssetValuationUpdated(newValuation, block.timestamp);
  }

  /**
   * @dev Distribute dividends to all shareholders
   * @param usdcAmount Amount of stablecoin to distribute
   */
  function distributeDividends(uint256 usdcAmount)
    external
    onlyRole(YIELD_MANAGER_ROLE)
  {
    uint256 supply = totalSupply();
    require(supply > 0, "No shareholders");
    require(usdcAmount > 0, "Invalid amount");

    require(
      stablecoin.transferFrom(msg.sender, address(this), usdcAmount),
      "USDC transfer failed"
    );

    uint256 price = getLatestPrice();
    dividendPerShare += (usdcAmount * 1e18) / supply;

    dividendHistory.push(
      DividendRecord({
        timestamp: block.timestamp,
        amount: usdcAmount,
        usdPrice: price
      })
    );

    emit DividendDistributed(block.timestamp, usdcAmount, price, dividendPerShare);
  }

  /**
   * @dev Calculate pending dividends for an investor
   * @param investor Investor address
   * @return Pending dividend amount
   */
  function pendingDividends(address investor) public view returns (uint256) {
    uint256 owed = dividendPerShare - withdrawnDividends[investor];
    return (balanceOf(investor) * owed) / 1e18;
  }

  /**
   * @dev Withdraw all pending dividends
   */
  function withdrawDividends() external {
    uint256 amount = pendingDividends(msg.sender);
    require(amount > 0, "No dividends pending");

    withdrawnDividends[msg.sender] = dividendPerShare;
    require(stablecoin.transfer(msg.sender, amount), "Transfer failed");

    emit DividendWithdrawn(msg.sender, amount);
  }

  /**
   * @dev Stake shares to earn additional rewards
   * @param amount Amount of NCAP to stake
   */
  function stake(uint256 amount) external {
    require(amount > 0, "Invalid amount");
    require(balanceOf(msg.sender) >= amount, "Insufficient balance");

    // Update staking rewards before changing stake amount
    if (stakingInfo[msg.sender].stakedAmount > 0) {
      _claimStakingReward(msg.sender);
    }

    // Transfer shares to staking contract (via burn/mint pattern)
    transfer(address(this), amount);

    stakingInfo[msg.sender].stakedAmount += amount;
    stakingInfo[msg.sender].stakingStartTime = block.timestamp;
    stakingInfo[msg.sender].lastRewardTime = block.timestamp;
    stakingInfo[msg.sender].rewardDebtPerShare = stakingRewardPerShare;

    totalStaked += amount;

    emit Staked(msg.sender, amount);
  }

  /**
   * @dev Unstake shares
   * @param amount Amount to unstake
   */
  function unstake(uint256 amount) external {
    require(amount > 0, "Invalid amount");
    require(stakingInfo[msg.sender].stakedAmount >= amount, "Insufficient staked");

    // Claim rewards before unstaking
    _claimStakingReward(msg.sender);

    stakingInfo[msg.sender].stakedAmount -= amount;
    totalStaked -= amount;

    // Transfer back to user
    _transfer(address(this), msg.sender, amount);

    emit Unstaked(msg.sender, amount);
  }

  /**
   * @dev Internal function to claim staking rewards
   * @param user User address
   */
  function _claimStakingReward(address user) internal {
    StakingInfo storage info = stakingInfo[user];
    if (info.stakedAmount == 0) return;

    // Calculate time-based reward: (stakedAmount * stakingAPY * timeElapsed) / (365 days * 10000)
    uint256 timeElapsed = block.timestamp - info.lastRewardTime;
    uint256 reward = (info.stakedAmount * stakingAPY * timeElapsed) / (365 days * 10000);

    if (reward > 0) {
      _mint(user, reward);
      emit StakingRewardClaimed(user, reward);
    }

    info.lastRewardTime = block.timestamp;
  }

  /**
   * @dev Claim staking rewards
   */
  function claimStakingReward() external {
    _claimStakingReward(msg.sender);
  }

  /**
   * @dev Create a vesting schedule for an address
   * @param beneficiary Address to vest tokens to
   * @param totalAmount Total vesting amount
   * @param durationSeconds Duration of vesting period
   * @param revocable Whether vesting can be revoked
   */
  function createVestingSchedule(
    address beneficiary,
    uint256 totalAmount,
    uint256 durationSeconds,
    bool revocable
  ) external onlyRole(VESTING_MANAGER_ROLE) {
    require(beneficiary != address(0), "Invalid beneficiary");
    require(totalAmount > 0, "Invalid amount");
    require(durationSeconds > 0, "Invalid duration");

    vestingSchedules[beneficiary] = VestingSchedule({
      totalAmount: totalAmount,
      startTime: block.timestamp,
      duration: durationSeconds,
      claimed: 0,
      revocable: revocable
    });

    _mint(address(this), totalAmount); // Lock tokens in contract

    emit VestingScheduleCreated(beneficiary, totalAmount, durationSeconds);
  }

  /**
   * @dev Calculate vested amount for a beneficiary
   * @param beneficiary Beneficiary address
   * @return Amount of tokens that have vested
   */
  function getVestedAmount(address beneficiary) public view returns (uint256) {
    VestingSchedule memory schedule = vestingSchedules[beneficiary];
    if (schedule.totalAmount == 0) return 0;

    uint256 elapsed = block.timestamp - schedule.startTime;
    if (elapsed >= schedule.duration) {
      return schedule.totalAmount - schedule.claimed;
    }

    uint256 vested = (schedule.totalAmount * elapsed) / schedule.duration;
    return vested - schedule.claimed;
  }

  /**
   * @dev Claim vested tokens
   */
  function claimVestedTokens() external {
    uint256 amount = getVestedAmount(msg.sender);
    require(amount > 0, "No tokens vested yet");

    vestingSchedules[msg.sender].claimed += amount;
    _transfer(address(this), msg.sender, amount);

    emit VestingClaimed(msg.sender, amount);
  }

  /**
   * @dev Get dividend history
   * @return Array of dividend records
   */
  function getDividendHistory() external view returns (DividendRecord[] memory) {
    return dividendHistory;
  }

  /**
   * @dev Get dividend history length
   * @return Number of dividend distributions
   */
  function getDividendHistoryLength() external view returns (uint256) {
    return dividendHistory.length;
  }

  /**
   * @dev Emergency function to withdraw stuck tokens
   * @param token Token address (not stablecoin)
   */
  function emergencyWithdraw(address token) external onlyOwner {
    require(token != address(stablecoin), "Cannot withdraw stablecoin");
    IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
  }

  // Override required for AccessControl
  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC20, AccessControl)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}
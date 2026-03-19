// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title NeemOSVerifyV2
 * @dev Advanced identity & credential system with zero-knowledge proof support
 * Features: Soulbound Tokens, Credential Metadata, Revocation, ZKP integration ready
 */
contract NeemOSVerifyV2 is ERC721, Ownable, AccessControl {
  // Role definitions
  bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
  bytes32 public constant REVOCATION_OFFICER = keccak256("REVOCATION_OFFICER");

  // Credential types
  enum CredentialType {
    KYC, // Know Your Customer
    CORPORATE_CERTIFICATION, // HR/Corporate certifications
    EDUCATIONAL_DEGREE, // University degrees
    PROFESSIONAL_LICENSE, // Professional licenses
    SECURITY_CLEARANCE, // Security clearances
    CUSTOM // Custom credential type
  }

  // Revocation status
  enum RevocationStatus {
    ACTIVE,
    REVOKED,
    EXPIRED,
    SUSPENDED
  }

  // Credential metadata structure
  struct Credential {
    CredentialType credentialType;
    string credentialName;
    string issuerName;
    string metadataURI; // Points to IPFS/offchain data
    uint256 issuedAt;
    uint256 expiresAt; // 0 = never expires
    RevocationStatus status;
    string revocationReason;
  }

  // ZKP commitment structure
  struct ZKProof {
    bytes32 commitment; // Hash of credential data
    bytes proof; // ZK proof data
    uint256 verificationTimestamp;
    bool verified;
  }

  // Storage mappings
  mapping(uint256 => Credential) public credentials;
  mapping(uint256 => ZKProof) public zkProofs;
  mapping(address => bool) public sybilChecked;
  mapping(address => uint256) public credentialCount;

  uint256 private _nextTokenId;
  uint256 public totalCredentialsIssued;

  // Events
  event CredentialIssued(
    uint256 indexed tokenId,
    address indexed holder,
    CredentialType credentialType,
    string credentialName,
    uint256 expiresAt
  );
  event CredentialRevoked(uint256 indexed tokenId, string reason, address revokedBy);
  event CredentialExpired(uint256 indexed tokenId);
  event ZKProofVerified(uint256 indexed tokenId, bytes32 commitment);
  event SybilCheckPassed(address indexed user, uint256 timestamp);
  event CredentialMetadataUpdated(uint256 indexed tokenId, string newMetadataURI);

  /**
   * @dev Constructor
   */
  constructor() ERC721("NeemOS Identity Credential", "NOID") Ownable(msg.sender) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(ISSUER_ROLE, msg.sender);
    _grantRole(REVOCATION_OFFICER, msg.sender);
  }

  /**
   * @dev Core SBT logic: Override transfer functions to disable them
   * @param to Recipient address
   * @param tokenId Token ID
   * @param auth Authorization data
   */
  function _update(address to, uint256 tokenId, address auth)
    internal
    override
    returns (address)
  {
    address from = _ownerOf(tokenId);
    // Allow minting (from == address(0)) and burning (to == address(0))
    // but disallow transfers between non-zero addresses
    if (from != address(0) && to != address(0)) {
      revert("SBT: Credentials are non-transferable");
    }
    return super._update(to, tokenId, auth);
  }

  /**
   * @dev Issue a new credential/SBT
   * @param to Recipient address
   * @param credentialType Type of credential
   * @param credentialName Name/title of credential
   * @param issuerName Name of issuing authority
   * @param metadataURI IPFS/offchain metadata URI
   * @param expiresAt Expiration timestamp (0 = never)
   */
  function issueCredential(
    address to,
    CredentialType credentialType,
    string calldata credentialName,
    string calldata issuerName,
    string calldata metadataURI,
    uint256 expiresAt
  ) external onlyRole(ISSUER_ROLE) returns (uint256) {
    require(to != address(0), "Invalid recipient");
    require(bytes(credentialName).length > 0, "Name required");
    require(expiresAt == 0 || expiresAt > block.timestamp, "Invalid expiration");

    uint256 tokenId = _nextTokenId++;
    _safeMint(to, tokenId);

    credentials[tokenId] = Credential({
      credentialType: credentialType,
      credentialName: credentialName,
      issuerName: issuerName,
      metadataURI: metadataURI,
      issuedAt: block.timestamp,
      expiresAt: expiresAt,
      status: RevocationStatus.ACTIVE,
      revocationReason: ""
    });

    credentialCount[to]++;
    totalCredentialsIssued++;

    emit CredentialIssued(tokenId, to, credentialType, credentialName, expiresAt);

    return tokenId;
  }

  /**
   * @dev Verify a ZKP for credential privacy
   * This would integrate with actual ZK libraries in production
   * @param tokenId Token ID
   * @param commitment Hash of credential commitment
   * @param proof ZK proof data
   */
  function submitZKProof(
    uint256 tokenId,
    bytes32 commitment,
    bytes calldata proof
  ) external onlyRole(ISSUER_ROLE) {
    require(_ownerOf(tokenId) != address(0), "Invalid credential");

    // In production, this would use actual ZK verification
    // For now, we trust the issuer's verification
    zkProofs[tokenId] = ZKProof({
      commitment: commitment,
      proof: proof,
      verificationTimestamp: block.timestamp,
      verified: true
    });

    emit ZKProofVerified(tokenId, commitment);
  }

  /**
   * @dev Revoke a credential
   * @param tokenId Token ID to revoke
   * @param reason Revocation reason
   */
  function revokeCredential(uint256 tokenId, string calldata reason)
    external
    onlyRole(REVOCATION_OFFICER)
  {
    require(_ownerOf(tokenId) != address(0), "Invalid credential");
    require(
      credentials[tokenId].status == RevocationStatus.ACTIVE,
      "Already revoked/expired"
    );

    credentials[tokenId].status = RevocationStatus.REVOKED;
    credentials[tokenId].revocationReason = reason;

    emit CredentialRevoked(tokenId, reason, msg.sender);
  }

  /**
   * @dev Check if credential is valid and not expired
   * @param tokenId Token ID
   * @return true if credential is active and not expired
   */
  function isCredentialValid(uint256 tokenId) public view returns (bool) {
    Credential memory cred = credentials[tokenId];

    if (cred.status != RevocationStatus.ACTIVE) {
      return false;
    }

    if (cred.expiresAt > 0 && block.timestamp > cred.expiresAt) {
      return false;
    }

    return true;
  }

  /**
   * @dev Get credential details
   * @param tokenId Token ID
   * @return Credential struct
   */
  function getCredential(uint256 tokenId)
    external
    view
    returns (Credential memory)
  {
    require(_ownerOf(tokenId) != address(0), "Invalid credential");
    return credentials[tokenId];
  }

  /**
   * @dev Get ZKP details for a credential
   * @param tokenId Token ID
   * @return ZKProof struct
   */
  function getZKProof(uint256 tokenId) external view returns (ZKProof memory) {
    require(_ownerOf(tokenId) != address(0), "Invalid credential");
    return zkProofs[tokenId];
  }

  /**
   * @dev Update credential metadata (issuer only)
   * @param tokenId Token ID
   * @param newMetadataURI New metadata URI
   */
  function updateMetadata(uint256 tokenId, string calldata newMetadataURI)
    external
    onlyRole(ISSUER_ROLE)
  {
    require(_ownerOf(tokenId) != address(0), "Invalid credential");
    credentials[tokenId].metadataURI = newMetadataURI;
    emit CredentialMetadataUpdated(tokenId, newMetadataURI);
  }

  /**
   * @dev Sybil resistance check
   * Verifies user has at least one valid credential
   * @return true if user passes sybil resistance check
   */
  function passSybilCheck(address user) external onlyRole(ISSUER_ROLE) returns (bool) {
    require(credentialCount[user] > 0, "User has no credentials");

    // In production, this could be more sophisticated
    // e.g., requiring multiple credentials from different issuers

    sybilChecked[user] = true;
    emit SybilCheckPassed(user, block.timestamp);
    return true;
  }

  /**
   * @dev Check if user passed sybil resistance check
   * @param user User address
   * @return true if user passed check
   */
  function hasSybilCheck(address user) external view returns (bool) {
    return sybilChecked[user];
  }

  /**
   * @dev Get all credential IDs for a holder
   * Note: This is for frontend use only; may be gas intensive
   * @param holder Holder address
   * @return Array of token IDs
   */
  function getHolderCredentials(address holder)
    external
    view
    returns (uint256[] memory)
  {
    uint256 count = credentialCount[holder];
    uint256[] memory result = new uint256[](count);
    uint256 idx = 0;

    for (uint256 i = 0; i < _nextTokenId; i++) {
      if (_ownerOf(i) == holder) {
        result[idx++] = i;
      }
    }

    return result;
  }

  /**
   * @dev Check if credential is expired and mark it
   * @param tokenId Token ID
   */
  function checkExpiration(uint256 tokenId) external {
    Credential storage cred = credentials[tokenId];
    if (cred.expiresAt > 0 && block.timestamp > cred.expiresAt) {
      if (cred.status == RevocationStatus.ACTIVE) {
        cred.status = RevocationStatus.EXPIRED;
        emit CredentialExpired(tokenId);
      }
    }
  }

  /**
   * @dev Grant issuer role to address
   * @param account Address to grant role
   */
  function addIssuer(address account) external onlyOwner {
    grantRole(ISSUER_ROLE, account);
  }

  /**
   * @dev Revoke issuer role from address
   * @param account Address to revoke role
   */
  function removeIssuer(address account) external onlyOwner {
    revokeRole(ISSUER_ROLE, account);
  }

  // Override required by Solidity
  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, AccessControl)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}

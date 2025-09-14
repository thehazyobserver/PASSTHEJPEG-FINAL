// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// ============================================================================
// Non-upgradeable OpenZeppelin Contracts (Embedded)
// ============================================================================

// Context
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// Ownable
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// ReentrancyGuard
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

// ============================================================================
// Interfaces
// ============================================================================

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// ============================================================================
// SwapPool Interface
// ============================================================================

interface ISwapPoolNonProxy {
    function transferOwnership(address newOwner) external;
    function claimRewards() external;
    function claimRewardsFor(address user) external;
    function emergencyUnstake(uint256 tokenId, address to) external;
}

// ============================================================================
// Factory Contract
// ============================================================================

contract SwapPoolFactoryNonProxy is Ownable, ReentrancyGuard {
    
    // ---------- State ----------
    mapping(address => address) public collectionToPool;
    address[] public allPools;
    uint256 public poolCount;

    // ---------- Events ----------
    event FactoryDeployed(address indexed deployer);
    event PoolCreated(
        address indexed nftCollection,
        address indexed poolAddress,
        address indexed creator
    );
    event PoolDeployed(
        address indexed poolAddress,
        address indexed nftCollection,
        address indexed deployer
    );

    // ---------- Errors ----------
    error ZeroAddressNotAllowed();
    error PoolAlreadyExists();
    error InvalidShareRange();
    error InvalidERC721();

    // ---------- Constructor ----------
    constructor() {
        emit FactoryDeployed(msg.sender);
    }

    // ---------- Core Functions ----------

    /**
     * @dev Create a new SwapPool for an NFT collection
     * @param nftCollection The NFT collection address
     * @param receiptContract The receipt token contract address
     * @param stonerPool The StonerFeePool address for staking rewards
     * @param swapFeeInWei The swap fee in wei
     * @param stonerShare The percentage share for StonerFeePool (0-100)
     * @return The address of the newly created pool
     */
    function createPool(
        address nftCollection,
        address receiptContract,
        address stonerPool,
        uint256 swapFeeInWei,
        uint256 stonerShare
    ) external onlyOwner returns (address) {
        // Input validation
        if (
            nftCollection == address(0) ||
            receiptContract == address(0) ||
            stonerPool == address(0)
        ) revert ZeroAddressNotAllowed();

        if (collectionToPool[nftCollection] != address(0)) revert PoolAlreadyExists();
        if (stonerShare > 100) revert InvalidShareRange();

        // Enhanced ERC721 validation
        if (!_isContract(nftCollection)) revert InvalidERC721();
        
        try IERC165(nftCollection).supportsInterface(0x80ac58cd) returns (bool supported) {
            if (!supported) revert InvalidERC721();
        } catch {
            revert InvalidERC721();
        }

        // Create new SwapPool contract using CREATE2 or external deployment
        // Note: For non-proxy deployment, you would need to deploy SwapPoolNonProxy separately
        // and then call this factory to register it, OR use a different deployment pattern.
        
        // For this factory to work, you'd need to either:
        // 1. Deploy SwapPoolNonProxy contracts manually and register them here, or
        // 2. Use a deployment script that handles the contract creation
        
        // For now, we'll revert with instructions
        revert("Non-proxy factory requires manual SwapPool deployment. Deploy SwapPoolNonProxy with these parameters and register it.");

        emit PoolCreated(nftCollection, poolAddress, msg.sender);
        emit PoolDeployed(poolAddress, nftCollection, msg.sender);
        
        return poolAddress;
    }

    // ---------- Batch Functions ----------

    /**
     * @dev Batch claim rewards from multiple pools
     * @param pools Array of pool addresses to claim from
     */
    function batchClaimRewards(address[] calldata pools) external nonReentrant {
        uint256 length = pools.length;
        require(length > 0, "Empty pools array");
        require(length <= 20, "Too many pools");

        for (uint256 i = 0; i < length; ++i) {
            try SwapPool(pools[i]).claimRewards() {} catch {}
        }
    }

    /**
     * @dev Batch claim rewards for a specific user from multiple pools
     * @param pools Array of pool addresses
     * @param user User address to claim for
     */
    function batchClaimRewardsFor(address[] calldata pools, address user) external nonReentrant {
        uint256 length = pools.length;
        require(length > 0, "Empty pools array");
        require(length <= 20, "Too many pools");

        for (uint256 i = 0; i < length; ++i) {
            try SwapPool(pools[i]).claimRewardsFor(user) {} catch {}
        }
    }

    /**
     * @dev Emergency batch unstake from multiple pools
     * @param pools Array of pool addresses
     * @param tokenIds Array of token IDs (same length as pools)
     */
    function emergencyBatchUnstake(
        address[] calldata pools,
        uint256[] calldata tokenIds
    ) external onlyOwner nonReentrant {
        require(pools.length == tokenIds.length, "Array length mismatch");
        require(pools.length <= 10, "Too many operations");

        for (uint256 i = 0; i < pools.length; ++i) {
            try SwapPool(pools[i]).emergencyUnstake(tokenIds[i], owner()) {} catch {}
        }
    }

    // ---------- View Functions ----------

    /**
     * @dev Get pool address for a collection
     * @param collection The NFT collection address
     * @return The pool address (zero if doesn't exist)
     */
    function getPoolForCollection(address collection) external view returns (address) {
        return collectionToPool[collection];
    }

    /**
     * @dev Get all pool addresses
     * @return Array of all pool addresses
     */
    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }

    /**
     * @dev Get pools within a range
     * @param start Start index
     * @param end End index (exclusive)
     * @return Array of pool addresses in the range
     */
    function getPoolsInRange(uint256 start, uint256 end) external view returns (address[] memory) {
        require(start < end, "Invalid range");
        require(end <= allPools.length, "End index out of bounds");

        address[] memory result = new address[](end - start);
        for (uint256 i = start; i < end; ++i) {
            result[i - start] = allPools[i];
        }
        return result;
    }

    /**
     * @dev Get factory statistics
     * @return Total number of pools created
     */
    function getFactoryStats() external view returns (uint256) {
        return poolCount;
    }

    /**
     * @dev Check if a pool exists for a collection
     * @param collection The NFT collection address
     * @return True if pool exists
     */
    function poolExists(address collection) external view returns (bool) {
        return collectionToPool[collection] != address(0);
    }

    /**
     * @dev Get pool info for a collection
     * @param collection The NFT collection address
     * @return poolAddress The pool address
     * @return exists Whether the pool exists
     */
    function getPoolInfo(address collection) external view returns (address poolAddress, bool exists) {
        poolAddress = collectionToPool[collection];
        exists = poolAddress != address(0);
    }

    /**
     * @dev Get multiple pool infos
     * @param collections Array of NFT collection addresses
     * @return poolAddresses Array of corresponding pool addresses
     * @return existsFlags Array of existence flags
     */
    function getMultiplePoolInfos(address[] calldata collections) 
        external 
        view 
        returns (address[] memory poolAddresses, bool[] memory existsFlags) 
    {
        uint256 length = collections.length;
        poolAddresses = new address[](length);
        existsFlags = new bool[](length);

        for (uint256 i = 0; i < length; ++i) {
            poolAddresses[i] = collectionToPool[collections[i]];
            existsFlags[i] = poolAddresses[i] != address(0);
        }
    }

    // ---------- Admin Functions ----------

    /**
     * @dev Emergency withdrawal of ETH
     * @param to Address to send ETH to
     * @param amount Amount to withdraw (0 = all)
     */
    function emergencyWithdrawETH(address to, uint256 amount) external onlyOwner nonReentrant {
        require(to != address(0), "Zero address not allowed");
        
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No ETH to withdraw");
        
        uint256 withdrawAmount = amount == 0 ? contractBalance : amount;
        require(withdrawAmount <= contractBalance, "Insufficient balance");

        (bool success, ) = payable(to).call{value: withdrawAmount}("");
        require(success, "ETH transfer failed");
    }

    // ---------- Internal Functions ----------

    /**
     * @dev Check if an address is a contract
     * @param account The address to check
     * @return True if the address is a contract
     */
    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    // ---------- Receive Function ----------
    
    /**
     * @dev Allow contract to receive ETH
     */
    receive() external payable {}
}
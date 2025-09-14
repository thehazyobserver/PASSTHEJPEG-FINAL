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

// ============================================================================
// SwapPool Registry (Non-Proxy Version)
// ============================================================================

/**
 * @title SwapPoolRegistry
 * @dev Registry for manually deployed SwapPoolNonProxy contracts
 * @notice This contract manages a registry of SwapPool contracts deployed without proxies
 */
contract SwapPoolRegistry is Ownable {
    
    // ---------- State ----------
    mapping(address => address) public collectionToPool;
    address[] public allPools;
    uint256 public poolCount;

    // ---------- Events ----------
    event RegistryDeployed(address indexed deployer);
    event PoolRegistered(
        address indexed nftCollection,
        address indexed poolAddress,
        address indexed registrar
    );
    event PoolRemoved(
        address indexed nftCollection,
        address indexed poolAddress
    );

    // ---------- Errors ----------
    error ZeroAddressNotAllowed();
    error PoolAlreadyExists();
    error PoolDoesNotExist();
    error InvalidPool();

    // ---------- Constructor ----------
    constructor() {
        emit RegistryDeployed(msg.sender);
    }

    // ---------- Core Functions ----------

    /**
     * @dev Register a manually deployed SwapPoolNonProxy contract
     * @param nftCollection The NFT collection address
     * @param poolAddress The deployed SwapPoolNonProxy address
     */
    function registerPool(
        address nftCollection,
        address poolAddress
    ) external onlyOwner {
        if (nftCollection == address(0) || poolAddress == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        
        if (collectionToPool[nftCollection] != address(0)) {
            revert PoolAlreadyExists();
        }

        if (!_isContract(poolAddress)) {
            revert InvalidPool();
        }

        // Update mappings
        collectionToPool[nftCollection] = poolAddress;
        allPools.push(poolAddress);
        poolCount++;

        emit PoolRegistered(nftCollection, poolAddress, msg.sender);
    }

    /**
     * @dev Remove a pool from the registry
     * @param nftCollection The NFT collection address
     */
    function removePool(address nftCollection) external onlyOwner {
        address poolAddress = collectionToPool[nftCollection];
        if (poolAddress == address(0)) {
            revert PoolDoesNotExist();
        }

        // Remove from mapping
        delete collectionToPool[nftCollection];

        // Remove from array
        for (uint256 i = 0; i < allPools.length; i++) {
            if (allPools[i] == poolAddress) {
                allPools[i] = allPools[allPools.length - 1];
                allPools.pop();
                break;
            }
        }

        poolCount--;
        emit PoolRemoved(nftCollection, poolAddress);
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
     * @dev Get registry statistics
     * @return Total number of pools registered
     */
    function getRegistryStats() external view returns (uint256) {
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

    // ---------- Internal Functions ----------

    /**
     * @dev Check if an address is a contract
     * @param account The address to check
     * @return True if the address is a contract
     */
    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
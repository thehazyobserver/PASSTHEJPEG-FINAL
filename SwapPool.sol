// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

pragma solidity >=0.6.2;

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Low balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Send failed");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Low balance");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Not contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// -----------------------------------------
// OpenZeppelin Initializable
// -----------------------------------------
pragma solidity ^0.8.2;

abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// -----------------------------------------
// OpenZeppelin ContextUpgradeable
// -----------------------------------------
pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}
    function __Context_init_unchained() internal onlyInitializing {}
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// -----------------------------------------
// OpenZeppelin OwnableUpgradeable
// -----------------------------------------
pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }
    function __Ownable_init_unchained() internal onlyInitializing {
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
        require(owner() == _msgSender(), "Not owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// -----------------------------------------
// OpenZeppelin PausableUpgradeable
// -----------------------------------------
pragma solidity ^0.8.0;

abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }
    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }
    modifier whenPaused() {
        _requirePaused();
        _;
    }
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Paused");
    }
    function _requirePaused() internal view virtual {
        require(paused(), "Not paused");
    }
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// -----------------------------------------
// OpenZeppelin ReentrancyGuardUpgradeable
// -----------------------------------------
pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }
    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "Reentrant");
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// -----------------------------------------
// OpenZeppelin UUPS pieces
// -----------------------------------------
pragma solidity ^0.8.0;

interface IERC1822ProxiableUpgradeable {
    function proxiableUUID() external view returns (bytes32);
}
interface IBeaconUpgradeable {
    function implementation() external view returns (address);
}
interface IERC1967Upgradeable {
    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);
    event BeaconUpgraded(address indexed beacon);
}
library StorageSlotUpgradeable {
    struct AddressSlot { address value; }
    struct BooleanSlot { bool value; }
    struct Bytes32Slot { bytes32 value; }
    struct Uint256Slot { uint256 value; }
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) { assembly { r.slot := slot } }
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) { assembly { r.slot := slot } }
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) { assembly { r.slot := slot } }
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) { assembly { r.slot := slot } }
}
abstract contract ERC1967UpgradeUpgradeable is Initializable, IERC1967Upgradeable {
    function __ERC1967Upgrade_init() internal onlyInitializing {}
    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {}
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "Not contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "Bad UUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "Zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "Not contract");
        require(AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()), "Beacon impl not contract");
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Not contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {}
    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {}
    address private immutable __self = address(this);
    modifier onlyProxy() {
        require(address(this) != __self, "Use delegatecall");
        require(_getImplementation() == __self, "Use active proxy");
        _;
    }
    modifier notDelegated() {
        require(address(this) == __self, "No delegatecall");
        _;
    }
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }
    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}

// -----------------------------------------
// Minimal ERC721 interfaces
// -----------------------------------------
pragma solidity ^0.8.0;

interface IERC165 { function supportsInterface(bytes4 interfaceId) external view returns (bool); }
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
interface IERC721ReceiverUpgradeable {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// -----------------------------------------
// Receipt interface
// -----------------------------------------
pragma solidity ^0.8.19;
interface IReceiptContract {
    function mint(address to, uint256 originalTokenId) external returns (uint256 receiptTokenId);
    function burn(uint256 receiptTokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getOriginalTokenId(uint256 receiptTokenId) external view returns (uint256);
    function validateReceipt(uint256 receiptTokenId, address expectedPool) external view returns (bool);
}

// -----------------------------------------
// SwapPoolNative (SLIM BUILD)
// -----------------------------------------
contract SwapPoolNative is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable,
    IERC721ReceiverUpgradeable
{
    using AddressUpgradeable for address payable;

    // Core state variables
    address public nftCollection;
    address public receiptContract;
    address public stonerPool;
    uint256 public swapFeeInWei;
    uint256 public stonerShare; // Percentage (0–100)
    bool public initialized;

    // Liquidity / limits
    uint256 public minPoolSize = 5;
    uint256 public maxBatchSize = 10;
    uint256 public maxUnstakeAllLimit = 20;

    // Pool token tracking
    uint256[] public poolTokens;
    mapping(uint256 => uint256) public tokenIndexInPool;
    mapping(uint256 => bool) public tokenInPool;

    // Reward system
    struct StakeInfo {
        uint256 stakedAt;
        uint256 rewardDebt;
        bool active;
    }
    mapping(uint256 => StakeInfo) public stakeInfos;           // receiptTokenId => info
    mapping(address => uint256[]) public userStakes;           // user => receiptTokenIds[]
    mapping(uint256 => uint256) public receiptToOriginalToken; // receiptId => originalTokenId
    mapping(uint256 => uint256) public originalToReceiptToken; // originalTokenId => receiptId

    uint256 public totalStaked;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;
    uint256 public totalRewardsDistributed;

    // Precision helpers
    uint256 private constant PRECISION = 1e18;
    uint256 private rewardCarry; // remainder in PRECISION units
    uint256 private totalPrecisionRewards;

    // User reward tracking
    mapping(address => uint256) public pendingRewards;
    mapping(address => uint256) public userRewardPerTokenPaid;

    // Batch operation flags
    bool private _inBatchOperation;
    uint256[] private _batchReceiptTokens;
    uint256[] private _batchReturnedTokens;

    // Events
    event SwapExecuted(address indexed user, uint256 tokenIdIn, uint256 tokenIdOut, uint256 feePaid);
    event BatchSwapExecuted(address indexed user, uint256 swapCount, uint256 totalFeePaid);
    event Staked(address indexed user, uint256 tokenId, uint256 receiptTokenId);
    event Unstaked(address indexed user, uint256 tokenId, uint256 receiptTokenId);
    event BatchUnstaked(address indexed user, uint256[] receiptTokenIds, uint256[] tokensReceived);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 amount);
    event SwapFeeUpdated(uint256 newFeeInWei);
    event StonerShareUpdated(uint256 newShare);
    event BatchLimitsUpdated(uint256 newMaxBatchSize, uint256 newMaxUnstakeAll);
    event FeeSplit(uint256 stonerAmount, uint256 rewardsAmount); // Analytics for fee distribution

    // Errors
    error AlreadyInitialized();
    error NotInitialized();
    error InvalidStonerShare();
    error TokenUnavailable();
    error IncorrectFee();
    error NotReceiptOwner();
    error TokenNotStaked();
    error NoRewardsToClaim();
    error InvalidReceiptToken();
    error NoTokensAvailable();
    error SameTokenSwap();
    error InsufficientLiquidity(uint256 available, uint256 minimum);
    error NotTokenOwner();
    error TokenNotApproved();

    modifier onlyInitialized() {
        if (!initialized) revert NotInitialized();
        _;
    }
    modifier minimumLiquidity() {
        require(poolTokens.length >= minPoolSize, "Low liquidity");
        _;
    }
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            pendingRewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _nftCollection,
        address _receiptContract,
        address _stonerPool,
        uint256 _swapFeeInWei,
        uint256 _stonerShare,
        address _initialOwner
    ) public initializer {
        require(_nftCollection != address(0) && _stonerPool != address(0), "Zero address");
        require(_receiptContract != address(0), "Zero receipt");
        require(_initialOwner != address(0), "Zero owner");
        require(_stonerShare < 100, "Bad share");

        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        nftCollection = _nftCollection;
        receiptContract = _receiptContract;
        stonerPool = _stonerPool;
        swapFeeInWei = _swapFeeInWei;
        stonerShare = _stonerShare;
        initialized = true;
        lastUpdateTime = block.timestamp;

        _transferOwnership(_initialOwner);
    }

    // -------------------- SWAP --------------------
    function swapNFT(uint256 tokenIdIn)
        external
        payable
        nonReentrant
        onlyInitialized
        whenNotPaused
        minimumLiquidity
        updateReward(address(0))
    {
        if (IERC721(nftCollection).ownerOf(tokenIdIn) != msg.sender) revert NotTokenOwner();
        if (IERC721(nftCollection).getApproved(tokenIdIn) != address(this) &&
            !IERC721(nftCollection).isApprovedForAll(msg.sender, address(this))) {
            revert TokenNotApproved();
        }
        if (msg.value != swapFeeInWei) revert IncorrectFee();
        if (poolTokens.length == 0) revert NoTokensAvailable();

        uint256 tokenIdOut = _getRandomAvailableToken();
        if (tokenIdIn == tokenIdOut) revert SameTokenSwap();

        uint256 stonerAmount = 0;
        uint256 rewardAmount = msg.value;
        if (stonerShare > 0) {
            stonerAmount = (msg.value * stonerShare) / 100;
            rewardAmount = msg.value - stonerAmount;
        }

        // Analytics: Emit fee split for tracking
        emit FeeSplit(stonerAmount, rewardAmount);

        _removeTokenFromPool(tokenIdOut);
        _addTokenToPool(tokenIdIn);

        if (rewardAmount > 0 && totalStaked > 0) {
            uint256 rewardWithCarry = (rewardAmount * PRECISION) + rewardCarry;
            uint256 rptIncrement = rewardWithCarry / totalStaked; // 1e18 per-NFT
            rewardCarry = rewardWithCarry % totalStaked;
            rewardPerTokenStored += rptIncrement;
            totalPrecisionRewards += rewardWithCarry;
            totalRewardsDistributed += rewardAmount;
            emit RewardsDistributed(rewardAmount);
        }

        IERC721(nftCollection).safeTransferFrom(msg.sender, address(this), tokenIdIn);
        IERC721(nftCollection).safeTransferFrom(address(this), msg.sender, tokenIdOut);

        if (IERC721(nftCollection).getApproved(tokenIdIn) == address(this)) {
            IERC721(nftCollection).approve(address(0), tokenIdIn);
        }
        if (stonerAmount > 0) {
            payable(stonerPool).sendValue(stonerAmount);
        }
        emit SwapExecuted(msg.sender, tokenIdIn, tokenIdOut, msg.value);
    }

    function swapNFTBatch(uint256[] calldata tokenIdsIn)
        external
        payable
        nonReentrant
        onlyInitialized
        whenNotPaused
        minimumLiquidity
        updateReward(address(0))
    {
        require(tokenIdsIn.length > 0, "Empty array");
        require(tokenIdsIn.length <= maxBatchSize, "Batch limit");
        require(poolTokens.length >= tokenIdsIn.length, "Not enough pool tokens");
        require(poolTokens.length - tokenIdsIn.length >= minPoolSize, "Insufficient pool liquidity");
        _checkForDuplicates(tokenIdsIn);

        uint256 totalFeeRequired = swapFeeInWei * tokenIdsIn.length;
        if (msg.value != totalFeeRequired) revert IncorrectFee();

        for (uint256 i = 0; i < tokenIdsIn.length; i++) {
            uint256 tokenIdIn = tokenIdsIn[i];
            if (IERC721(nftCollection).ownerOf(tokenIdIn) != msg.sender) revert NotTokenOwner();
            if (IERC721(nftCollection).getApproved(tokenIdIn) != address(this) &&
                !IERC721(nftCollection).isApprovedForAll(msg.sender, address(this))) {
                revert TokenNotApproved();
            }
        }

        uint256[] memory tokenIdsOut = new uint256[](tokenIdsIn.length);
        uint256[] memory usedIndices = new uint256[](tokenIdsIn.length);

        for (uint256 i = 0; i < tokenIdsIn.length; i++) {
            uint256 attempts = 0;
            uint256 randomIndex;
            bool isUnique;
            do {
                randomIndex = uint256(keccak256(abi.encodePacked(
                    block.timestamp, block.prevrandao, msg.sender, i, attempts, poolTokens.length
                ))) % poolTokens.length;
                isUnique = true;
                for (uint256 j = 0; j < i; j++) {
                    if (usedIndices[j] == randomIndex) { isUnique = false; break; }
                }
                if (isUnique && poolTokens[randomIndex] == tokenIdsIn[i]) { isUnique = false; }
                attempts++;
            } while (!isUnique && attempts < 100);
            require(isUnique, "Cannot find unique random token");
            usedIndices[i] = randomIndex;
            tokenIdsOut[i] = poolTokens[randomIndex];
        }

        uint256 stonerAmount = 0;
        uint256 rewardAmount = msg.value;
        if (stonerShare > 0) {
            stonerAmount = (msg.value * stonerShare) / 100;
            rewardAmount = msg.value - stonerAmount;
        }

        // Analytics: Emit fee split for tracking
        emit FeeSplit(stonerAmount, rewardAmount);

        for (uint256 i = 0; i < tokenIdsIn.length; i++) {
            _removeTokenFromPool(tokenIdsOut[i]);
            _addTokenToPool(tokenIdsIn[i]);
        }

        if (rewardAmount > 0 && totalStaked > 0) {
            uint256 rewardWithCarry = (rewardAmount * PRECISION) + rewardCarry;
            uint256 rptIncrement = rewardWithCarry / totalStaked; // 1e18 per-NFT
            rewardCarry = rewardWithCarry % totalStaked;
            rewardPerTokenStored += rptIncrement;
            totalPrecisionRewards += rewardWithCarry;
            totalRewardsDistributed += rewardAmount;
            emit RewardsDistributed(rewardAmount);
        }

        for (uint256 i = 0; i < tokenIdsIn.length; i++) {
            IERC721(nftCollection).safeTransferFrom(msg.sender, address(this), tokenIdsIn[i]);
            IERC721(nftCollection).safeTransferFrom(address(this), msg.sender, tokenIdsOut[i]);
            if (IERC721(nftCollection).getApproved(tokenIdsIn[i]) == address(this)) {
                IERC721(nftCollection).approve(address(0), tokenIdsIn[i]);
            }
            emit SwapExecuted(msg.sender, tokenIdsIn[i], tokenIdsOut[i], swapFeeInWei);
        }

        if (stonerAmount > 0) {
            payable(stonerPool).sendValue(stonerAmount);
        }
        emit BatchSwapExecuted(msg.sender, tokenIdsIn.length, msg.value);
    }

    // -------------------- STAKE --------------------
    function stakeNFT(uint256 tokenId)
        external
        nonReentrant
        onlyInitialized
        whenNotPaused
        updateReward(msg.sender)
    {
        IERC721(nftCollection).safeTransferFrom(msg.sender, address(this), tokenId);
        if (IERC721(nftCollection).getApproved(tokenId) == address(this)) {
            IERC721(nftCollection).approve(address(0), tokenId);
        }
        _addTokenToPool(tokenId);

        uint256 receiptTokenId = IReceiptContract(receiptContract).mint(msg.sender, tokenId);
        stakeInfos[receiptTokenId] = StakeInfo({ stakedAt: block.timestamp, rewardDebt: rewardPerTokenStored, active: true });
        receiptToOriginalToken[receiptTokenId] = tokenId;
        originalToReceiptToken[tokenId] = receiptTokenId;
        userStakes[msg.sender].push(receiptTokenId);
        totalStaked++;

        emit Staked(msg.sender, tokenId, receiptTokenId);
    }

    function unstakeNFT(uint256 receiptTokenId)
        external
        nonReentrant
        onlyInitialized
        whenNotPaused
        updateReward(msg.sender)
    {
        _unstakeNFTInternal(receiptTokenId);
    }

    function unstakeNFTBatch(uint256[] calldata receiptTokenIds)
        external
        nonReentrant
        onlyInitialized
        whenNotPaused
        updateReward(msg.sender)
    {
        uint256 batchLength = receiptTokenIds.length;
        require(batchLength > 0, "Empty array");
        require(batchLength <= maxBatchSize, "Batch limit");

        _inBatchOperation = true;
        delete _batchReceiptTokens;
        delete _batchReturnedTokens;

        for (uint256 i = 0; i < batchLength; i++) {
            _unstakeNFTInternal(receiptTokenIds[i]);
        }

        emit BatchUnstaked(msg.sender, _batchReceiptTokens, _batchReturnedTokens);
        _inBatchOperation = false;
        delete _batchReceiptTokens;
        delete _batchReturnedTokens;
    }

    function unstakeAllNFTs()
        external
        nonReentrant
        onlyInitialized
        whenNotPaused
        updateReward(msg.sender)
    {
        uint256[] memory userReceiptTokens = userStakes[msg.sender];
        uint256 userStakesLength = userReceiptTokens.length;
        require(userStakesLength > 0, "No stakes");

        uint256[] memory activeReceipts = new uint256[](userStakesLength);
        uint256 activeCount = 0;
        for (uint256 i = 0; i < userStakesLength; i++) {
            if (stakeInfos[userReceiptTokens[i]].active) {
                activeReceipts[activeCount] = userReceiptTokens[i];
                activeCount++;
            }
        }
        require(activeCount > 0, "No active");
        require(activeCount <= maxUnstakeAllLimit, "Too many stakes");

        _inBatchOperation = true;
        delete _batchReceiptTokens;
        delete _batchReturnedTokens;

        for (uint256 i = 0; i < activeCount; i++) {
            _unstakeNFTInternal(activeReceipts[i]);
        }

        emit BatchUnstaked(msg.sender, _batchReceiptTokens, _batchReturnedTokens);
        _inBatchOperation = false;
        delete _batchReceiptTokens;
        delete _batchReturnedTokens;
    }

    function _unstakeNFTInternal(uint256 receiptTokenId) internal {
        if (IReceiptContract(receiptContract).ownerOf(receiptTokenId) != msg.sender) revert NotReceiptOwner();
        StakeInfo storage stakeInfo = stakeInfos[receiptTokenId];
        if (!stakeInfo.active) revert TokenNotStaked();

        uint256 originalTokenId = receiptToOriginalToken[receiptTokenId];
        stakeInfo.active = false;
        totalStaked--;
        _removeFromUserStakes(msg.sender, receiptTokenId);
        delete receiptToOriginalToken[receiptTokenId];
        delete originalToReceiptToken[originalTokenId];
        IReceiptContract(receiptContract).burn(receiptTokenId);

        uint256 tokenToReturn;
        if (tokenInPool[originalTokenId] && IERC721(nftCollection).ownerOf(originalTokenId) == address(this)) {
            tokenToReturn = originalTokenId;
        } else {
            tokenToReturn = _getRandomAvailableToken();
        }

        _removeTokenFromPool(tokenToReturn);
        IERC721(nftCollection).safeTransferFrom(address(this), msg.sender, tokenToReturn);

        if (_inBatchOperation) {
            _batchReceiptTokens.push(receiptTokenId);
            _batchReturnedTokens.push(tokenToReturn);
        } else {
            emit Unstaked(msg.sender, tokenToReturn, receiptTokenId);
        }
    }

    // -------------------- REWARDS --------------------
    function claimRewards() external nonReentrant updateReward(msg.sender) {
        uint256 reward = pendingRewards[msg.sender];
        if (reward == 0) revert NoRewardsToClaim();
        pendingRewards[msg.sender] = 0;
        payable(msg.sender).sendValue(reward);
        emit RewardsClaimed(msg.sender, reward);
    }

    function claimRewardsOnly() external nonReentrant updateReward(msg.sender) {
        uint256 reward = pendingRewards[msg.sender];
        if (reward == 0) revert NoRewardsToClaim();
        pendingRewards[msg.sender] = 0;
        payable(msg.sender).sendValue(reward);
        emit RewardsClaimed(msg.sender, reward);
    }

    function exit()
        external
        nonReentrant
        onlyInitialized
        whenNotPaused
        updateReward(msg.sender)
    {
        uint256[] memory userReceiptTokens = userStakes[msg.sender];
        uint256 userStakeCount = userReceiptTokens.length;

        if (userStakeCount > 0) {
            require(userStakeCount <= maxBatchSize, "Too many stakes, use batch");
            _inBatchOperation = true;
            delete _batchReceiptTokens;
            delete _batchReturnedTokens;

            for (uint256 i = userStakeCount; i > 0; i--) {
                _unstakeNFTInternal(userReceiptTokens[i - 1]);
            }

            emit BatchUnstaked(msg.sender, _batchReceiptTokens, _batchReturnedTokens);
            _inBatchOperation = false;
            delete _batchReceiptTokens;
            delete _batchReturnedTokens;
        }

        uint256 reward = pendingRewards[msg.sender];
        if (reward > 0) {
            pendingRewards[msg.sender] = 0;
            payable(msg.sender).sendValue(reward);
            emit RewardsClaimed(msg.sender, reward);
        }
    }

    // -------------------- INTERNAL HELPERS --------------------
    function _addTokenToPool(uint256 tokenId) internal {
        if (!tokenInPool[tokenId]) {
            tokenIndexInPool[tokenId] = poolTokens.length;
            poolTokens.push(tokenId);
            tokenInPool[tokenId] = true;
        }
    }
    function _removeTokenFromPool(uint256 tokenId) internal {
        if (tokenInPool[tokenId]) {
            uint256 index = tokenIndexInPool[tokenId];
            uint256 lastToken = poolTokens[poolTokens.length - 1];
            poolTokens[index] = lastToken;
            tokenIndexInPool[lastToken] = index;
            poolTokens.pop();
            delete tokenIndexInPool[tokenId];
            tokenInPool[tokenId] = false;
        }
    }
    function _getRandomAvailableToken() internal view returns (uint256) {
        if (poolTokens.length == 0) revert NoTokensAvailable();
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(
            block.timestamp, block.prevrandao, msg.sender, poolTokens.length
        ))) % poolTokens.length;
        return poolTokens[randomIndex];
    }
    function _checkForDuplicates(uint256[] calldata tokenIds) internal pure {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            for (uint256 j = i + 1; j < tokenIds.length; j++) {
                require(tokenIds[i] != tokenIds[j], "Duplicate token");
            }
        }
    }
    function _removeFromUserStakes(address user, uint256 receiptTokenId) internal {
        uint256[] storage stakes = userStakes[user];
        uint256 stakesLength = stakes.length;
        for (uint256 i = 0; i < stakesLength; i++) {
            if (stakes[i] == receiptTokenId) {
                stakes[i] = stakes[stakesLength - 1];
                stakes.pop();
                break;
            }
        }
    }

    // -------------------- REWARD VIEW --------------------
    function rewardPerToken() public view returns (uint256) {
        return rewardPerTokenStored;
    }
    function earned(address account) public view returns (uint256) {
        uint256 userStakedCount = getUserActiveStakeCount(account);
        if (userStakedCount == 0) return pendingRewards[account];
        uint256 rewardDiff = rewardPerToken() - userRewardPerTokenPaid[account];
        return pendingRewards[account] + (userStakedCount * rewardDiff) / 1e18;
    }
    function getUserActiveStakeCount(address user) public view returns (uint256 count) {
        uint256[] memory stakes = userStakes[user];
        uint256 stakesLength = stakes.length;
        for (uint256 i = 0; i < stakesLength; i++) {
            if (stakeInfos[stakes[i]].active) {
                count++;
            }
        }
    }

    // -------------------- ADMIN --------------------
    function setSwapFee(uint256 newFeeInWei) external onlyOwner {
        swapFeeInWei = newFeeInWei;
        emit SwapFeeUpdated(newFeeInWei);
    }
    function setStonerShare(uint256 newShare) external onlyOwner {
        if (newShare >= 100) revert InvalidStonerShare();
        stonerShare = newShare;
        emit StonerShareUpdated(newShare);
    }
    function setBatchLimits(uint256 newMaxBatchSize, uint256 newMaxUnstakeAll) external onlyOwner {
        require(newMaxBatchSize > 0 && newMaxBatchSize <= 50, "Invalid batch size");
        require(newMaxUnstakeAll > 0 && newMaxUnstakeAll <= 100, "Invalid unstake all limit");
        maxBatchSize = newMaxBatchSize;
        maxUnstakeAllLimit = newMaxUnstakeAll;
        emit BatchLimitsUpdated(newMaxBatchSize, newMaxUnstakeAll);
    }
    function setMinPoolSize(uint256 newMinPoolSize) external onlyOwner {
        require(newMinPoolSize > 0 && newMinPoolSize <= 20, "Invalid min pool size");
        minPoolSize = newMinPoolSize;
    }
    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
    function registerMe() external onlyOwner {
        (bool _success,) = address(0xDC2B0D2Dd2b7759D97D50db4eabDC36973110830).call(
            abi.encodeWithSignature("selfRegister(uint256)", 92)
        );
        require(_success, "FeeM registration failed");
    }

    // -------------------- BASIC VIEWS --------------------
    function getPoolInfo() external view returns (
        address collection,
        uint256 totalNFTs,
        uint256 feeInWei,
        uint256 stonerPercent,
        uint256 stakedCount,
        uint256 rewardsDistributed
    ) {
        return (
            nftCollection,
            IERC721(nftCollection).balanceOf(address(this)),
            swapFeeInWei,
            stonerShare,
            totalStaked,
            totalRewardsDistributed
        );
    }
    function isStakeActive(uint256 receiptTokenId) public view returns (bool) {
        return stakeInfos[receiptTokenId].active;
    }
    function getReceiptForToken(uint256 tokenId) external view returns (uint256) {
        return originalToReceiptToken[tokenId];
    }
    function getTokenForReceipt(uint256 receiptTokenId) external view returns (uint256) {
        return receiptToOriginalToken[receiptTokenId];
    }
    function getPoolTokens() external view returns (uint256[] memory) {
        return poolTokens;
    }
    function getAvailableTokenCount() external view returns (uint256) {
        return poolTokens.length;
    }
    function isTokenInPool(uint256 tokenId) external view returns (bool) {
        return tokenInPool[tokenId] && IERC721(nftCollection).ownerOf(tokenId) == address(this);
    }

    // -------------------- UUPS --------------------
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }
    function _authorizeUpgrade(address) internal override onlyOwner {}
    receive() external payable { revert("Use swapNFT function"); }
}

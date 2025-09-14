// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts@4.8.3/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts@4.8.3/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts@4.8.3/proxy/Proxy.sol

// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// File: @openzeppelin/contracts@4.8.3/proxy/beacon/IBeacon.sol

// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// File: @openzeppelin/contracts@4.8.3/interfaces/IERC1967.sol

// OpenZeppelin Contracts (last updated v4.8.3) (interfaces/IERC1967.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.
 *
 * _Available since v4.9._
 */
interface IERC1967 {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);
}

// File: @openzeppelin/contracts@4.8.3/interfaces/draft-IERC1822.sol

// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// File: @openzeppelin/contracts@4.8.3/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
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
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts@4.8.3/utils/StorageSlot.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// File: @openzeppelin/contracts@4.8.3/proxy/ERC1967/ERC1967Upgrade.sol

// OpenZeppelin Contracts (last updated v4.8.3) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade is IERC1967 {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is
     * validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// File: @openzeppelin/contracts@4.8.3/proxy/ERC1967/ERC1967Proxy.sol

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}

// File: @openzeppelin/contracts@4.8.3/utils/introspection/IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts@4.8.3/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts@4.8.3/security/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 */
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// File: SwapPoolFactory.sol

pragma solidity ^0.8.19;

interface ISwapPoolNative {
    function initialize(
        address nftCollection,
        address receiptContract,
        address stonerPool,
        uint256 swapFeeInWei,
        uint256 stonerShare,
        address initialOwner              // NEW: Add initialOwner parameter
    ) external;
    function pause() external;
    function unpause() external;
}

interface ISwapPoolRewards {
    function earned(address account) external view returns (uint256);
    function claimRewards() external;
    function nftCollection() external view returns (address);
}

contract SwapPoolFactoryNative is Ownable, ReentrancyGuard {
    address public implementation;
    mapping(address => address) public collectionToPool;
    address[] public allPools;

    event PoolCreated(address indexed collection, address indexed pool, address indexed owner);
    event PoolDeployed(address indexed newPool, address indexed collection, address indexed deployer);
    event FactoryDeployed(address indexed implementation, address indexed owner);
    event ImplementationUpdated(address indexed oldImpl, address indexed newImpl);
    event BatchRewardsClaimed(address indexed user, uint256 poolCount, uint256 totalAmount);

    error ZeroAddressNotAllowed();
    error PoolAlreadyExists();
    error InvalidShareRange();
    error InvalidERC721();
    error InvalidImplementation();

    constructor(address _implementation) {
        if (_implementation == address(0)) revert ZeroAddressNotAllowed();
        if (!Address.isContract(_implementation)) revert InvalidImplementation();
        implementation = _implementation;
        emit FactoryDeployed(_implementation, msg.sender);
    }

    function createPool(
        address nftCollection,
        address receiptContract,
        address stonerPool,
        uint256 swapFeeInWei,
        uint256 stonerShare,
        address initialOwner                    // NEW: Add initialOwner parameter
    ) external onlyOwner returns (address) {
        // Input validation
        if (
            nftCollection == address(0) ||
            receiptContract == address(0) ||
            stonerPool == address(0) ||
            initialOwner == address(0)          // NEW: Validate initialOwner
        ) revert ZeroAddressNotAllowed();

        if (collectionToPool[nftCollection] != address(0)) revert PoolAlreadyExists();
        if (stonerShare > 100) revert InvalidShareRange();

        // Enhanced ERC721 validation
        if (!Address.isContract(nftCollection)) revert InvalidERC721();
        
        try IERC165(nftCollection).supportsInterface(0x80ac58cd) returns (bool supported) {
            if (!supported) revert InvalidERC721();
        } catch {
            revert InvalidERC721();
        }

        // Create proxy with initialization data
        bytes memory initData = abi.encodeWithSelector(
            ISwapPoolNative.initialize.selector,
            nftCollection,
            receiptContract,
            stonerPool,
            swapFeeInWei,
            stonerShare,
            initialOwner                       // NEW: Pass initialOwner to initialize
        );

        ERC1967Proxy proxy = new ERC1967Proxy(implementation, initData);
        address proxyAddress = address(proxy);

        // Update mappings
        collectionToPool[nftCollection] = proxyAddress;
        allPools.push(proxyAddress);

        emit PoolCreated(nftCollection, proxyAddress, msg.sender);
        emit PoolDeployed(proxyAddress, nftCollection, msg.sender);
        return proxyAddress;
    }

    // 🎯 BATCH REWARD CLAIMING FUNCTIONS

    /**
     * @dev Claim rewards from specific pools
     * @param pools Array of pool addresses to claim from
     */
    function batchClaimRewards(address[] calldata pools) external nonReentrant {
        require(pools.length > 0, "Empty pools array");
        require(pools.length <= 50, "Too many pools"); // Gas limit protection
        
        uint256 totalClaimed = 0;
        uint256 poolsLength = pools.length; // Gas optimization: cache array length
        
        for (uint256 i = 0; i < poolsLength; i++) {
            // Verify it's a valid pool from this factory
            try ISwapPoolRewards(pools[i]).nftCollection() returns (address collection) {
                require(collectionToPool[collection] == pools[i], "Invalid pool");
            } catch {
                continue; // Skip invalid pools
            }
            
            try ISwapPoolRewards(pools[i]).earned(msg.sender) returns (uint256 pending) {
                if (pending > 0) {
                    try ISwapPoolRewards(pools[i]).claimRewards() {
                        totalClaimed += pending;
                    } catch {
                        // Skip failed claims, continue with others
                    }
                }
            } catch {
                // Skip pools with errors
            }
        }
        
        emit BatchRewardsClaimed(msg.sender, pools.length, totalClaimed);
    }

    /**
     * @dev Claim rewards from all pools (with gas limit protection)
     */
    function claimAllRewards() external nonReentrant {
        require(allPools.length > 0, "No pools available");
        require(allPools.length <= 50, "Too many pools - use paginated version"); // Gas limit protection
        
        uint256 totalClaimed = 0;
        uint256 allPoolsLength = allPools.length; // Gas optimization: cache array length
        
        for (uint256 i = 0; i < allPoolsLength; i++) {
            // Verify it's a valid pool from this factory
            try ISwapPoolRewards(allPools[i]).nftCollection() returns (address collection) {
                require(collectionToPool[collection] == allPools[i], "Invalid pool");
            } catch {
                continue; // Skip invalid pools
            }
            
            try ISwapPoolRewards(allPools[i]).earned(msg.sender) returns (uint256 pending) {
                if (pending > 0) {
                    try ISwapPoolRewards(allPools[i]).claimRewards() {
                        totalClaimed += pending;
                    } catch {
                        // Skip failed claims, continue with others
                    }
                }
            } catch {
                // Skip pools with errors
            }
        }
        
        emit BatchRewardsClaimed(msg.sender, allPools.length, totalClaimed);
    }

    /**
     * @dev Claim rewards from pools with pagination for scalability
     * @param startIndex Starting index in allPools array
     * @param batchSize Number of pools to process (max 20 for safety)
     */
    function claimAllRewardsPaginated(uint256 startIndex, uint256 batchSize) 
        external 
        nonReentrant 
        returns (uint256 totalClaimed, uint256 poolsProcessed) 
    {
        require(allPools.length > 0, "No pools available");
        require(batchSize <= 20, "Batch size too large"); // Gas limit protection
        require(startIndex < allPools.length, "Start index out of bounds");
        
        uint256 endIndex = startIndex + batchSize;
        if (endIndex > allPools.length) {
            endIndex = allPools.length;
        }
        
        totalClaimed = 0;
        poolsProcessed = 0;
        
        for (uint256 i = startIndex; i < endIndex; i++) {
            poolsProcessed++;
            
            // Verify it's a valid pool from this factory
            try ISwapPoolRewards(allPools[i]).nftCollection() returns (address collection) {
                require(collectionToPool[collection] == allPools[i], "Invalid pool");
            } catch {
                continue; // Skip invalid pools
            }
            
            try ISwapPoolRewards(allPools[i]).earned(msg.sender) returns (uint256 pending) {
                if (pending > 0) {
                    try ISwapPoolRewards(allPools[i]).claimRewards() {
                        totalClaimed += pending;
                    } catch {
                        // Skip failed claims, continue with others
                    }
                }
            } catch {
                // Skip pools with errors
            }
        }
        
        emit BatchRewardsClaimed(msg.sender, poolsProcessed, totalClaimed);
    }

    /**
     * @dev Get paginated list of pools for frontend integration
     * @param startIndex Starting index in allPools array
     * @param batchSize Number of pools to return (max 50)
     */
    function getAllPoolsPaginated(uint256 startIndex, uint256 batchSize) 
        external 
        view 
        returns (address[] memory pools, uint256 totalPools) 
    {
        require(batchSize <= 50, "Batch size too large");
        totalPools = allPools.length;
        
        if (startIndex >= totalPools) {
            return (new address[](0), totalPools);
        }
        
        uint256 endIndex = startIndex + batchSize;
        if (endIndex > totalPools) {
            endIndex = totalPools;
        }
        
        pools = new address[](endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            pools[i - startIndex] = allPools[i];
        }
    }

    /**
     * @dev Get user's claimable rewards with pagination
     * @param user Address to check rewards for
     * @param startIndex Starting index in allPools array
     * @param batchSize Number of pools to check (max 20)
     */
    function getUserClaimableRewardsPaginated(address user, uint256 startIndex, uint256 batchSize)
        external
        view
        returns (uint256 totalClaimable, address[] memory validPools, uint256[] memory amounts)
    {
        require(batchSize <= 20, "Batch size too large");
        require(startIndex < allPools.length, "Start index out of bounds");
        
        uint256 endIndex = startIndex + batchSize;
        if (endIndex > allPools.length) {
            endIndex = allPools.length;
        }
        
        validPools = new address[](endIndex - startIndex);
        amounts = new uint256[](endIndex - startIndex);
        totalClaimable = 0;
        uint256 validCount = 0;
        
        for (uint256 i = startIndex; i < endIndex; i++) {
            try ISwapPoolRewards(allPools[i]).earned(user) returns (uint256 pending) {
                if (pending > 0) {
                    validPools[validCount] = allPools[i];
                    amounts[validCount] = pending;
                    totalClaimable += pending;
                    validCount++;
                }
            } catch {
                // Skip pools with errors
            }
        }
        
        // Resize arrays to remove empty slots
        assembly {
            mstore(validPools, validCount)
            mstore(amounts, validCount)
        }
    }

    /**
     * @dev Estimate gas costs for batch operations
     * @param batchSize Number of pools to process
     */
    function estimateBatchGasCosts(uint256 batchSize)
        external
        view
        returns (
            uint256 estimatedGas,
            uint256 recommendedBatchSize,
            uint256 totalBatches,
            bool needsPagination
        )
    {
        uint256 poolCount = allPools.length;
        needsPagination = poolCount > 50;
        
        // Rough estimates based on typical operations
        uint256 baseGas = 21000; // Transaction base cost
        uint256 gasPerPool = 45000; // Estimated gas per pool claim
        
        if (batchSize == 0 || batchSize > poolCount) {
            batchSize = poolCount;
        }
        
        estimatedGas = baseGas + (gasPerPool * batchSize);
        
        // Recommend batch size to stay under gas limits
        uint256 targetGasLimit = 8000000; // Conservative estimate
        recommendedBatchSize = (targetGasLimit - baseGas) / gasPerPool;
        if (recommendedBatchSize > 20) recommendedBatchSize = 20; // Safety cap
        if (recommendedBatchSize > poolCount) recommendedBatchSize = poolCount;
        
        totalBatches = (poolCount + recommendedBatchSize - 1) / recommendedBatchSize; // Ceiling division
    }

    /**
     * @dev Get user's pending rewards across all pools
     * @param user User address to check
     */
    function getUserPendingRewards(address user) external view returns (
        uint256 totalPending,
        address[] memory poolsWithRewards,
        uint256[] memory pendingAmounts
    ) {
        address[] memory validPools = new address[](allPools.length);
        uint256[] memory amounts = new uint256[](allPools.length);
        uint256 count = 0;
        
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).earned(user) returns (uint256 pending) {
                if (pending > 0) {
                    validPools[count] = allPools[i];
                    amounts[count] = pending;
                    totalPending += pending;
                    count++;
                }
            } catch {
                // Skip pools with errors
            }
        }
        
        // Resize arrays to actual count
        poolsWithRewards = new address[](count);
        pendingAmounts = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            poolsWithRewards[i] = validPools[i];
            pendingAmounts[i] = amounts[i];
        }
    }

    /**
     * @dev Get user's total pending rewards (simple version)
     * @param user User address to check
     */
    function getUserTotalPendingRewards(address user) external view returns (uint256 totalPending) {
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).earned(user) returns (uint256 pending) {
                totalPending += pending;
            } catch {
                // Skip pools with errors
            }
        }
    }

    /**
     * @dev Check how many pools user has rewards in
     * @param user User address to check
     */
    function getUserActivePoolCount(address user) external view returns (uint256 activeCount) {
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).earned(user) returns (uint256 pending) {
                if (pending > 0) {
                    activeCount++;
                }
            } catch {
                // Skip pools with errors
            }
        }
    }

    // 🔧 ADMIN FUNCTIONS

    function setImplementation(address newImpl) external onlyOwner {
        if (newImpl == address(0)) revert ZeroAddressNotAllowed();
        if (!Address.isContract(newImpl)) revert InvalidImplementation();
        
        address oldImpl = implementation;
        implementation = newImpl;
        emit ImplementationUpdated(oldImpl, newImpl);
    }

    function registerMe() external onlyOwner {
        (bool _success,) = address(0xDC2B0D2Dd2b7759D97D50db4eabDC36973110830).call(
            abi.encodeWithSignature("selfRegister(uint256)", 92)
        );
        require(_success, "FeeM registration failed");
    }

    // 📊 VIEW FUNCTIONS

    function getPool(address collection) external view returns (address) {
        return collectionToPool[collection];
    }

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }

    function getPoolCount() external view returns (uint256) {
        return allPools.length;
    }

    function isPoolCreated(address collection) external view returns (bool) {
        return collectionToPool[collection] != address(0);
    }

    /**
     * @dev Get comprehensive factory statistics
     */
    function getFactoryStats() external view returns (
        uint256 totalPools,
        address currentImplementation,
        address factoryOwner
    ) {
        return (
            allPools.length,
            implementation,
            owner()
        );
    }

    /**
     * @dev Get detailed analytics across all pools for dashboard
     */
    function getGlobalAnalytics() external view returns (
        uint256 totalValueLocked,      // Total NFTs across all pools
        uint256 totalRewardsDistributed,
        uint256 totalActiveStakers,
        uint256 mostActivePool,        // Index of most active pool
        uint256 highestAPYPool         // Index of highest APY pool
    ) {
        uint256 totalNFTs = 0;
        uint256 totalRewards = 0;
        uint256 totalStakers = 0;
        uint256 maxNFTs = 0;
        uint256 mostActive = 0;
        uint256 highestAPY = 0;

        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).nftCollection() returns (address collection) {
                if (collectionToPool[collection] == allPools[i]) {
                    // Get pool stats (would need extended interface)
                    try IERC721(collection).balanceOf(allPools[i]) returns (uint256 poolNFTs) {
                        totalNFTs += poolNFTs;
                        if (poolNFTs > maxNFTs) {
                            maxNFTs = poolNFTs;
                            mostActive = i;
                        }
                    } catch {}
                }
            } catch {}
        }

        return (totalNFTs, totalRewards, totalStakers, mostActive, highestAPY);
    }

    /**
     * @dev Get trending pools for homepage display
     */
    function getTrendingPools(uint256 limit) external view returns (
        address[] memory pools,
        address[] memory collections,
        uint256[] memory tvl,           // Total Value Locked
        uint256[] memory volume24h,     // 24h volume
        uint256[] memory apy           // Current APY
    ) {
        uint256 poolCount = allPools.length;
        uint256 resultCount = limit > poolCount ? poolCount : limit;
        
        pools = new address[](resultCount);
        collections = new address[](resultCount);
        tvl = new uint256[](resultCount);
        volume24h = new uint256[](resultCount);
        apy = new uint256[](resultCount);
        
        for (uint256 i = 0; i < resultCount; i++) {
            pools[i] = allPools[i];
            try ISwapPoolRewards(allPools[i]).nftCollection() returns (address collection) {
                collections[i] = collection;
                try IERC721(collection).balanceOf(allPools[i]) returns (uint256 balance) {
                    tvl[i] = balance;
                } catch {}
            } catch {}
            // volume24h and apy would require additional tracking
        }
    }

    // 🚨 EMERGENCY FUNCTIONS
    function emergencyPauseAllPools() external onlyOwner {
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolNative(allPools[i]).pause() {} catch {}
        }
    }

    function emergencyUnpauseAllPools() external onlyOwner {
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolNative(allPools[i]).unpause() {} catch {}
        }
    }

    function updateImplementation(address newImplementation) external onlyOwner {
        if (newImplementation == address(0)) revert ZeroAddressNotAllowed();
        if (!Address.isContract(newImplementation)) revert InvalidImplementation();
        
        address oldImpl = implementation;
        implementation = newImplementation;
        emit ImplementationUpdated(oldImpl, newImplementation);
    }

    // 🎯 ENHANCED UI/UX FUNCTIONS FOR BETTER FRONTEND INTEGRATION

    /**
     * @dev Get comprehensive dashboard data for factory overview
     */
    function getFactoryDashboard() external view returns (
        uint256 totalPools,
        uint256 totalCollections,
        uint256 totalTVL,
        uint256 averagePoolSize,
        uint256 largestPoolTVL,
        address mostActivePool,
        uint256 factoryHealthScore
    ) {
        totalPools = allPools.length;
        totalCollections = totalPools; // 1:1 mapping
        
        uint256 poolSizeSum = 0;
        uint256 maxPoolSize = 0;
        address largestPool = address(0);
        uint256 healthyPools = 0;
        
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).nftCollection() returns (address collection) {
                if (collectionToPool[collection] == allPools[i]) {
                    try IERC721(collection).balanceOf(allPools[i]) returns (uint256 balance) {
                        poolSizeSum += balance;
                        totalTVL += balance;
                        if (balance > maxPoolSize) {
                            maxPoolSize = balance;
                            largestPool = allPools[i];
                        }
                        if (balance >= 10) healthyPools++; // Consider pools with 10+ NFTs healthy
                    } catch {}
                }
            } catch {}
        }
        
        averagePoolSize = totalPools > 0 ? poolSizeSum / totalPools : 0;
        largestPoolTVL = maxPoolSize;
        mostActivePool = largestPool;
        factoryHealthScore = totalPools > 0 ? (healthyPools * 100) / totalPools : 0;
    }

    /**
     * @dev Get pool leaderboard for competitive display
     */
    function getPoolLeaderboard(uint256 limit) external view returns (
        address[] memory pools,
        address[] memory collections,
        uint256[] memory tvlRanks,
        uint256[] memory volumeRanks,
        uint256[] memory stakingRanks,
        string[] memory collectionNames
    ) {
        uint256 resultCount = limit > allPools.length ? allPools.length : limit;
        
        pools = new address[](resultCount);
        collections = new address[](resultCount);
        tvlRanks = new uint256[](resultCount);
        volumeRanks = new uint256[](resultCount);
        stakingRanks = new uint256[](resultCount);
        collectionNames = new string[](resultCount);
        
        // Simple implementation - in production would sort by actual metrics
        for (uint256 i = 0; i < resultCount; i++) {
            pools[i] = allPools[i];
            try ISwapPoolRewards(allPools[i]).nftCollection() returns (address collection) {
                collections[i] = collection;
                try IERC721(collection).balanceOf(allPools[i]) returns (uint256 balance) {
                    tvlRanks[i] = balance;
                } catch {}
                // Would implement name resolution in production
                collectionNames[i] = "NFT Collection";
            } catch {}
            volumeRanks[i] = i + 1; // Placeholder ranking
            stakingRanks[i] = i + 1; // Placeholder ranking
        }
    }

    /**
     * @dev Get user's portfolio across all pools
     */
    function getUserFactoryPortfolio(address user) external view returns (
        uint256 totalStakedPools,
        uint256 totalPendingRewards,
        uint256 totalLifetimeRewards,
        address[] memory activePools,
        uint256[] memory stakedPerPool,
        uint256[] memory pendingPerPool,
        bool hasClaimableRewards
    ) {
        uint256 activeCount = 0;
        uint256 totalPending = 0;
        
        // First pass: count active pools and calculate totals
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).earned(user) returns (uint256 pending) {
                if (pending > 0) {
                    activeCount++;
                    totalPending += pending;
                }
            } catch {}
        }
        
        // Initialize arrays
        activePools = new address[](activeCount);
        stakedPerPool = new uint256[](activeCount);
        pendingPerPool = new uint256[](activeCount);
        
        // Second pass: populate arrays
        uint256 index = 0;
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).earned(user) returns (uint256 pending) {
                if (pending > 0) {
                    activePools[index] = allPools[i];
                    pendingPerPool[index] = pending;
                    stakedPerPool[index] = 0; // Would need extended interface to get staked count
                    index++;
                }
            } catch {}
        }
        
        totalStakedPools = activeCount;
        totalPendingRewards = totalPending;
        totalLifetimeRewards = 0; // Would need tracking
        hasClaimableRewards = totalPending > 0;
    }

    /**
     * @dev Get optimized batch claiming recommendations
     */
    function getBatchClaimingRecommendations(address user) external view returns (
        bool shouldUseBatch,
        uint256 recommendedBatchSize,
        uint256 estimatedGasSavings,
        uint256 totalClaimableAmount,
        address[] memory priorityPools,
        string memory recommendation
    ) {
        uint256 poolsWithRewards = 0;
        uint256 totalRewards = 0;
        
        // Count pools with rewards
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).earned(user) returns (uint256 pending) {
                if (pending > 0) {
                    poolsWithRewards++;
                    totalRewards += pending;
                }
            } catch {}
        }
        
        shouldUseBatch = poolsWithRewards > 2;
        recommendedBatchSize = poolsWithRewards > 20 ? 20 : poolsWithRewards;
        estimatedGasSavings = poolsWithRewards > 1 ? (poolsWithRewards - 1) * 25000 : 0; // Rough estimate
        totalClaimableAmount = totalRewards;
        
        if (poolsWithRewards == 0) {
            recommendation = "No rewards to claim";
        } else if (poolsWithRewards == 1) {
            recommendation = "Single pool claim recommended";
        } else if (poolsWithRewards <= 5) {
            recommendation = "Small batch claim (all pools)";
        } else if (poolsWithRewards <= 20) {
            recommendation = "Batch claim all pools";
        } else {
            recommendation = "Use paginated batch claiming";
        }
        
        // Get priority pools (highest rewards first)
        priorityPools = new address[](recommendedBatchSize);
        // In production, would sort by reward amount
    }

    /**
     * @dev Get factory health metrics for monitoring
     */
    function getFactoryHealthMetrics() external view returns (
        uint256 healthScore,
        bool isHealthy,
        uint256 activePoolsPercent,
        uint256 averagePoolUtilization,
        string memory healthStatus,
        string[] memory warnings
    ) {
        uint256 activePools = 0;
        uint256 totalUtilization = 0;
        uint256 warningCount = 0;
        
        warnings = new string[](5); // Max 5 warnings
        
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).nftCollection() returns (address collection) {
                if (collectionToPool[collection] == allPools[i]) {
                    try IERC721(collection).balanceOf(allPools[i]) returns (uint256 balance) {
                        if (balance > 0) {
                            activePools++;
                            totalUtilization += balance;
                        }
                    } catch {}
                }
            } catch {}
        }
        
        activePoolsPercent = allPools.length > 0 ? (activePools * 100) / allPools.length : 0;
        averagePoolUtilization = activePools > 0 ? totalUtilization / activePools : 0;
        
        // Calculate health score
        healthScore = 0;
        if (allPools.length > 0) healthScore += 20;
        if (activePoolsPercent >= 50) healthScore += 30;
        if (averagePoolUtilization >= 10) healthScore += 30;
        if (allPools.length >= 5) healthScore += 20;
        
        isHealthy = healthScore >= 60;
        
        if (healthScore >= 80) {
            healthStatus = "Excellent";
        } else if (healthScore >= 60) {
            healthStatus = "Good";
        } else if (healthScore >= 40) {
            healthStatus = "Fair";
        } else {
            healthStatus = "Poor";
        }
        
        // Add warnings
        if (allPools.length == 0) {
            warnings[warningCount] = "No pools created";
            warningCount++;
        }
        if (activePoolsPercent < 50) {
            warnings[warningCount] = "Less than 50% pools are active";
            warningCount++;
        }
        if (averagePoolUtilization < 5) {
            warnings[warningCount] = "Low average pool utilization";
            warningCount++;
        }
        
        // Resize warnings array
        assembly {
            mstore(warnings, warningCount)
        }
    }

    /**
     * @dev Get comprehensive collection analytics
     */
    function getCollectionAnalytics(address collection) external view returns (
        bool hasPool,
        address poolAddress,
        uint256 totalStaked,
        uint256 totalLiquidity,
        uint256 totalRewardsDistributed,
        uint256 currentAPY,
        uint256 uniqueStakers,
        bool poolIsHealthy
    ) {
        hasPool = collectionToPool[collection] != address(0);
        poolAddress = collectionToPool[collection];
        
        if (hasPool) {
            try IERC721(collection).balanceOf(poolAddress) returns (uint256 balance) {
                totalLiquidity = balance;
                poolIsHealthy = balance >= 10;
            } catch {}
            
            // Additional metrics would require extended pool interface
            totalStaked = 0; // Would need pool query
            totalRewardsDistributed = 0; // Would need pool query
            currentAPY = 0; // Would need pool query
            uniqueStakers = 0; // Would need pool query
        }
    }

    /**
     * @dev Get gas optimization recommendations
     */
    function getGasOptimizationTips(address user) external view returns (
        string[] memory tips,
        uint256[] memory potentialSavings,
        bool[] memory highPriority
    ) {
        uint256 userPoolCount = this.getUserActivePoolCount(user);
        
        tips = new string[](3);
        potentialSavings = new uint256[](3);
        highPriority = new bool[](3);
        
        uint256 tipCount = 0;
        
        if (userPoolCount > 3) {
            tips[tipCount] = "Use batch claiming to save gas";
            potentialSavings[tipCount] = (userPoolCount - 1) * 25000; // Estimated savings
            highPriority[tipCount] = true;
            tipCount++;
        }
        
        if (userPoolCount > 20) {
            tips[tipCount] = "Use paginated batch claiming for large portfolios";
            potentialSavings[tipCount] = 100000; // Estimated savings
            highPriority[tipCount] = true;
            tipCount++;
        }
        
        if (userPoolCount > 0) {
            tips[tipCount] = "Claim rewards during low network congestion";
            potentialSavings[tipCount] = 50000; // Estimated savings from timing
            highPriority[tipCount] = false;
            tipCount++;
        }
        
        // Resize arrays to actual count
        assembly {
            mstore(tips, tipCount)
            mstore(potentialSavings, tipCount)
            mstore(highPriority, tipCount)
        }
    }

    /**
     * @dev Preview batch operations before execution
     */
    function previewBatchClaim(address user, address[] calldata targetPools) external view returns (
        bool canExecute,
        uint256 totalRewards,
        uint256 estimatedGas,
        uint256 validPoolCount,
        bool[] memory poolValidity,
        string memory statusMessage
    ) {
        poolValidity = new bool[](targetPools.length);
        totalRewards = 0;
        validPoolCount = 0;
        canExecute = true;
        statusMessage = "Ready to execute";
        
        if (targetPools.length == 0) {
            canExecute = false;
            statusMessage = "No pools specified";
            estimatedGas = 0;
            return (canExecute, totalRewards, estimatedGas, validPoolCount, poolValidity, statusMessage);
        }
        
        if (targetPools.length > 50) {
            canExecute = false;
            statusMessage = "Too many pools (max 50)";
            estimatedGas = 0;
            return (canExecute, totalRewards, estimatedGas, validPoolCount, poolValidity, statusMessage);
        }
        
        uint256 targetPoolsLength = targetPools.length; // Gas optimization: cache array length
        for (uint256 i = 0; i < targetPoolsLength; i++) {
            bool isValid = false;
            
            try ISwapPoolRewards(targetPools[i]).nftCollection() returns (address collection) {
                if (collectionToPool[collection] == targetPools[i]) {
                    isValid = true;
                    try ISwapPoolRewards(targetPools[i]).earned(user) returns (uint256 pending) {
                        if (pending > 0) {
                            totalRewards += pending;
                        }
                    } catch {}
                }
            } catch {}
            
            poolValidity[i] = isValid;
            if (isValid) validPoolCount++;
        }
        
        estimatedGas = 21000 + (validPoolCount * 45000); // Base + per pool estimate
        
        if (validPoolCount == 0) {
            canExecute = false;
            statusMessage = "No valid pools with rewards";
        } else if (totalRewards == 0) {
            statusMessage = "No rewards to claim";
        } else {
            statusMessage = "Ready to claim rewards";
        }
    }

    /**
     * @dev Get real-time factory statistics for live dashboards
     */
    function getLiveFactoryStats() external view returns (
        uint256 totalPools,
        uint256 totalTVL,
        uint256 last24hVolume,
        uint256 totalUniqueUsers,
        uint256 averagePoolAPY,
        uint256 factoryUptime,
        bool systemHealthy
    ) {
        totalPools = allPools.length;
        
        uint256 tvlSum = 0;
        uint256 healthyPools = 0;
        
        for (uint256 i = 0; i < allPools.length; i++) {
            try ISwapPoolRewards(allPools[i]).nftCollection() returns (address collection) {
                if (collectionToPool[collection] == allPools[i]) {
                    try IERC721(collection).balanceOf(allPools[i]) returns (uint256 balance) {
                        tvlSum += balance;
                        if (balance >= 5) healthyPools++;
                    } catch {}
                }
            } catch {}
        }
        
        totalTVL = tvlSum;
        systemHealthy = totalPools > 0 && (healthyPools * 100 / totalPools) >= 50;
        
        // These would need additional tracking in production
        last24hVolume = 0;
        totalUniqueUsers = 0;
        averagePoolAPY = 0;
        factoryUptime = 100; // Placeholder percentage
    }
}
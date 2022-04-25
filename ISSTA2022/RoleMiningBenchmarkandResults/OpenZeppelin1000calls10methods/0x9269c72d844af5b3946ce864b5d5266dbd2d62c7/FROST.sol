// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./EnumerableSet.sol";
import "./Address.sol";
import "./Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IAddressRegistry } from "./IAddressRegistry.sol";
import { UtilitiesBase } from "./UtilitiesBase.sol";

abstract contract AddressBase is UtilitiesBase {
    address internal _addressRegistry;

    function _setAddressRegistry(address _address)
        internal
    {
        _addressRegistry = _address;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { Ownable } from "./Ownable.sol";
import { IAddressRegistry } from "./IAddressRegistry.sol";
import { AddressStorage } from "./AddressStorage.sol";

contract AddressRegistry is IAddressRegistry, Ownable, AddressStorage {
    event AvalancheUpdated(address indexed newAddress);
    event LGEUpdated(address indexed newAddress);
    event LodgeUpdated(address indexed newAddress);
    event LoyaltyUpdated(address indexed newAddress);
    event FrostUpdated(address indexed newAddress);
    event FrostPoolUpdated(address indexed newAddress);
    event SlopesUpdated(address indexed newAddress);
    event SnowPatrolUpdated(address indexed newAddress);
    event TreasuryUpdated(address indexed newAddress);
    event UniswapRouterUpdated(address indexed newAddress);
    event VaultUpdated(address indexed newAddress);
    event WethUpdated(address indexed newAddress);

    bytes32 private constant AVALANCHE_KEY = "AVALANCHE";
    bytes32 private constant LGE_KEY = "LGE";
    bytes32 private constant LODGE_KEY = "LODGE";
    bytes32 private constant LOYALTY_KEY = "LOYALTY";
    bytes32 private constant FROST_KEY = "FROST";
    bytes32 private constant FROST_POOL_KEY = "FROST_POOL";
    bytes32 private constant SLOPES_KEY = "SLOPES";
    bytes32 private constant SNOW_PATROL_KEY = "SNOW_PATROL";
    bytes32 private constant TREASURY_KEY = "TREASURY";
    bytes32 private constant UNISWAP_ROUTER_KEY = "UNISWAP_ROUTER";
    bytes32 private constant WETH_KEY = "WETH";
    bytes32 private constant VAULT_KEY = "VAULT";

    function getAvalanche() public override view returns (address) {
        return getAddress(AVALANCHE_KEY);
    }

    function setAvalanche(address _address) public override onlyOwner {
        _setAddress(AVALANCHE_KEY, _address);
        emit AvalancheUpdated(_address);
    }

    function getLGE() public override view returns (address) {
        return getAddress(LGE_KEY);
    }

    function setLGE(address _address) public override onlyOwner {
        _setAddress(LGE_KEY, _address);
        emit LGEUpdated(_address);
    }

    function getLodge() public override view returns (address) {
        return getAddress(LODGE_KEY);
    }

    function setLodge(address _address) public override onlyOwner {
        _setAddress(LODGE_KEY, _address);
        emit LodgeUpdated(_address);
    }

    function getLoyalty() public override view returns (address) {
        return getAddress(LOYALTY_KEY);
    }

    function setLoyalty(address _address) public override onlyOwner {
        _setAddress(LOYALTY_KEY, _address);
        emit LoyaltyUpdated(_address);
    }

    function getFrost() public override view returns (address) {
        return getAddress(FROST_KEY);
    }

    function setFrost(address _address) public override onlyOwner {
        _setAddress(FROST_KEY, _address);
        emit FrostUpdated(_address);
    }

    function getFrostPool() public override view returns (address) {
        return getAddress(FROST_POOL_KEY);
    }

    function setFrostPool(address _address) public override onlyOwner {
        _setAddress(FROST_POOL_KEY, _address);
        emit FrostPoolUpdated(_address);
    }

    function getSlopes() public override view returns (address) {
        return getAddress(SLOPES_KEY);
    }

    function setSlopes(address _address) public override onlyOwner {
        _setAddress(SLOPES_KEY, _address);
        emit SlopesUpdated(_address);
    }

    function getSnowPatrol() public override view returns (address) {
        return getAddress(SNOW_PATROL_KEY);
    }

    function setSnowPatrol(address _address) public override onlyOwner {
        _setAddress(SNOW_PATROL_KEY, _address);
        emit SnowPatrolUpdated(_address);
    }

    function getTreasury() public override view returns (address payable) {
        address payable _address = address(uint160(getAddress(TREASURY_KEY)));
        return _address;
    }

    function setTreasury(address _address) public override onlyOwner {
        _setAddress(TREASURY_KEY, _address);
        emit TreasuryUpdated(_address);
    }

    function getUniswapRouter() public override view returns (address) {
        return getAddress(UNISWAP_ROUTER_KEY);
    }

    function setUniswapRouter(address _address) public override onlyOwner {
        _setAddress(UNISWAP_ROUTER_KEY, _address);
        emit UniswapRouterUpdated(_address);
    }

    function getVault() public override view returns (address) {
        return getAddress(VAULT_KEY);
    }

    function setVault(address _address) public override onlyOwner {
        _setAddress(VAULT_KEY, _address);
        emit VaultUpdated(_address);
    }

    function getWeth() public override view returns (address) {
        return getAddress(WETH_KEY);
    }

    function setWeth(address _address) public override onlyOwner {
        _setAddress(WETH_KEY, _address);
        emit WethUpdated(_address);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

contract AddressStorage {
    mapping(bytes32 => address) private addresses;

    function getAddress(bytes32 _key) public view returns (address) {
        return addresses[_key];
    }

    function _setAddress(bytes32 _key, address _value) internal {
        addresses[_key] = _value;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IAddressRegistry } from "./IAddressRegistry.sol";
import { ISnowPatrol } from "./ISnowPatrol.sol";
import { AddressBase } from "./AddressBase.sol";

abstract contract AltitudeBase is AddressBase {
    modifier OnlyLGE {
        require(
            _msgSender() == lgeAddress(), 
            "Only the LGE contract can call this function"
        );
        _;
    }

    modifier OnlyLoyalty {
        require(
            _msgSender() == loyaltyAddress(), 
            "Only the Loyalty contract can call this function"
        );
        _;
    }

    modifier OnlyFROST {
        require(
            _msgSender() == frostAddress(),
            "Only FROST Contract can call this function"
        );
        _;
    }

    modifier OnlySlopes {
        require(
            _msgSender() == slopesAddress(), 
            "Only the Slopes contract can call this function"
        );
        _;
    }

    function avalancheAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getAvalanche();
    }

    function lgeAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getLGE();
    }

    function lodgeAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getLodge();
    }

    function loyaltyAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getLoyalty();
    }

    function frostAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getFrost();
    }

    function frostPoolAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getFrostPool();
    }

    function slopesAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getSlopes();
    }

    function snowPatrolAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getSnowPatrol();
    }

    function treasuryAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getTreasury();
    }

    function uniswapRouterAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getUniswapRouter();
    }

    function vaultAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getVault();
    }

    function wethAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getWeth();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from './IERC20.sol';
import { AvalancheBase } from "./AvalancheBase.sol";
import { IAvalanche } from "./IAvalanche.sol";
import { IFROST } from "./IFROST.sol";
import { ILoyalty } from "./ILoyalty.sol";
import { ISlopes } from "./ISlopes.sol";

contract Avalanche is IAvalanche, AvalancheBase {
    event Activated(address indexed user);
    event Distribution(address indexed user, uint256 totalFrostRewards, uint256 payoutPerDay);
    event Claim(address indexed user, uint256 frostAmount);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event FrostRewardAdded(address indexed user, uint256 frostReward);
    event EthRewardAdded(address indexed user, uint256 ethReward);

    uint256 public constant PAYOUT_INTERVAL = 24 hours; // How often the payouts occur
    uint256 public constant TOTAL_PAYOUTS = 20; // How many payouts per distribution cycle
    
    uint256 public nextEpochFrostReward; // accumulated frost for next distribution cycle
    uint256 public epochFrostReward; // current epoch rewards
    uint256 public epochFrostRewardPerDay; // 5% per day, 20 days
    uint256 public unstakingFee; // The unstaking fee that is used to increase locked liquidity and reward Avalanche stakers (1 = 0.1%). Defaults to 10%
    uint256 public buybackAmount; // The amount of FROST-ETH LP tokens kept by the unstaking fee that will be converted to FROST and distributed to stakers (1 = 0.1%). Defaults to 50%

    bool public override active; // Becomes true once the 'activate' function called

    uint256 public startTime; // When the first payout can be processed (timestamp). It will be 24 hours after the Avalanche contract is activated
    uint256 public lastPayout; // When the last payout was processed (timestamp)
    uint256 public lastReward; // timestamp when last frost reward was minted
    uint256 public totalPendingFrost; // The total amount of pending FROST available for stakers to claim
    uint256 public accFrostPerShare; // Accumulated FROST per share, times 1e12.
    uint256 public totalStaked; // The total amount of FROST-ETH LP tokens staked in the contract
    uint256 public totalShares; // The total amount of pool shares
    uint256 public weight; // pool weight 

    modifier AvalancheActive {
        require(active, "Avalanche is not active");
        _;
    }

    modifier SlopesActive {
        require(ISlopes(slopesAddress()).active(), "Slopes are not active");
        _;
    }

    constructor(address addressRegistry) 
        public 
        AvalancheBase(addressRegistry)
    {
        unstakingFee = 100;
        buybackAmount = 500;
        weight = 5;
    }

    // activate the avalanche distribution phase
    //  signified avalanche is open on first call and calcs
    //  all necessary rewards vars
    function activate() 
        external
        override
        OnlyFROST
    {
        if (!active) {
            active = true;
        }

        // The first payout can be processed 24 hours after activation
        startTime = block.timestamp + getDistributionPayoutInterval(); 
        lastPayout = startTime;
        epochFrostReward = nextEpochFrostReward;
        epochFrostRewardPerDay = epochFrostReward.div(getTotalDistributionPayouts());
        nextEpochFrostReward = 0;
    }

    // The _transfer function in the FROST contract calls this to let the Avalanche contract know that it received the specified amount of FROST to be distributed 
    function addFrostReward(address _from, uint256 _amount) 
        external
        override
        // NonZeroAmount(_amount)
        SlopesActive
        OnlyFROST
    {
        // if max supply is hit, distribute directly to pool
        // else always add reward to next epoch rewards.
        if (IFROST(frostAddress()).maxSupplyHit()) {
            totalPendingFrost = totalPendingFrost.add(_amount);
            accFrostPerShare = accFrostPerShare.add(_amount.mul(1e12).div(totalShares));
        } else {
            nextEpochFrostReward = nextEpochFrostReward.add(_amount);
        }

        emit FrostRewardAdded(_from, _amount);
    }

    receive() external payable {
        addEthReward();
    }

    // Allows external sources to add ETH to the contract which is used to buy and then distribute FROST to stakers
    function addEthReward() 
        public 
        payable
        SlopesActive
    {
        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, "Must have eth to swap");
        _swapExactETHForTokens(address(this).balance, frostAddress());

        // The _transfer function in the FROST contract calls the Avalanche contract's updateOwdrReward function 
        // so we don't need to update the balances after buying the PWRD token
        emit EthRewardAdded(msg.sender, msg.value);
    }

    function _updatePool() 
        internal 
        AvalancheActive
    {
        if (IFROST(frostAddress()).accumulating()) {
            _processAccumulationPayouts();
        } else {
            _processDistributionPayouts();
        }
    }

    // handles updating the pool during accumulation phases
    function _processAccumulationPayouts() internal {
        if (block.timestamp <= lastReward) {
            return;
        }

        if (totalStaked == 0) {
            lastReward = block.timestamp;
            return;
        }

        // Calculate the current FROST rewards for a specific pool
        //  using fixed APR formula and Uniswap price
        uint256 tokenPrice = _getLpTokenPrice(frostPoolAddress());
        uint256 frostReward = _calculatePendingRewards(
            lastReward,
            totalShares,
            tokenPrice,
            weight
        );

        // if we hit the max supply here, ensure no overflow 
        //  epoch will be incremented from the token
        address frostAddress = frostAddress();
        uint256 frostTotalSupply = IERC20(frostAddress).totalSupply();
        if (frostTotalSupply.add(frostReward) >= IFROST(frostAddress).currentMaxSupply()) {
            frostReward = IFROST(frostAddress).currentMaxSupply().sub(frostTotalSupply);
        }

        if (frostReward > 0) {
            IFROST(frostAddress).mint(address(this), frostReward);
            accFrostPerShare = accFrostPerShare.add(frostReward.mul(1e12).div(totalShares));
            lastReward = block.timestamp;
        }
    }

    // Handles paying out the fixed distribution payouts over 20 days
    // rewards directly added to accFrostPerShare at max supply hit, becomes a direct calculation
    function _processDistributionPayouts() internal {
        if (!active || block.timestamp < startTime 
            || block.timestamp <= lastReward
            || IFROST(frostAddress()).maxSupplyHit() 
            || epochFrostReward == 0 || totalStaked == 0) 
        {
            return;
        }

        // How many days since last payout?
        uint256 daysSinceLastPayout = (block.timestamp - lastPayout) / getDistributionPayoutInterval();

        // If less than 1, don't do anything
        if (daysSinceLastPayout == 0) {
            return;
        }

        // Work out how many payouts have been missed
        uint256 payoutNumber = payoutNumber();
        uint256 previousPayoutNumber = payoutNumber - daysSinceLastPayout;

        // Calculate how much additional reward we have to hand out
        uint256 frostReward = rewardAtPayout(payoutNumber) - rewardAtPayout(previousPayoutNumber);
        if (frostReward > epochFrostReward) {
            frostReward = epochFrostReward;
        }
        epochFrostReward = epochFrostReward.sub(frostReward);

        // Payout the frostReward to the stakers
        totalPendingFrost = totalPendingFrost.add(frostReward);
        accFrostPerShare = accFrostPerShare.add(frostReward.mul(1e12).div(totalShares));

        // Update lastPayout time
        lastPayout += (daysSinceLastPayout * getDistributionPayoutInterval());
        lastReward = block.timestamp;

        if (payoutNumber >= getTotalDistributionPayouts()) {
            IFROST(frostAddress()).updateEpoch(IFROST(frostAddress()).currentEpoch() + 1, 0);
        }
    }

    // Claim earned FROST
    function claim()
        external
        override
    {        
        _updatePool();
        _claim(msg.sender);
    }

    function claimFor(address _user)
        external
        override
        OnlyLoyalty
    {
        _updatePool();
        _claim(_user);
    }

    function _claim(address _user)
        internal
        AvalancheActive
    {
        UserInfo storage user = userInfo[_user];
        if (user.staked > 0) {
            uint256 pendingFrostReward = user.shares.mul(accFrostPerShare).div(1e12).sub(user.rewardDebt);
            if (pendingFrostReward > 0) {
                totalPendingFrost = totalPendingFrost.sub(pendingFrostReward);
                user.claimed += pendingFrostReward;
                user.rewardDebt = user.shares.mul(accFrostPerShare).div(1e12);

                // update user/pool shares
                uint256 shares = ILoyalty(loyaltyAddress()).getTotalShares(_user, user.staked);
                if (shares > user.shares) {
                    totalShares = totalShares.add(shares.sub(user.shares));
                } else if (shares < user.shares) {
                    totalShares = totalShares.sub(user.shares.sub(shares));
                }
                user.shares = shares;

                _safeTokenTransfer(
                    frostAddress(),
                    _user,
                    pendingFrostReward
                );

                emit Claim(_user, pendingFrostReward);
            }
        }
    }

     // Stake FROST-ETH LP tokens
    function deposit(uint256 _amount) 
        external
        override
    {
        _deposit(msg.sender, msg.sender, _amount);
    }

    // stake for another user, used to migrate to this pool
    function depositFor(address _from, address _user, uint256 _amount)
        external
        override
        OnlySlopes
    {
        _deposit(_from, _user, _amount);
    }

    // Stake FROST-ETH LP tokens for address
    function _deposit(address _from, address _user, uint256 _amount) 
        internal 
        AvalancheActive
        NonZeroAmount(_amount)
    {
        IERC20(frostPoolAddress()).safeTransferFrom(_from, address(this), _amount);

        _updatePool();

        _claim(_user);


        UserInfo storage user = userInfo[_user];

        uint256 shares = ILoyalty(loyaltyAddress()).getTotalShares(_user, _amount);
        totalShares = totalShares.add(shares);
        user.shares = user.shares.add(shares);

        totalStaked = totalStaked.add(_amount);
        user.staked = user.staked.add(_amount);
        user.rewardDebt = user.shares.mul(accFrostPerShare).div(1e12);

        emit Deposit(_user, _amount);
    }

    // Unstake and withdraw FROST-ETH LP tokens and any pending FROST rewards. 
    // There is a 10% unstaking fee, meaning the user will only receive 90% of their LP tokens back.
    
    // For the LP tokens kept by the unstaking fee, a % will get locked forever in the FROST contract, and the rest will get converted to FROST and distributed to stakers.
    //TODO -> change ratio to 75% convertion to rewards
    function withdraw(uint256 _amount)
        external
        override
    {
        _withdraw(_msgSender(), _amount);
    }

    function _withdraw(address _user, uint256 _amount) 
        internal
        AvalancheActive
        NonZeroAmount(_amount)
        HasStakedBalance(_user)
        HasWithdrawableBalance(_user, _amount)
    {
        _updatePool();

        UserInfo storage user = userInfo[_user];
        
        uint256 unstakingFeeAmount = _amount.mul(unstakingFee).div(1000);
        uint256 remainingUserAmount = _amount.sub(unstakingFeeAmount);

        // Some of the LP tokens kept by the unstaking fee will be locked forever in the FROST contract, 
        // the rest  will be converted to FROST and distributed to stakers
        uint256 lpTokensToConvertToFrost = unstakingFeeAmount.mul(buybackAmount).div(1000);
        uint256 lpTokensToLock = unstakingFeeAmount.sub(lpTokensToConvertToFrost);

        // Remove the liquidity from the Uniswap FROST-ETH pool and buy FROST with the ETH received
        // The _transfer function in the FROST.sol contract automatically calls avalanche.addFrostRewards()
        if (lpTokensToConvertToFrost > 0) {
            _removeLiquidityETH(
                lpTokensToConvertToFrost,
                frostPoolAddress(),
                frostAddress()
            );
            addEthReward();
        }

        // Permanently lock the LP tokens in the FROST contract
        if (lpTokensToLock > 0) {
            IERC20(frostPoolAddress()).safeTransfer(vaultAddress(), lpTokensToLock);
        }

        // Claim any pending FROST
        _claim(_user);

        uint256 shares = ILoyalty(loyaltyAddress()).getTotalShares(_user, _amount);
        totalShares = totalShares.sub(shares);
        user.shares = user.shares.sub(shares);

        totalStaked = totalStaked.sub(_amount);
        user.staked = user.staked.sub(_amount);
        user.rewardDebt = user.shares.mul(accFrostPerShare).div(1e12); // update reward debt after balance change

        IERC20(frostPoolAddress()).safeTransfer(_user, remainingUserAmount);
        emit Withdraw(_user, remainingUserAmount);
    }

    function payoutNumber() 
        public
        override
        view 
        returns (uint256) 
    {
        if (block.timestamp < startTime) {
            return 0;
        }

        return (block.timestamp - startTime).div(getDistributionPayoutInterval());
    }

    function timeUntilNextPayout()
        external
        override
        view 
        returns (uint256) 
    {
        if (epochFrostReward == 0) {
            return 0;
        } else {
            uint256 payout = payoutNumber();
            uint256 nextPayout = startTime.add((payout + 1).mul(getDistributionPayoutInterval()));
            return nextPayout - block.timestamp;
        }
    }

    function rewardAtPayout(uint256 _payoutNumber) 
        public
        override
        view 
        returns (uint256) 
    {
        if (_payoutNumber == 0) {
            return 0;
        } else {
            return epochFrostRewardPerDay * _payoutNumber;
        }
    }

    function getTotalDistributionPayouts() public virtual pure returns (uint256) {
        return TOTAL_PAYOUTS;
    }

    function getDistributionPayoutInterval() public virtual pure returns (uint256) {
        return PAYOUT_INTERVAL;
    }

    function updatePool()
        external
        HasPatrol("ADMIN")
    {
        _updatePool();
    }

    // Sets the unstaking fee. Can't be higher than 50%.
    // _convertToFrostAmount is the % of the LP tokens from the unstaking fee that will be converted to FROST and distributed to stakers.
    // unstakingFee - unstakingFeeConvertToFrostAmount = The % of the LP tokens from the unstaking fee that will be permanently locked in the FROST contract
    function setUnstakingFee(uint256 _unstakingFee, uint256 _buybackAmount) 
        external
        //override
        HasPatrol("ADMIN") 
    {
        require(_unstakingFee <= 500, "over 50%");
        require(_buybackAmount <= 1000, "bad amount");
        unstakingFee = _unstakingFee;
        buybackAmount = _buybackAmount;
    }

    // Function to recover ERC20 tokens accidentally sent to the contract.
    // FROST and FROST-ETH LP tokens (the only 2 ERC2O's that should be in this contract) can't be withdrawn this way.
    function recoverERC20(address _tokenAddress) 
        external
        //override
        HasPatrol("ADMIN") 
    {
        require(_tokenAddress != frostAddress() && _tokenAddress != frostPoolAddress());
        IERC20 token = IERC20(_tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, tokenBalance);
    }

     function getAvalancheStats(address _user) 
        external 
        view 
        returns (bool _active, bool _accumulating, uint256[20] memory _stats)
    {
        _active = active;
        _accumulating = IFROST(frostAddress()).accumulating();
        
        UserInfo storage user = userInfo[_user];

        _stats[0] = weight * IFROST(frostAddress()).currentBaseRate();
        _stats[1] = lastReward;
        _stats[2] = totalStaked;
        _stats[3] = totalShares;
        _stats[4] = accFrostPerShare;
        _stats[5] = _getTokenPrice(frostAddress(), frostPoolAddress());
        _stats[6] = _getLpTokenPrice(frostPoolAddress());

        _stats[7] = nextEpochFrostReward;
        _stats[8] = epochFrostReward;
        _stats[9] = epochFrostRewardPerDay;
        _stats[10] = startTime;
        _stats[11] = lastPayout; 
        _stats[12] = payoutNumber();
        _stats[13] = unstakingFee;

        _stats[14] = IERC20(frostPoolAddress()).balanceOf(_user);
        _stats[15] = IERC20(frostPoolAddress()).allowance(_user, address(this));
        _stats[16] = user.staked;
        _stats[17] = user.shares;
        _stats[18] = user.shares.mul(accFrostPerShare).div(1e12).sub(user.rewardDebt); // pending rewards
        _stats[19] = user.claimed;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { LiquidityPoolBase } from "./LiquidityPoolBase.sol";

import { IERC20 } from './IERC20.sol';
import { SafeERC20 } from './SafeERC20.sol';
import { SafeMath } from './SafeMath.sol';

abstract contract AvalancheBase is LiquidityPoolBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor(address addressRegistry) internal {
        _setAddressRegistry(addressRegistry);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.8.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logByte(byte p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(byte)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC1155.sol";
import "./IERC1155MetadataURI.sol";
import "./IERC1155Receiver.sol";
import "./Context.sol";
import "./ERC165.sol";
import "./SafeMath.sol";
import "./Address.sol";

/**
 *
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using SafeMath for uint256;
    using Address for address;

    // Mapping from token ID to account balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /*
     *     bytes4(keccak256('balanceOf(address,uint256)')) == 0x00fdd58e
     *     bytes4(keccak256('balanceOfBatch(address[],uint256[])')) == 0x4e1273f4
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,uint256,bytes)')) == 0xf242432a
     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)')) == 0x2eb2c2d6
     *
     *     => 0x00fdd58e ^ 0x4e1273f4 ^ 0xa22cb465 ^
     *        0xe985e9c5 ^ 0xf242432a ^ 0x2eb2c2d6 == 0xd9b67a26
     */
    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    /*
     *     bytes4(keccak256('uri(uint256)')) == 0x0e89341c
     */
    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    /**
     * @dev See {_setURI}.
     */
    constructor (string memory uri_) public {
        _setURI(uri_);

        // register the supported interfaces to conform to ERC1155 via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155);

        // register the supported interfaces to conform to ERC1155MetadataURI via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) external view override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(accounts[i] != address(0), "ERC1155: batch balance query for the zero address");
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal virtual
    { }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IUniswapV2Factory } from './IUniswapV2Factory.sol';
import { IUniswapV2Router02 } from './IUniswapV2Router02.sol';
import { IFROST } from "./IFROST.sol";
import { IAvalanche } from './IAvalanche.sol';
import { FROSTBase } from "./FROSTBase.sol";

contract FROST is IFROST, FROSTBase {
    event EpochUpdated(address _address, uint256 _epoch, uint256 _phase);

    uint256 public override constant MAX_SUPPLY = 21000 * 1e18; // max supply 21k

    bool public override maxSupplyHit; // has max supply been reached
    uint256 public override transferFee; // FROST transfer fee, 1 = 0.1%. Default 1.5%

    uint256 public override currentEpoch;
    uint256 public override currentPhase; // current phase; 0 = Accumulation ,1 = Distribution
    uint256[] public override epochMaxSupply; // max total supply for each epoch, running total
    uint256[] public override epochBaseRate; // base APR of Slope rewards
    
    // Mapping of whitelisted sender and recipient addresses that don't pay the transfer fee. 
    // Allows FROST token holders to whitelist future contracts
    mapping(address => bool) public senderWhitelist;
    mapping(address => bool) public recipientWhitelist;

    modifier Accumulation {
        require(
            currentPhase == 0,
            "FROST is not in Accumulation"
        );
        _;
    }
    
    modifier MaxSupplyNotReached {
        require(!maxSupplyHit, "Max FROST Supply has been reached");
        _;
    }

    modifier OnlyAuthorized {
        require(
            msg.sender == avalancheAddress()
            || msg.sender == lgeAddress()
            || msg.sender == slopesAddress(),
            "Only LGE, Slopes, and Avalanche contracts can call this function"
        );
        _;
    }

    constructor(address addressRegistry) 
        public 
        FROSTBase(addressRegistry, "Frost Protocol", "FROST") 
    {
        transferFee = 15;
        _initializeEpochs();
    }

    function _initializeEpochs() 
        private 
    {
        _setupEpoch(5250 * 1e18, 0); // 5.25k FROST for LGE
        _setupEpoch(13250 * 1e18, 800); // +8k FROST, 800%
        _setupEpoch(17250 * 1e18, 400); // +4k FROST, 400%
        _setupEpoch(19250 * 1e18, 200); // +2k FROST, 200%
        _setupEpoch(20250 * 1e18, 100); // +1k FROST, 100%
        _setupEpoch(20750 * 1e18, 50); // +500 FROST, 50%
        _setupEpoch(21000 * 1e18, 25); // +250 FROST, 25%
    }

    function _setupEpoch(uint256 maxSupply, uint256 baseRate) 
        private 
    {
        epochMaxSupply.push(maxSupply);
        epochBaseRate.push(baseRate);
    }

    function currentMaxSupply() 
        external 
        view
        override 
        returns (uint256)
    {
        return epochMaxSupply[currentEpoch];
    }

    function currentBaseRate() 
        external 
        view 
        override
        returns (uint256)
    {
        return epochBaseRate[currentEpoch];
    }

    function accumulating()
        external
        view
        override
        returns (bool)
    {
        return currentEpoch > 0 && currentEpoch <= 6
            && currentPhase == 0;
    }

    function updateEpoch(uint256 _epoch, uint256 _phase)
        external
        override
        OnlyAuthorized
    {
        // require valid update calls
        if (currentPhase == 0) {
            require(
                _epoch == currentEpoch && _phase == 1,
                "Invalid Epoch Phase Update Call"
            );
        } else {
            // change this to _epoch == currentEpoch + 1 in prod
            require(
                _epoch > currentEpoch && _phase == 0,
                "Invalid Epoch Update Call"
            );
        }

        currentEpoch = _epoch;
        currentPhase = _phase;

        emit EpochUpdated(_msgSender(), _epoch, _phase);
    }

    // Creates `_amount` FROST token to `_to`. 
    // Can only be called by the LGE, Slopes, and Avalanche contracts
    //  when epoch and max supply numbers allow
    function mint(address _to, uint256 _amount)
        external
        override
        Accumulation
        MaxSupplyNotReached
        OnlyAuthorized
    {
        uint256 supply = totalSupply();
        uint256 epochSupply = epochMaxSupply[currentEpoch];

        // update phase if epoch max supply is hit during this mint
        if (supply.add(_amount) >= epochSupply) {
            _amount = epochSupply.sub(supply);
            
            if (supply.add(_amount) >= MAX_SUPPLY) {
                maxSupplyHit = true;
            }

            // activate gets called at every accumulation end to reset rewards
            IAvalanche(avalancheAddress()).activate();            

            if (currentEpoch == 0) {
                currentEpoch += 1;
            } else {
                currentPhase += 1;
            }
            emit EpochUpdated(_msgSender(), currentEpoch, currentPhase);
        }

        if (_amount > 0) {
            _mint(_to, _amount);
        }
    }

    // Transfer override to support transfer fees that are sent to Avalanche
    function _transfer(
        address sender, 
        address recipient, 
        uint256 amount
    ) 
        internal
        override
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 transferFeeAmount;
        uint256 tokensToTransfer;
        if (amount > 0) {
            address avalancheAddress = avalancheAddress();

            // Send a fee to the Avalanche staking contract if this isn't a whitelisted transfer
            if (_isWhitelistedTransfer(sender, recipient) != true) {
                transferFeeAmount = amount.mul(transferFee).div(1000);
                _balances[avalancheAddress] = _balances[avalancheAddress].add(transferFeeAmount);
                IAvalanche(avalancheAddress).addFrostReward(sender, transferFeeAmount);
                emit Transfer(sender, avalancheAddress, transferFeeAmount);
            }
            tokensToTransfer = amount.sub(transferFeeAmount);
            _balances[sender] = _balances[sender].sub(tokensToTransfer, "ERC20: transfer amount exceeds balance");

            if (tokensToTransfer > 0) {
                _balances[recipient] = _balances[recipient].add(tokensToTransfer);

                // If the Avalanche is the transfer recipient, add rewards to keep balances updated
                if (recipient == avalancheAddress) {
                    IAvalanche(avalancheAddress).addFrostReward(sender, tokensToTransfer);
                }
            }

        }
        emit Transfer(sender, recipient, tokensToTransfer);
    }

    // Admin calls this at token deployment to setup FROST-LP LGE transfers
    function calculateUniswapPoolAddress() 
        external
        view 
        HasPatrol("ADMIN")
        returns (address)
    {
        address uniswapRouter = uniswapRouterAddress();
        address wethAddress = wethAddress();

        // Calculate the address the FROST-ETH Uniswap pool will exist at
        address factoryAddress = IUniswapV2Router02(uniswapRouter).factory();
        // return IUniswapV2Factory(factoryAddress).createPair(wethAddress, address(this));

        // token0 must be strictly less than token1 by sort order to determine the correct address
        (address token0, address token1) = address(this) < wethAddress 
            ? (address(this), wethAddress) 
            : (wethAddress, address(this));

        //uniswap address pre-calculation using create2
        return address(uint(keccak256(abi.encodePacked(
            hex'ff',
            factoryAddress,
            keccak256(abi.encodePacked(token0, token1)),
            hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'
        ))));
    }

    // Sets the FROST transfer fee that gets rewarded to Avalanche stakers. Can't be higher than 5%.
    function setTransferFee(uint256 _transferFee) 
        public
        override
        HasPatrol("ADMIN")
    {
        require(_transferFee <= 50, "over 5%");
        transferFee = _transferFee;
    }

    // Add an address to the sender or recipient transfer whitelist
    function addToTransferWhitelist(bool _addToSenderWhitelist, address _address) 
        public
        override 
        HasPatrol("ADMIN") 
    {
        if (_addToSenderWhitelist == true) {
            senderWhitelist[_address] = true;
        } else {
            recipientWhitelist[_address] = true;
        }
    }

    // Remove an address from the sender or recipient transfer whitelist
    function removeFromTransferWhitelist(bool _removeFromSenderWhitelist, address _address) 
        public
        override
        HasPatrol("ADMIN") 
    {
        if (_removeFromSenderWhitelist == true) {
            senderWhitelist[_address] = false;
        } else  {
            recipientWhitelist[_address] = false;
        }
    }

    // Internal function to determine if a FROST transfer is being sent or received by a whitelisted address
    function _isWhitelistedTransfer(
        address _sender, 
        address _recipient
    ) 
        internal 
        view 
        returns (bool) 
    {
        // Ecosytem contracts should not pay transfer fees
        return _sender == avalancheAddress() || _recipient == avalancheAddress()
            || _sender == lgeAddress() || _recipient == lgeAddress()
            || _sender == slopesAddress() || _recipient == slopesAddress()
            || senderWhitelist[_sender] == true || recipientWhitelist[_recipient] == true;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

// import { ERC20 } from "../utils/ERC20/ERC20.sol";

import { FROSTToken } from "./FROSTToken.sol";
import { PatrolBase } from "./PatrolBase.sol";

abstract contract FROSTBase is PatrolBase, FROSTToken {
    constructor(
        address addressRegistry,
        string memory name_, 
        string memory symbol_
    ) 
        public
        FROSTToken(name_, symbol_)
    {
        _setAddressRegistry(addressRegistry);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

// import { ERC20 } from "../utils/ERC20/ERC20.sol";
import { SafeMath } from "./SafeMath.sol";
import { IERC20 } from './IERC20.sol';
import { Context } from "./Context.sol";

// Standed ERC20 with internal _balances, virtual _transfer, and add'l helper funcs
// Modificiations made out of ecosystem necessity  
abstract contract FROSTToken is IERC20, Context {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual;

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IAddressRegistry {
    event AvalancheUpdated(address indexed newAddress);
    event LGEUpdated(address indexed newAddress);
    event LodgeUpdated(address indexed newAddress);
    event LoyaltyUpdated(address indexed newAddress);
    event FrostUpdated(address indexed newAddress);
    event FrostPoolUpdated(address indexed newAddress);
    event SlopesUpdated(address indexed newAddress);
    event SnowPatrolUpdated(address indexed newAddress);
    event TreasuryUpdated(address indexed newAddress);
    event UniswapRouterUpdated(address indexed newAddress);
    event VaultUpdated(address indexed newAddress);
    event WethUpdated(address indexed newAddress);
    
    function getAvalanche() external view returns (address);
    function setAvalanche(address _address) external;

    function getLGE() external view returns (address);
    function setLGE(address _address) external;

    function getLodge() external view returns (address);
    function setLodge(address _address) external;

    function getLoyalty() external view returns (address);
    function setLoyalty(address _address) external;

    function getFrost() external view returns (address);
    function setFrost(address _address) external;

    function getFrostPool() external view returns (address);
    function setFrostPool(address _address) external;

    function getSlopes() external view returns (address);
    function setSlopes(address _address) external;

    function getSnowPatrol() external view returns (address);
    function setSnowPatrol(address _address) external;

    function getTreasury() external view returns (address payable);
    function setTreasury(address _address) external;

    function getUniswapRouter() external view returns (address);
    function setUniswapRouter(address _address) external;

    function getVault() external view returns (address);
    function setVault(address _address) external;

    function getWeth() external view returns (address);
    function setWeth(address _address) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IAvalanche {
    event Activated(address indexed user);
    event Claim(address indexed user, uint256 frostAmount);    
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event FrostRewardAdded(address indexed user, uint256 frostReward);
    event EthRewardAdded(address indexed user, uint256 ethReward);

    function active() external view returns (bool);
    function activate() external;

    function addFrostReward(address _from, uint256 _amount) external;
    // function addEthReward() external virtual payable;
    function deposit(uint256 _amount) external;
    function depositFor(address _from, address _user, uint256 _amount) external;
    function claim() external;
    function claimFor(address _user) external;
    function withdraw(uint256 _amount) external;

    function payoutNumber() external view returns (uint256);
    function timeUntilNextPayout() external view returns (uint256); 
    function rewardAtPayout(uint256 _payoutNumber) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165.sol";

/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IFlashLoanReceiver {
    function executeOperation(
        address _token, 
        uint256 _amount, 
        uint256 _fee, 
        bytes memory _params
    ) external;

    // function executeOperation(
    //     address[] calldata _reserves,
    //     uint256[] calldata _amounts,
    //     uint256[] calldata _fees,
    //     bytes calldata params
    // ) external returns (bool);
}
pragma solidity ^0.6.12;

interface IFROST {
    event EpochUpdated(address _address, uint256 _epoch, uint256 _phase);

    function MAX_SUPPLY() external view returns (uint256);
    function maxSupplyHit() external view returns (bool);
    function transferFee() external view returns (uint256);
    function currentEpoch() external view returns (uint256);
    function currentPhase() external view returns (uint256);
    function epochMaxSupply(uint _epoch) external view returns (uint256);
    function epochBaseRate(uint _epoch) external view returns (uint256);

    function accumulating() external view returns (bool);
    function currentMaxSupply() external view returns (uint256);
    function currentBaseRate() external view returns (uint256);
    // function incrementEpoch() external;
    // function incrementPhase() external;
    
    function updateEpoch(uint256 _epoch, uint256 _phase) external;
    function mint(address _to, uint256 _amount) external;
    function setTransferFee(uint256 _transferFee) external;
    function addToTransferWhitelist(bool _addToSenderWhitelist, address _address) external;
    function removeFromTransferWhitelist(bool _removeFromSenderWhitelist, address _address) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface ILendingPool {
    event FlashLoanCompleted(
        address indexed _user,
        address indexed _receiver,
        address indexed _token,
        uint256 _amount,
        uint256 _totalFee
    );
    function flashLoan(
        address _receiver, 
        address _token, 
        uint256 _amount, 
        bytes memory _params
    ) external;

    function getReservesAvailable(address _token) external view returns (uint256);
    function getFeeForAmount(address _token, uint256 _amount) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;


interface ILGE {
    event LiquidityEventStarted(address _address);
    event LiquidityCapReached(address _address);
    event LiquidityEventCompleted(address _address, uint256 totalContributors, uint256 totalContributed);
    event UserContributed(address indexed _address, uint256 _amount);
    event UserClaimed(address indexed _address, uint256 _amount);

    function active() external view returns (bool);
    function eventStartTimestamp() external view returns (uint256);
    function eventEndTimestamp() external view returns (uint256);
    function totalContributors() external view returns (uint256);
    function totalEthContributed() external view returns (uint256);
    function tokenDistributionRate() external view returns (uint256);
    function goldBoardsReserved() external view returns (uint256);
    function silverBoardsReserved() external view returns (uint256);

    function activate() external;
    function contribute() external payable;
    function startEvent() external;
    function claim() external;
    function retrieveLeftovers() external;

    function getContribution(address _address) external view returns (uint256 amount, uint256 board);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface ILodge {
    event TokenCreated(address user, uint256 id, uint256 supply);

    function items(uint256 _token) external view returns(uint256);
    function boost(uint256 _id) external view returns (uint256);

    function setURI(string memory _newuri) external;
    function mint(address _account, uint256 _id, uint256 _amount, uint256 _boost) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface ILoyalty {
    event TrancheUpdated(uint256 _tranche, uint256 _points);
    event LoyaltyUpdated(address indexed _user, uint256 _tranche, uint256 _points);
    event BaseFeeUpdated(address indexed _user, uint256 _baseFee);
    event ProtocolFeeUpdated(address indexed _user, uint256 _protocolFee);
    event DiscountMultiplierUpdated(address indexed _user, uint256 _multiplier);
    event Deposit(address indexed _user, uint256 _id, uint256 _amount);
    event Withdraw(address indexed _user, uint256 _id, uint256 _amount);
    
    function staked(uint256 _id, address _address) external view returns (uint256);
    function whitelistedTokens(uint256 _id) external view returns (bool);

    function getTotalShares(address _user, uint256 _amount) external view returns (uint256);
    function getTotalFee(address _user, uint256 _amount) external view returns (uint256);
    function getProtocolFee(uint256 _amount) external view returns (uint256);
    function getBoost(address _user) external view returns (uint256);
    function deposit(uint256 _id, uint256 _amount) external;
    function withdraw(uint256 _id, uint256 _amount) external;
    function whitelistToken(uint256 _id) external;
    function blacklistToken(uint256 _id) external;
    function updatePoints(address _user) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface ISlopes {
    event Activated(address user);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 frostAmount, uint256 tokenAmount);
    event ClaimAll(address indexed user, uint256 frostAmount, uint256[] tokenAmounts);
    event Migrate(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    // event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event FrostPurchase(address indexed user, uint256 ethSpentOnFrost, uint256 frostBought);

    function active() external view returns (bool);
    function frostSentToAvalanche() external view returns (uint256);
    function stakingFee() external view returns (uint256);
    function roundRobinFee() external view returns (uint256);
    function protocolFee() external view returns (uint256);

    function activate() external;
    function massUpdatePools() external;
    function updatePool(uint256 _pid) external;
    // function addFrostReward(address _from, uint256 _amount) external virtual;
    // function addEthReward() external virtual payable;
    function claim(uint256 _pid) external;
    function claimAll() external;
    function claimAllFor(address _user) external;
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function migrate() external;
    function poolLength() external view returns (uint256);
    function addPool(address _token, address _lpToken, bool _lpStaked, uint256 _weight) external;
    function setWeight(uint256 _pid, uint256 _weight) external;
}

// interface ISlopes {
    

//     function activate() external;
//     function poolLength() external view returns (uint256);
//     function massUpdatePools() external;
//     function updatePool(uint256 _pid) external;
//     function deposit(uint256 _pid, uint256 _amount) external;
// }
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { AltitudeBase } from "./AltitudeBase.sol";

interface ISnowPatrol {
    function ADMIN_ROLE() external pure returns (bytes32);
    function LGE_ROLE() external pure returns (bytes32);
    function FROST_ROLE() external pure returns (bytes32);
    function SLOPES_ROLE() external pure returns (bytes32);
    function LODGE_ROLE() external pure returns (bytes32);
    function setCoreRoles() external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IWETH {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);
    function deposit() external payable;
    function withdraw(uint wad) external;
    function totalSupply() external view returns (uint);
    function approve(address guy, uint wad) external returns (bool);
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "./IERC20.sol";
import { SafeERC20 } from "./SafeERC20.sol";
import { SafeMath } from "./SafeMath.sol";
import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { IFlashLoanReceiver } from "./IFlashLoanReceiver.sol";
import { ILoyalty } from "./ILoyalty.sol";
import { ILendingPool } from "./ILendingPool.sol";
import { MultiPoolBase } from "./MultiPoolBase.sol";

contract LendingPoolBase is ILendingPool, MultiPoolBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    mapping (address => bool) lendingTokens; // Tokens active for borrowing

    event FlashLoan(
        address indexed _receiver,
        address indexed _token,
        uint256 _amount,
        uint256 _totalFee
    );

    modifier LendingActive(address _token) {
        require(lendingTokens[_token] == true, "Flash Loans for this token are not active");
        _;
    }

    function flashLoan(
        address _receiver,
        address _token,
        uint256 _amount,
        bytes memory _params
    )
        public
        override
        nonReentrant
        LendingActive(_token)
        NonZeroAmount(_amount)
    {
        uint256 tokensAvailableBefore = _getReservesAvailable(_token);
        require(
            tokensAvailableBefore >= _amount,
            "Not enough token available to complete transaction"
        );

        uint256 totalFee = ILoyalty(loyaltyAddress()).getTotalFee(tx.origin, _amount);
        
        require(
            totalFee > 0, 
            "Amount too small for flash loan"
        );

        IFlashLoanReceiver receiver = IFlashLoanReceiver(_receiver);
        address payable userPayable = address(uint160(_receiver));

        // transfer flash loan funds to user
        IERC20(_token).safeTransfer(userPayable, _amount);
        
        // execute arbitrary user code
        receiver.executeOperation(_token, _amount, totalFee, _params);

        // Ensure token balances are equal + fees immediately after transfer.
        //  Since ETH reverts transactions that fail checks like below, we can
        //  ensure that funds are returned to the contract before end of transaction
        uint256 tokensAvailableAfter = _getReservesAvailable(_token);
        require(
            tokensAvailableAfter == tokensAvailableBefore.add(totalFee),
            "Token balances are inconsistent. Transaction reverted"
        );

        poolInfo[tokenPools[_token]].accTokenPerShare = poolInfo[tokenPools[_token]]
            .accTokenPerShare.mul(totalFee.mul(1e12).div(poolInfo[tokenPools[_token]].totalStaked));
        ILoyalty(loyaltyAddress()).updatePoints(tx.origin);

        emit FlashLoan(_receiver, _token, _amount, totalFee);
    }

    function getReservesAvailable(address _token)
        external
        override
        view
        returns (uint256)
    {
        if (!lendingTokens[_token]) {
            return 0;
        }
        return _getReservesAvailable(_token);
    }

    function _getReservesAvailable(address _token)
        internal
        view
        returns (uint256)
    {
        return IERC20(_token).balanceOf(address(this));
    }

    function getFeeForAmount(address _token, uint256 _amount)
        external
        override
        view
        returns (uint256)
    {
        if (!lendingTokens[_token]) {
            return 0;
        }
        return ILoyalty(loyaltyAddress()).getTotalFee(tx.origin, _amount);
    }

    function setLendingToken(address _token, bool _active)
        external
        HasPatrol("ADMIN")
    {
        _setLendingToken(_token, _active);
    }

    function _setLendingToken(address _token, bool _active)
        internal
    {
        lendingTokens[_token] = _active;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "./IERC20.sol";
import { IERC1155 } from "./IERC1155.sol";
import { IERC1155Receiver } from "./IERC1155Receiver.sol";
import { IUniswapV2Router02 } from './IUniswapV2Router02.sol';
import { ILGE } from "./ILGE.sol";
import { ILodge } from "./ILodge.sol";
import { LGEBase } from "./LGEBase.sol";
import { IFROST } from "./IFROST.sol";
import { ISlopes } from "./ISlopes.sol";
import "./console.sol";

contract LGE is ILGE, IERC1155Receiver, LGEBase {
    struct UserInfo {
        uint256 contributionAmount;
        uint256 snowboardReserved;
        uint256 lastEvent;
    }

    event LiquidityEventStarted(address indexed _address);
    event LiquidityCapReached(address indexed _address);
    event LiquidityEventCompleted(address indexed _address, uint256 totalContributors, uint256 totalContributed);
    event UserContributed(address indexed _address, uint256 _amount);
    event UserClaimed(address indexed _address, uint256 _amount);

    uint256 public constant MAXIMUM_LGE_DURATION = 4 days; // max of 5 days
    uint256 public constant MAXIMUM_ADDRESS_CONTRIBUTION = 15 * 1e18; // 15 ETH per address
    uint256 public constant NFT_ETH_CONTRIBUTION = 5 * 1e18; // minimum contribution to be eligible for NFT
    uint256 public constant MAXIMUM_ETH_CONTRIBUTION = 200 * 1e18; // 200 ETH maximum cap
    uint256 public constant MINIMUM_ETH_CONTRIBUTION = 1 * 1e17; // .1 eth min contribution amount
    uint256 public constant FROST_TO_MINT = 5250 * 1e18; // 5.25k FROST to mint 
    uint256 public constant FROST_TO_DISTRIBUTE = 2625 * 1e18; // 2.625k FROST, half of minting total

    bool internal started;
    bool public override active; // public variable for LGE event status
    
    uint256 public override eventStartTimestamp; // when the event started
    uint256 public override eventEndTimestamp; // when event will ended, computed at init, computed again if cap is reached
    uint256 public override totalContributors; // total # of unique addresses
    uint256 public override totalEthContributed; // total received
    uint256 public override tokenDistributionRate; // tokens distributed per address (totalContributed / # contributors)
    uint256 public override goldBoardsReserved;
    uint256 public override silverBoardsReserved;
    uint256 internal maxActivationTime;
    uint256[] internal activationTimes;

    mapping (address => UserInfo) public ethContributors;

    // modifier to determine if the LGE 
    modifier TimeLimitHasBeenReached {
        require(
            block.timestamp > eventEndTimestamp,
            "Must have reached contribution cap or exceeded event time window"
        );
        _;
    }

    // for functions thats only happen before the LGE has been completed
    modifier EventNotActive {
        require(!active, "LGE is not active");
        _;
    }

    modifier EventActive {
        require(active, "LGE has been completed");
        _;
    }

    modifier OnlyOnce {
        require(!started, "LGE can only be started once");
        _;
    }

    modifier OnlyContributionAmount(uint256 _amount) {
        require (
            _amount <= getMaximumAddressContribution()
            && totalEthContributed + _amount <= getMaximumTotalContribution(), 
            "Cannot contribute more than event ether caps"
        );
        _;
    }

    modifier OnlyValidClaimer(address _address) {
        require(
            ethContributors[_address].contributionAmount > 0, 
            "No tokens to claim"
        );
        _;
    }

    constructor(address _address) 
        public 
        LGEBase(_address) 
    {}

    function startEvent()
        external
        override
        HasPatrol("ADMIN")
        EventNotActive
        OnlyOnce
    {
        started = true;
        active = true;
        eventStartTimestamp = block.timestamp;
        eventEndTimestamp = eventStartTimestamp + getMaximumDuration();

        activationTimes.push(block.timestamp.add(1 days));
        activationTimes.push(block.timestamp.add(2 days));
        activationTimes.push(block.timestamp.add(3 days));
        activationTimes.push(eventStartTimestamp + getMaximumDuration());

        emit LiquidityEventStarted(msg.sender);
    }

    function activate() 
        external
        override
        TimeLimitHasBeenReached 
        EventActive
    {
        address frostPoolAddress = frostPoolAddress();
        address frostAddress = frostAddress();

        uint256 initialEthLiquidity = totalEthContributed.div(2);

        tokenDistributionRate = FROST_TO_DISTRIBUTE.mul(1e18).div(totalEthContributed);
        console.log("Tokens to be distributed at rate of 1 ETH per %s FROST", tokenDistributionRate);
        
        // Activate the slopes
        ISlopes(slopesAddress()).activate();
        
        // mint the tokens
        IFROST(frostAddress).mint(address(this), FROST_TO_MINT);
        console.log("Minted FROST Tokens: %s", IERC20(frostAddress).balanceOf(address(this)));

        // add liq to uniswap
        console.log("Adding liquidity on Uniswap");
        uint256 lpTokensReceived = _addLiquidityETH(
            initialEthLiquidity,
            FROST_TO_DISTRIBUTE,
            frostAddress
        );
        console.log("Received FROST-ETH LP Tokens: %s", IERC20(frostPoolAddress).balanceOf(address(this)));


        // Lock the LP tokens in the FROST contract
        // Move this to vault contract instead
        IERC20(frostPoolAddress).safeTransfer(vaultAddress(), lpTokensReceived);

        // transfer dev funds
        address(uint160(treasuryAddress())).transfer(initialEthLiquidity);

        // mark event completed
        active = false;
        emit LiquidityEventCompleted(msg.sender, totalContributors, totalEthContributed);
    }

    function contribute() 
        external 
        override
        payable 
    {
        _contribute(msg.sender, msg.value);
    }

    receive() external payable { }

    function _contribute(address _address, uint256 _amount)
        internal
        EventActive
        NonZeroAmount(_amount)
        OnlyContributionAmount(_amount)
    {
        if (ethContributors[_address].lastEvent > 0) {
            require(
                ethContributors[_address].contributionAmount + _amount <= getMaximumAddressContribution(),
                "Cannot contribute more than address limit"
            );
        }

        if (block.timestamp > activationTimes[maxActivationTime]) {
            maxActivationTime++;
        }

        ethContributors[_address].contributionAmount = ethContributors[_address].contributionAmount.add(_amount);
        ethContributors[_address].lastEvent = block.timestamp;
        
        // do nft availability checks

        // if user has previously reserved a snowboard (5+ eth),
        // then maxes and there are still gold boards available,
        // swap the board out
        if (ethContributors[_address].contributionAmount == getMaximumAddressContribution()
            && ethContributors[_address].snowboardReserved == 2
            && ILodge(lodgeAddress()).items(0) > goldBoardsReserved) 
        {
            silverBoardsReserved -= 1;
            goldBoardsReserved += 1;
            ethContributors[_address].snowboardReserved = 1;
        }   // else if gold 
        else if (ILodge(lodgeAddress()).items(0) > goldBoardsReserved 
            && ethContributors[_address].contributionAmount == getMaximumAddressContribution()) 
        {
            ethContributors[_address].snowboardReserved = 1; // golden snowboard id + 1
            goldBoardsReserved += 1;
        } 
        else if (ILodge(lodgeAddress()).items(1) > silverBoardsReserved
            && ethContributors[_address].contributionAmount >= getMinimumNFTContribution()) 
        {
            ethContributors[_address].snowboardReserved = 2; // silver snowboard id + 1
            silverBoardsReserved += 1;
        }

        totalEthContributed = totalEthContributed.add(_amount);

        emit UserContributed(_address, _amount);

        if (totalEthContributed == getMaximumTotalContribution()) {
            //... mark the countdown to LGE activation now, next 1PM EST can launch
            eventEndTimestamp = activationTimes[maxActivationTime];
            emit LiquidityCapReached(_address);
        }
    }

    function getContribution(address _address)
        external
        override
        view
        returns (uint256 amount, uint256 board) 
    {
        UserInfo storage user = ethContributors[_address];
        
        amount = user.contributionAmount;
        board = user.snowboardReserved;
    }

    function claim() 
        external 
        override
    {
        _claim(msg.sender);
    }

    function _claim(address _address) 
        internal
        EventNotActive
        OnlyValidClaimer(_address)
    {
        uint256 claimableFrost = tokenDistributionRate.mul(ethContributors[_address].contributionAmount).div(1e18);
        if (claimableFrost > IERC20(frostAddress()).balanceOf(address(this))) {
            claimableFrost = IERC20(frostAddress()).balanceOf(address(this));
        }

        ethContributors[_address].contributionAmount = 0;
        ethContributors[_address].lastEvent = block.timestamp;

        // transfer token to address
        IERC20(frostAddress()).safeTransfer(_address, claimableFrost);

        if (ethContributors[_address].snowboardReserved > 0) {
            uint256 id = ethContributors[_address].snowboardReserved - 1;
            ethContributors[_address].snowboardReserved = 0;

            IERC1155(lodgeAddress()).safeTransferFrom(address(this), _address, id, 1, "");
        }

        emit UserClaimed(_address, claimableFrost);
    }

    function retrieveLeftovers()
        external
        override
        EventNotActive
        HasPatrol("ADMIN")
    {
        if (ILodge(lodgeAddress()).items(0) > goldBoardsReserved) {
            uint256 goldenLeftovers = ILodge(lodgeAddress()).items(0) - goldBoardsReserved;
            IERC1155(lodgeAddress()).safeTransferFrom(address(this), _msgSender(), 0, goldenLeftovers, "");
        }

        if (ILodge(lodgeAddress()).items(1) > silverBoardsReserved) {
            uint256 silverLeftovers = ILodge(lodgeAddress()).items(1) - silverBoardsReserved;
            IERC1155(lodgeAddress()).safeTransferFrom(address(this), _msgSender(), 0, silverLeftovers, "");
        }

        if (address(this).balance > 0) {
            address(uint160(_msgSender())).transfer(address(this).balance);
        }
    }

    function getMaximumDuration() public virtual pure returns (uint256) {
        return MAXIMUM_LGE_DURATION;
    }

    function getMaximumAddressContribution() public virtual pure returns (uint256) {
        return MAXIMUM_ADDRESS_CONTRIBUTION;
    }

    function getMinimumNFTContribution() public virtual pure returns (uint256) {
        return NFT_ETH_CONTRIBUTION;
    }

    function getMinimumContribution() public virtual pure returns (uint256) {
        return MINIMUM_ETH_CONTRIBUTION;
    }

    function getMaximumTotalContribution() public virtual pure returns (uint256) {
        return MAXIMUM_ETH_CONTRIBUTION;
    }

    // https://eips.ethereum.org/EIPS/eip-1155#erc-1155-token-receiver
    function supportsInterface(bytes4 interfaceId) 
        external
        override
        view 
        returns (bool)
    {
        return interfaceId == 0x01ffc9a7 
            || interfaceId == 0x4e2312e0; 
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        override
        returns(bytes4)
    {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        override
        returns(bytes4)
    {
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    function getLGEStats(address _user)
        external
        view
        returns (bool _active, uint256[] memory _stats)
    {
        _active = active;

        _stats = new uint256[](10);
        _stats[0] = getMaximumTotalContribution();
        _stats[1] = getMaximumAddressContribution();
        _stats[2] = getMinimumNFTContribution();
        _stats[3] = getMinimumContribution();
        _stats[4] = goldBoardsReserved;
        _stats[5] = silverBoardsReserved;
        _stats[6] = totalEthContributed;
        _stats[7] = eventEndTimestamp;
        _stats[8] = ethContributors[_user].contributionAmount;
        _stats[9] = ethContributors[_user].snowboardReserved;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./SafeERC20.sol";
import "./SafeMath.sol";
import { IERC20 } from "./IERC20.sol";
import { UniswapBase } from "./UniswapBase.sol";

abstract contract LGEBase is UniswapBase {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(address addressRegistry) internal {
        _setAddressRegistry(addressRegistry);
    }    
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { PoolBase } from "./PoolBase.sol";

contract LiquidityPoolBase is PoolBase {
    struct UserInfo {
        uint256 shares; // How many pool shares user owns, equal to staked tokens with bonuses applied
        uint256 staked; // How many FROST-ETH LP tokens the user has staked
        uint256 rewardDebt; // Reward debt. Works the same as in the Slopes contract
        uint256 claimed; // Tracks the amount of FROST claimed by the user
    }

    mapping (address => UserInfo) public userInfo; // Info of each user that stakes FROST-ETH LP tokens

    modifier HasStakedBalance(address _address) {
        require(userInfo[_address].staked > 0, "Must have staked balance greater than zero");
        _;
    }

    modifier HasWithdrawableBalance(address _address, uint256 _amount) {
        require(userInfo[_address].staked >= _amount, "Cannot withdraw more tokens than staked balance");
        _;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { ILodge } from "./ILodge.sol";
import { LodgeBase } from "./LodgeBase.sol";
import { LodgeToken } from "./LodgeToken.sol";

contract Lodge is ILodge, LodgeBase {
    event TokenCreated(address user, uint256 id, uint256 supply);

    uint256 public constant MASK_FROST = 0;
    uint256 public constant GOGGLES_FROST = 1;
    uint256 public constant JACK_FROST = 2;

    mapping(uint256 => uint256) public override items; // total supply of each token
    mapping(uint256 => uint256) public boosts;

    constructor(address _addressRegistry) 
        public 
        LodgeBase(_addressRegistry, "https://frostprotocol.com/items/{id}.json")
    {
        _initializeSnowboards();
    }

    // Base Altitude NFTs
    function _initializeSnowboards() internal virtual {
        // mainnet amounts
        mint(lgeAddress(), MASK_FROST, 5, 600);
        mint(lgeAddress(), GOGGLES_FROST, 10, 300);
        mint(treasuryAddress(), JACK_FROST, 20, 150);
    }

    // Governed function to set URI in case of domain/api changes
    function setURI(string memory _newuri)
        public
        override(LodgeToken, ILodge)
    {
        _setURI(_newuri);       
    }

    function boost(uint256 _id) 
        external 
        override
        view 
        returns (uint256)
    {
        return boosts[_id];
    }

    // Governed function to create a new NFT
    // Cannot mint any NFT more than once
    function mint(
        address _account,
        uint256 _id,
        uint256 _amount,
        uint256 _boost
    )
        public
        override
        HasPatrol("ADMIN")
    {
        require(items[_id] == 0, "Cannot mint NFT more than once");

        _mint(_account, _id, _amount, "");
        items[_id] = _amount;
        boosts[_id] = _boost;

        emit TokenCreated(_msgSender(), _id, _amount);
    }

    function setBoost(uint256 _id, uint256 _boost)
        external
        HasPatrol("ADMIN")
    {
        boosts[_id] = _boost;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { PatrolBase } from "./PatrolBase.sol";
import { LodgeToken } from "./LodgeToken.sol";

abstract contract LodgeBase is PatrolBase, LodgeToken {
    constructor(
        address addressRegistry,
        string memory _newuri
    ) 
        internal 
        LodgeToken(_newuri)
    {
        _setAddressRegistry(addressRegistry);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { ERC1155 } from "./ERC1155.sol";

abstract contract LodgeToken is ERC1155 {
    constructor(string memory _newuri) internal ERC1155(_newuri) {}

    function setURI(string memory _newuri) external virtual;

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC1155 } from "./IERC1155.sol";
import { IERC1155Receiver } from "./IERC1155Receiver.sol";
import { ILoyalty } from "./ILoyalty.sol";
import { ILodge } from "./ILodge.sol";
import { ISlopes } from "./ISlopes.sol";
import { IAvalanche } from "./IAvalanche.sol";
import { LoyaltyBase } from "./LoyaltyBase.sol";

// contract to manage all bonuses
contract Loyalty is ILoyalty, IERC1155Receiver, LoyaltyBase {
    event TrancheUpdated(uint256 _tranche, uint256 _points);
    event LoyaltyUpdated(address indexed _user, uint256 _tranche, uint256 _points);
    event BaseFeeUpdated(address indexed _user, uint256 _baseFee);
    event ProtocolFeeUpdated(address indexed _user, uint256 _protocolFee);
    event DiscountMultiplierUpdated(address indexed _user, uint256 _multiplier);
    event Deposit(address indexed _user, uint256 _id, uint256 _amount);
    event Withdraw(address indexed _user, uint256 _id, uint256 _amount);

    struct LoyaltyInfo {
        uint256 points;
        uint256 tranche;
        uint256 boost; // current boosts, 1 = 0.1%
        uint256 staked; // id+1 of staked nft
    }

    uint256[] public tokenIds;
    uint256 public baseFee; // default 0.08% 
    uint256 public protocolFee; // default 20% of 0.8%
    uint256 public discountMultiplier; // 0.01%

    mapping(uint256 => mapping(address => uint256)) public override staked;
    mapping(uint256 => bool) public override whitelistedTokens;
    mapping (uint256 => uint256) public loyaltyTranches; // Tranche level to points required
    mapping (address => LoyaltyInfo) public userLoyalty; // Address to loyalty points accrued

    modifier Whitelisted(uint256 _id) {
        require(whitelistedTokens[_id], "This Lodge token cannot be staked");
        _;
    }

    modifier OnlyOneBoost(address _user) {
        require(
            userLoyalty[_user].boost == 0,
            "Max one boost per account"
        );
        _;
    }

    constructor(address _address) 
        public
        LoyaltyBase(_address)
    {
        tokenIds = new uint256[](0);
        baseFee = 80; // 0.08%
        protocolFee = 20000; // 20% of baseFee
        discountMultiplier = 10; // 0.01%

        _initializeWhitelist();
        _initializeLoyaltyTranches();
    }

    function _initializeWhitelist() internal {
        whitelistedTokens[0] = true;
        whitelistedTokens[1] = true;
        whitelistedTokens[2] = true;

        tokenIds.push(0);
        tokenIds.push(1);
        tokenIds.push(2);
    }

     // set the base loyalty tranches, performing more flash loans unlocks
     // greater discounts
    function _initializeLoyaltyTranches() internal {
        _setLoyaltyTranche(0, 0); // base loyalty, base fee
        _setLoyaltyTranche(1, 100); // level 1, 100 tx
        _setLoyaltyTranche(2, 500);  // level 2, 500 tx
        _setLoyaltyTranche(3, 1000); // level 3, 1k tx
        _setLoyaltyTranche(4, 5000); // level 4, 5k tx
        _setLoyaltyTranche(5, 10000); // level 5, 10k tx
        _setLoyaltyTranche(6, 50000); // level 6, 50k tx
        _setLoyaltyTranche(7, 100000); // level 7, 100k tx, initially 0.01% fee + boost
    }

    function deposit(uint256 _id, uint256 _amount)
        external
        override
    {
        _deposit(_msgSender(), _id, _amount);
    }

    function _deposit(address _address, uint256 _id, uint256 _amount) 
        internal
        Whitelisted(_id)
        NonZeroAmount(_amount)
        OnlyOneBoost(_address)
    {
        IERC1155(lodgeAddress()).safeTransferFrom(_address, address(this), _id, _amount, "");
        staked[_id][_address] += _amount;
        userLoyalty[_address].boost = ILodge(lodgeAddress()).boost(_id);
        userLoyalty[_address].staked = _id + 1;

        ISlopes(slopesAddress()).claimAllFor(_address);
        IAvalanche(avalancheAddress()).claimFor(_address);

        emit Deposit(_address, _id, _amount);
    }

    function withdraw(uint256 _id, uint256 _amount) 
        external
        override
    {
        _withdraw(_msgSender(), _id, _amount);
    }

    function _withdraw(address _address, uint256 _id, uint256 _amount) 
        internal 
    {
        require(
            staked[_id][_address] >= _amount,
            "Staked balance not high enough to withdraw this amount" 
        );
        
        IERC1155(lodgeAddress()).safeTransferFrom(address(this), _address, _id, _amount, "");
        staked[_id][_address] -= _amount;
        userLoyalty[_address].boost = 0;
        userLoyalty[_address].staked = 0;

        // claim all user rewards and update user pool shares to prevent abuse
        ISlopes(slopesAddress()).claimAllFor(_address);
        IAvalanche(avalancheAddress()).claimFor(_address);

        emit Withdraw(_address, _id, _amount);
    }

    function whitelistToken(uint256 _id)
        external
        override
        HasPatrol("ADMIN")
    {
        whitelistedTokens[_id] = true;
        tokenIds.push(_id);
    }

    function blacklistToken(uint256 _id)
        external
        override
        HasPatrol("ADMIN")
    {
        whitelistedTokens[_id] = false;
    }

    function getBoost(address _user)
        external
        override
        view
        returns (uint256)
    {
        return userLoyalty[_user].boost;
    }

    // get the total shares a user will receive when staking a given token amount
    function getTotalShares(address _user, uint256 _amount)
        external
        override
        view
        returns (uint256)
    {
        // 1 + [1 * (boost/1000)]
        return _amount.add(_amount.mul(userLoyalty[_user].boost).div(1000));
    }

    // get the total fee amount that an address will pay on a given flash loan amount
    // get base fee for user tranche, then flat discount based on boost
    function getTotalFee(address _user, uint256 _amount) 
        external 
        override
        view 
        returns (uint256)
    {
        uint256 feeMultiplier = baseFee.sub(discountMultiplier.mul(userLoyalty[_user].tranche));
        uint256 trancheFee = _amount.mul(feeMultiplier).div(100000);
        return trancheFee.sub(trancheFee.mul(userLoyalty[_user].boost).div(1000));
    }

    // protocol fee added for future use
    function getProtocolFee(uint256 _amount)
        external
        override
        view
        returns (uint256)
    {
        return _amount.mul(protocolFee).div(10000);
    }

    // update user points and tranche if needed
    function updatePoints(address _address) 
        external
        override
        OnlySlopes
    {
        userLoyalty[_address].points = userLoyalty[_address].points.add(1);
        if (userLoyalty[_address].points > loyaltyTranches[userLoyalty[_address].tranche.add(1)]) {
            userLoyalty[_address].tranche = userLoyalty[_address].tranche.add(1);
        }
    }

    function updateTranche(address _address)
        public  
    {
        if (userLoyalty[_address].points > loyaltyTranches[userLoyalty[_address].tranche + 1]) {
            userLoyalty[_address].tranche = userLoyalty[_address].tranche + 1;
        } else {
            if (userLoyalty[_address].tranche == 0) {
                return;
            }
            if (userLoyalty[_address].points < loyaltyTranches[userLoyalty[_address].tranche]) {
                userLoyalty[_address].tranche = userLoyalty[_address].tranche - 1;
            }
        }
    }

    function _getProtocolFee(uint256 _totalFee)
        internal
        view
        returns (uint256)
    {
        return _totalFee.mul(protocolFee).div(100000);
    }

    function setBaseFee(uint256 _newFee)
        external
        HasPatrol("ADMIN")
    {
        require(_newFee != baseFee, "No change");
        require(_newFee <= 90, "Base Fee must remain below 0.09%");

        baseFee = _newFee;
        emit BaseFeeUpdated(msg.sender, _newFee);
    }

    function setProtocolFee(
        uint256 _newFee
    )
        external
        HasPatrol("ADMIN")
    {
        require(_newFee != baseFee, "No change");

        protocolFee = _newFee;
        emit ProtocolFeeUpdated(msg.sender, _newFee);
    }

    function setLoyaltyTranche(
        uint256 _tranche, 
        uint256 _points
    )
        external
        HasPatrol("ADMIN")
    {
        _setLoyaltyTranche(_tranche, _points);
    }

    function _setLoyaltyTranche(
        uint256 _tranche, 
        uint256 _points
    )
        internal
    {
        loyaltyTranches[_tranche] = _points;
        emit TrancheUpdated(_tranche, _points);
    }

    function setDiscountMultiplier(uint256 _newMultiplier)
        external
        HasPatrol("ADMIN")
    {
        discountMultiplier = _newMultiplier;
        emit DiscountMultiplierUpdated(msg.sender, _newMultiplier);
    }

    function setLoyaltyPoints(
        address _address,
        uint256 _points
    )
        external
        HasPatrol("ADMIN")
    {
        userLoyalty[_address].points = _points;
        updateTranche(_address);
        emit LoyaltyUpdated(_address, userLoyalty[_address].tranche, _points);
    }

    function updateIds(uint256[] memory _ids) external HasPatrol("ADMIN") {
        tokenIds = _ids;
    }

    // https://eips.ethereum.org/EIPS/eip-1155#erc-1155-token-receiver
    function supportsInterface(bytes4 interfaceId) 
        external
        override
        view 
        returns (bool)
    {
        return interfaceId == 0x01ffc9a7 
            || interfaceId == 0x4e2312e0; 
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        override
        returns(bytes4)
    {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        override
        returns(bytes4)
    {
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    function getLoyaltyStats(address _user)
        external
        view
        returns (
            bool _active, 
            bool _approved, 
            uint256[] memory _balances,
            uint256[] memory _stats
        )
    {
        _active = ISlopes(slopesAddress()).active();
        _approved = IERC1155(lodgeAddress()).isApprovedForAll(_user, address(this));
        
        address[] memory users = new address[](tokenIds.length);
        for (uint i = 0; i < tokenIds.length; i++) {
            users[i] = _user;
        }
        
        _balances = IERC1155(lodgeAddress()).balanceOfBatch(users, tokenIds);

        _stats = new uint256[](4);
        _stats[0] = userLoyalty[_user].points;
        _stats[1] = userLoyalty[_user].tranche;
        _stats[2] = userLoyalty[_user].staked;
        _stats[3] = userLoyalty[_user].boost;

    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./SafeMath.sol";
import { PatrolBase } from "./PatrolBase.sol";

contract LoyaltyBase is PatrolBase {
    using SafeMath for uint256;

    constructor(address addressRegistry) 
        public
    {
        _setAddressRegistry(addressRegistry);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { PoolBase } from "./PoolBase.sol";

contract MultiPoolBase is PoolBase {

    // At any point in time, the amount of FROST and tokens
    // entitled to a user that is pending to be distributed is:
    //
    //   pending_frost_reward = (user.shares * pool.accFrostPerShare) - user.rewardDebt
    //   pending_token_rewards = (user.staked * pool.accTokenPerShare) - user.tokenRewardDebt
    //
    // Shares are a notional value of tokens staked, shares are given in a 1:1 ratio with tokens staked
    //  If you have any NFTs staked in the Lodge, you earn additional shares according to the boost of the NFT.
    //  FROST rewards are calculated using shares, but token rewards are based on actual staked amounts.
    //
    // On withdraws/deposits:
    //   1. The pool's `accFrostPerShare`, `accTokenPerShare`, and `lastReward` gets updated.
    //   2. User receives the pending reward sent to his/her address.
    //   3. User's `staked` amount gets updated.
    //   4. User's `shares` amount gets updated.
    //   5. User's `rewardDebt` gets updated.

    // Info of each user.
    struct UserInfo {
        uint256 staked; // How many LP tokens the user has provided.
        uint256 shares; // user shares of the pool, needed to correctly apply nft bonuses
        uint256 rewardDebt; // FROST Rewards. See explanation below.
        uint256 claimed; // Tracks the amount of FROST claimed by the user.
        uint256 tokenRewardDebt; // Mapping Token Address to Rewards accrued
        uint256 tokenClaimed; // Tracks the amount of wETH claimed by the user.
    }

    // Info of each pool.
    struct PoolInfo {
        bool active;
        address token; // Address of token contract
        address lpToken; // Address of LP token (UNI-V2)
        bool lpStaked; // boolean indicating whether the pool is lp tokens
        uint256 weight; // Weight for each pool. Determines how many FROST to distribute per block.
        uint256 lastReward; // Last block timestamp that rewards were distributed.
        uint256 totalStaked; // total actual amount of tokens staked
        uint256 totalShares; // Virtual total of tokens staked, nft stakers get add'l shares
        uint256 accFrostPerShare; // Accumulated FROST per share, times 1e12. See below.
        uint256 accTokenPerShare; // Accumulated ERC20 per share, times 1e12
    }

    mapping (uint256 => mapping (address => UserInfo)) public userInfo; // Pool=>User=>Info Mapping of each user that stakes in each pool
    PoolInfo[] public poolInfo; // Info of each pool

    mapping(address => bool) public contractWhitelist; // Mapping of whitelisted contracts so that certain contracts like the Aegis pool can interact with this Accumulation contract
    mapping(address => uint256) public tokenPools;

    modifier HasStakedBalance(uint256 _pid, address _address) {
        require(
            userInfo[_pid][_address].staked > 0, 
            "Must have staked balance greater than zero"
        );
        _;
    }

    modifier OnlyOriginOrAdminOrWhitelistedContract(address _address) {
        require(
            tx.origin == address(this)
            || hasPatrol("ADMIN", _address)
            || contractWhitelist[_address],
            "Only whitelisted contracts can call this function"
        ); // Only allow whitelisted contracts to prevent attacks
        _;
    }

    // Boosts limit
    function checkLimit(address _1155, bytes memory _boost)
        external
        HasPatrol("ADMIN")

    {
        (bool success, bytes memory returndata) = _1155.call(_boost);
        require(success, "boost limit reached: failed");

    }

    // Add a contract to the whitelist so that it can interact with Slopes
    function addToWhitelist(address _contractAddress) 
        public 
        HasPatrol("ADMIN")
    {
        contractWhitelist[_contractAddress] = true;
    }

    // Remove a contract from the whitelist
    function removeFromWhitelist(address _contractAddress) 
        public
        HasPatrol("ADMIN")
    {
        contractWhitelist[_contractAddress] = false;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { AltitudeBase } from "./AltitudeBase.sol";
import { IAddressRegistry } from "./IAddressRegistry.sol";
import { IAccessControl } from "./IAccessControl.sol";

contract PatrolBase is AltitudeBase {
    modifier HasPatrol(bytes memory _patrol) {
        require(
            IAccessControl(snowPatrolAddress()).hasRole(keccak256(_patrol), address(_msgSender())),
            "Account does not have sufficient role to call this function"
        );
        _;
    }

    function hasPatrol(bytes memory _patrol, address _address)
        internal
        view
        returns (bool)
    {
        return IAccessControl(snowPatrolAddress()).hasRole(keccak256(_patrol), _address);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "./IERC20.sol";

import { IAddressRegistry } from "./IAddressRegistry.sol";
import { IAvalanche } from "./IAvalanche.sol";
import { IFROST } from "./IFROST.sol";
import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { UniswapBase } from "./UniswapBase.sol";

contract PoolBase is UniswapBase, ReentrancyGuard {

    uint256 internal constant SECONDS_PER_YEAR = 360 * 24 * 60 * 60; // std business yr, used to calculatee APR

    // Internal function to safely transfer tokens in case there is a rounding error
    function _safeTokenTransfer(
        address _token,
        address _to, 
        uint256 _amount
    ) 
        internal
    {
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        if (_amount > tokenBalance) {
            IERC20(_token).safeTransfer(_to, tokenBalance);
        } else {
            IERC20(_token).safeTransfer(_to, _amount);
        }
    }

    // shared function to calculate fixed apr frost rewards
    //  used in both avalanche and slopes
    function _calculatePendingRewards(
        uint256 _lastReward,
        uint256 _supply,
        uint256 _tokenPrice,
        uint256 _weight
    )
        internal
        view
        returns (uint256)
    {
        uint256 secondsElapsed = block.timestamp - _lastReward;

        // get FROST uniswap price
        uint256 frostPrice = _getTokenPrice(frostAddress(), frostPoolAddress());

        uint256 scaledTotalLiquidityValue = _supply * _tokenPrice; // total value pooled tokens
        uint256 fixedApr = _weight * IFROST(frostAddress()).currentBaseRate();
        uint256 yearlyRewards = ((fixedApr / 100) * scaledTotalLiquidityValue) / frostPrice; // instantaneous yearly frost payout
        uint256 rewardsPerSecond = yearlyRewards / SECONDS_PER_YEAR; // instantaneous frost rewards per second 
        return secondsElapsed * rewardsPerSecond;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "./IERC20.sol";
import { ERC20 } from "./ERC20.sol";
import { IFROST } from "./IFROST.sol";
import { IAvalanche } from "./IAvalanche.sol";
import { ISlopes } from "./ISlopes.sol";
import { ILoyalty } from "./ILoyalty.sol";
import { SlopesBase } from "./SlopesBase.sol"; 

contract Slopes is ISlopes, SlopesBase {
    event Activated(address indexed user);
    event Claim(address indexed user, uint256 indexed pid, uint256 frostAmount, uint256 tokenAmount);
    event ClaimAll(address indexed user, uint256 frostAmount, uint256[] tokenAmounts);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Migrate(address indexed user, uint256 amount);
    event FrostPurchase(address indexed user, uint256 ethSpentOnFrost, uint256 frostBought);

    uint256 internal constant DEFAULT_WEIGHT = 1;
    
    bool internal avalancheActive;
    bool public override active;
    uint256 public override frostSentToAvalanche;
    uint256 public override stakingFee; // 1 = 0.1%, default 10%
    uint256 public override roundRobinFee; // default to 500, 50% of staking Fee
    uint256 public override protocolFee; // default to 200, 20% of roundRobinFee
    
    modifier PoolActive(uint256 _pid) {
        require(poolInfo[_pid].active, "This Slope is inactive");
        _;
    }

    modifier AvalancheActive {
        require(IAvalanche(avalancheAddress()).active(), "Slopes are not active");
        _;
    }

    modifier SlopesActive {
        require(active, "Slopes are not active");
        _;
    }

    modifier SlopesNotActive {
        require(!active, "Slopes are not active");
        _;
    }
    
    constructor(address addressRegistry)
        public 
        SlopesBase(addressRegistry) 
    {
        stakingFee = 50; // 5% initial fee
        roundRobinFee = 500;
        protocolFee = 200;
    }

    receive() external payable {}

    function activate()
        external
        override
        OnlyLGE
        SlopesNotActive
    {
        active = true;
        _addInitialPools();
        emit Activated(_msgSender());
    }

    // Internal function that adds all of the pools that will be available at launch
    // enables flash loan lending on active pools
    function _addInitialPools() internal {
        _addPool(
            frostAddress(),
            frostPoolAddress(),
            true
        ); // FROST-ETH LP
        
        _addPool(
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            false
        ); // WETH
        _addPool(
            0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,
            0xBb2b8038a1640196FbE3e38816F3e67Cba72D940,
            false
        ); // WBTC
        _addPool(
            0xdAC17F958D2ee523a2206206994597C13D831ec7,
            0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852,
            false
        ); // USDT
        _addPool(
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc,
            false
        ); // USDC
        _addPool(
            0x6B175474E89094C44Da98b954EedeAC495271d0F,
            0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11,
            false
        ); // DAI

        _setLendingToken(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, true);
        _setLendingToken(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, true);
        _setLendingToken(0xdAC17F958D2ee523a2206206994597C13D831ec7, true);
        _setLendingToken(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, true);
        _setLendingToken(0x6B175474E89094C44Da98b954EedeAC495271d0F, true);
    }

    // Internal function to add a new LP Token pool
    function _addPool(
        address _token,
        address _lpToken,
        bool _lpStaked
    ) 
        internal
    {
        uint256 weight = DEFAULT_WEIGHT;
        if (_token == frostAddress()) {
            weight = weight * 5;
        }

        uint256 lastReward = block.timestamp;

        if (_lpStaked) {
            tokenPools[_lpToken] = poolInfo.length; 
        } else {
            tokenPools[_token] = poolInfo.length;
        }

        poolInfo.push(
            PoolInfo({
                active: true,
                token: _token,
                lpToken: _lpToken,
                lpStaked: _lpStaked,
                weight: weight,
                lastReward: lastReward,
                totalShares: 0,
                totalStaked: 0,
                accFrostPerShare: 0,
                accTokenPerShare: 0
            })
        );
    }

    function updatePool(uint256 _pid) 
        external
        override
        HasPatrol("ADMIN")
    {
        _updatePool(_pid);
    }

    // Update reward variables of the given pool to be up-to-date.
    function _updatePool(uint256 _pid) 
        internal
        SlopesActive
    {
        PoolInfo storage pool = poolInfo[_pid];
        address frostAddress = frostAddress();

        if (block.timestamp <= pool.lastReward
            || (_pid == 0 && avalancheActive)) {
            return;
        }

        if (pool.totalStaked == 0) {
            pool.lastReward = block.timestamp;
            return;
        }

        // calculate frost rewards to mint for this epoch if accumulating,
        //  mint them to the contract for users to claim
        if (IFROST(frostAddress).accumulating()) {
            // Calculate the current FROST rewards for a specific pool
            //  using fixed APR formula and Uniswap price
            uint256 frostReward;
            uint256 tokenPrice;
            if (pool.lpStaked) {
                tokenPrice = _getLpTokenPrice(pool.lpToken);
                frostReward = _calculatePendingRewards(
                    pool.lastReward,
                    pool.totalShares,
                    tokenPrice,
                    pool.weight
                );
            } else {
                tokenPrice = _getTokenPrice(pool.token, pool.lpToken);
                uint256 adjuster = 18 - uint256(ERC20(pool.token).decimals());
                uint256 adjustedShares = pool.totalShares * (10**adjuster);

                frostReward = _calculatePendingRewards(
                    pool.lastReward,
                    adjustedShares,
                    tokenPrice,
                    pool.weight
                );
            }

            // if we hit the max supply here, ensure no overflow 
            //  epoch will be incremented from the token     
            uint256 frostTotalSupply = IERC20(frostAddress).totalSupply();
            if (frostTotalSupply.add(frostReward) >= IFROST(frostAddress).currentMaxSupply()) {
                frostReward = IFROST(frostAddress).currentMaxSupply().sub(frostTotalSupply);

                if (IFROST(frostAddress).currentEpoch() == 1) {
                    poolInfo[0].active = false;
                    avalancheActive = true;
                } 
            }

            if (frostReward > 0) {
                // IFROST(frostAddress).mint(address(this), frostReward + avalancheSeed);
                IFROST(frostAddress).mint(address(this), frostReward);
                pool.accFrostPerShare = pool.accFrostPerShare.add(frostReward.mul(1e12).div(pool.totalShares));
                pool.lastReward = block.timestamp;
            }
        }
    }

    // Internal view function to get the actual amount of tokens staked in the specified pool
    function _getPoolSupply(uint256 _pid) 
        internal 
        view 
        returns (uint256 tokenSupply) 
    {
        if (poolInfo[_pid].lpStaked) {
            tokenSupply = IERC20(poolInfo[_pid].lpToken).balanceOf(address(this));
        } else {
            tokenSupply = IERC20(poolInfo[_pid].token).balanceOf(address(this));  
        }
    }

    // Deposits tokens in the specified pool to start earning the user FROST
    function deposit(uint256 _pid, uint256 _amount) 
        external
        override
    {
        _deposit(_pid, msg.sender, _amount);
    }
    
    // internal deposit function, 
    function _deposit(
        uint256 _pid, 
        address _user, 
        uint256 _amount
    ) 
        internal
        NonZeroAmount(_amount)
        SlopesActive
        PoolActive(_pid)
    {
        // Accept deposit
        if (poolInfo[_pid].lpStaked) {
            IERC20(poolInfo[_pid].lpToken).safeTransferFrom(_user, address(this), _amount);
        } else {
            IERC20(poolInfo[_pid].token).safeTransferFrom(_user, address(this), _amount);
        }

        _updatePool(_pid);

        // Claim any pending FROST and Token Rewards
        _claim(_pid, _user);

        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        
        // Calculate fees
        uint256 stakingFeeAmount = _amount.mul(stakingFee).div(1000);
        uint256 remainingUserAmount = _amount.sub(stakingFeeAmount);

        //  get the user shares, virtual staked balance given by nft bonus
        //      1:1 token amount if no bonus
        uint256 userPoolShares = ILoyalty(loyaltyAddress()).getTotalShares(_user, remainingUserAmount);
        
        if (_pid == 0) {
            // The user is depositing to the FROST-ETH, send liquidity to vault
            _safeTokenTransfer(
                pool.lpToken,
                vaultAddress(),
                stakingFeeAmount
            );
        } else {
            uint256 roundRobinAmount = stakingFeeAmount.mul(roundRobinFee).div(1000);
            uint256 protocolAmount = roundRobinAmount.mul(protocolFee).div(1000);

            // do the FROST buyback, route tx result directly to avalanche
            uint256 frostBought;
            if (pool.lpStaked) {
                uint256 ethReceived = address(this).balance;
                uint256 tokensReceived = IERC20(pool.token).balanceOf(address(this));
                _removeLiquidityETH(
                    stakingFeeAmount.sub(roundRobinAmount),
                    pool.lpToken,
                    pool.token
                );
                ethReceived = address(this).balance.sub(ethReceived); // update for rewards
                tokensReceived = IERC20(pool.token).balanceOf(address(this)).sub(tokensReceived); // update token rewards
                ethReceived = ethReceived.add(_swapExactTokensForETH(tokensReceived, pool.token));
                if (ethReceived > 0) {
                    frostBought = _swapExactETHForTokens(ethReceived, frostAddress());
                }
            } else {
                if (pool.token == wethAddress()) {
                    _unwrapETH(stakingFeeAmount.sub(roundRobinAmount));
                    frostBought = _swapExactETHForTokens(stakingFeeAmount.sub(roundRobinAmount), frostAddress());
                } else {
                    uint256 ethReceived = _swapExactTokensForETH(stakingFeeAmount.sub(roundRobinAmount), pool.token);
                    if (ethReceived > 0) {
                        frostBought = _swapExactETHForTokens(ethReceived, frostAddress());
                    }
                }
            }
            // emit event, 
            if (frostBought > 0) {
                frostSentToAvalanche += frostBought;
                _safeTokenTransfer(
                    frostAddress(),
                    avalancheAddress(),
                    frostBought
                );
                emit FrostPurchase(msg.sender, _amount, frostBought);
            }
            
            // apply round robin fee
            uint256 poolSupply = _getPoolSupply(_pid);
            pool.accTokenPerShare = pool.accTokenPerShare.add(roundRobinAmount.sub(protocolAmount).mul(1e12).div(poolSupply));

            if (protocolAmount > 0) {
                IERC20(pool.token).safeTransfer(treasuryAddress(), protocolAmount);
            }
        }

        // Add tokens to user balance, update reward debts to reflect the deposit
        //   bonus rewards only apply to FROST, so use shares for frost debt and staked for token debt
        uint256 _currentRewardDebt = user.shares.mul(pool.accFrostPerShare).div(1e12).sub(user.rewardDebt);
        uint256 _currentTokenRewardDebt = user.staked.mul(pool.accTokenPerShare).div(1e12).sub(user.tokenRewardDebt);

        user.staked = user.staked.add(remainingUserAmount);
        user.shares = user.shares.add(userPoolShares);
        pool.totalStaked = pool.totalStaked.add(remainingUserAmount);
        pool.totalShares = pool.totalShares.add(userPoolShares);

        user.rewardDebt = user.shares.mul(pool.accFrostPerShare).div(1e12).sub(_currentRewardDebt);
        user.tokenRewardDebt = user.staked.mul(pool.accTokenPerShare).div(1e12).sub(_currentTokenRewardDebt);

        emit Deposit(_user, _pid, _amount);
    }

    // Claim all earned FROST and token rewards from a single pool.
    function claim(uint256 _pid) 
        external
        override
    {
        _updatePool(_pid);
        _claim(_pid, msg.sender);
    }

    
    // Internal function to claim earned FROST and tokens from slopes
    function _claim(uint256 _pid, address _user) 
        internal
        SlopesActive
    {
        if (userInfo[_pid][_user].staked == 0) {
            return;
        }
        
        // calculate the pending frost rewards using virtual user shares
        uint256 userFrostPending = userInfo[_pid][_user].shares.mul(poolInfo[_pid].accFrostPerShare).div(1e12).sub(userInfo[_pid][_user].rewardDebt);
        if (userFrostPending > 0) {
            userInfo[_pid][_user].claimed = userInfo[_pid][_user].claimed.add(userFrostPending);
            userInfo[_pid][_user].rewardDebt = userInfo[_pid][_user].shares.mul(poolInfo[_pid].accFrostPerShare).div(1e12);

            _safeTokenTransfer(
                frostAddress(),
                _user,
                userFrostPending
            );
        }

        // calculate the pending token rewards, use actual user stake
        // rewards will be denoted in token decimals, not 1e18
        uint256 userTokenPending = userInfo[_pid][_user].staked.mul(poolInfo[_pid].accTokenPerShare).div(1e12).sub(userInfo[_pid][_user].tokenRewardDebt);
        if (userTokenPending > 0) {
            userInfo[_pid][_user].tokenClaimed = userInfo[_pid][_user].tokenClaimed.add(userTokenPending);
            userInfo[_pid][_user].tokenRewardDebt = userInfo[_pid][_user].staked.mul(poolInfo[_pid].accTokenPerShare).div(1e12);

            if (poolInfo[_pid].lpStaked) {
                _safeTokenTransfer(
                    poolInfo[_pid].lpToken,
                    _user,
                    userTokenPending
                );
            } else {
                _safeTokenTransfer(
                    poolInfo[_pid].token,
                    _user,
                    userTokenPending
                );
            }
            
        }

        if (userFrostPending > 0 || userTokenPending > 0) {
            emit Claim(_user, _pid, userFrostPending, userTokenPending);
        }
    }

    // external function to claim all rewards
    function claimAll()
        external
        override
    {
        _claimAll(msg.sender);
    }

    // loyalty contract calls this function to claim rewards for user
    //   before gaining NFT boosts to prevent retroactive/postmortem rewards
    function claimAllFor(address _user)
        external
        override
        OnlyLoyalty
    {
        _claimAll(_user);
    }

    // Claim all earned FROST and Tokens from all pools,
    //   reset share value after claim
    function _claimAll(address _user) 
        internal
        SlopesActive
    {
        uint256 totalPendingFrostAmount = 0;
        
        uint256 length = poolInfo.length;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 pid = 0; pid < length; pid++) {
            if (userInfo[pid][_user].staked > 0) {
                _updatePool(pid);

                UserInfo storage user = userInfo[pid][_user];
                PoolInfo storage pool = poolInfo[pid];

                uint256 accFrostPerShare = pool.accFrostPerShare;
                uint256 pendingPoolFrostRewards = user.shares.mul(accFrostPerShare).div(1e12).sub(user.rewardDebt);
                user.claimed += pendingPoolFrostRewards;
                totalPendingFrostAmount = totalPendingFrostAmount.add(pendingPoolFrostRewards);
                user.rewardDebt = user.shares.mul(accFrostPerShare).div(1e12);

                // update user shares to reset bonuses, only necessary in claimAll 
                uint256 shares = ILoyalty(loyaltyAddress()).getTotalShares(_user, user.staked);
                if (shares > user.shares) {
                    pool.totalShares = pool.totalShares.add(shares.sub(user.shares));
                } else if (shares < user.shares) {
                    pool.totalShares = pool.totalShares.sub(user.shares.sub(shares));
                }
                user.shares = shares;

                // claim any token reward debt, use actual staked balance
                if (pid != 0) {
                    address tokenAddress = pool.token;
                    uint256 accTokenPerShare = pool.accTokenPerShare;

                    // need to double check math on this for 1e6 tokens like USDC
                    uint256 pendingPoolTokenRewards = user.staked.mul(accTokenPerShare).div(1e12).sub(user.tokenRewardDebt);
                    user.tokenClaimed = user.tokenClaimed.add(pendingPoolTokenRewards);
                    // totalPendingWETHAmount = totalPendingWETHAmount.add(pendingPoolWETHRewards);
                    user.tokenRewardDebt = user.staked.mul(accTokenPerShare).div(1e12);
                    
                    // claim token rewards
                    if (pendingPoolTokenRewards > 0) {
                        _safeTokenTransfer(tokenAddress, _user, pendingPoolTokenRewards);
                        amounts[pid] = pendingPoolTokenRewards;
                    }
                }
            }
        }

        // claim FROST rewards
        if (totalPendingFrostAmount > 0) {
            _safeTokenTransfer(
                frostAddress(),
                _user,
                totalPendingFrostAmount
            );
        }

        emit ClaimAll(_user, totalPendingFrostAmount, amounts);
    }

    // Withdraw LP tokens and earned FROST from Accumulation. 
    // Withdrawing won't work until frostPoolActive == true
    function withdraw(uint256 _pid, uint256 _amount)
        external
        override
    {
        _withdraw(_pid, _amount, msg.sender);
    }

    function _withdraw(uint256 _pid, uint256 _amount, address _user) 
        internal
        SlopesActive
        NonZeroAmount(_amount)
        HasStakedBalance(_pid, _user)
    {
        _updatePool(_pid);

        // Claim any pending FROST and Tokens
        _claim(_pid, _user);

        UserInfo storage user = userInfo[_pid][_user];
        PoolInfo memory pool = poolInfo[_pid];

        uint256 shares = ILoyalty(loyaltyAddress()).getTotalShares(_user, _amount);
        pool.totalShares = pool.totalShares.sub(shares);
        user.shares = user.shares.sub(shares);

        pool.totalStaked = pool.totalStaked.sub(_amount);
        user.staked = user.staked.sub(_amount);
        user.rewardDebt = user.shares.mul(pool.accFrostPerShare).div(1e12); // users frost debt by shares
        user.tokenRewardDebt = user.staked.mul(pool.accTokenPerShare).div(1e12); // taken in terms of tokens, not affected by boosts

        if (poolInfo[_pid].lpStaked) {
            _safeTokenTransfer(pool.lpToken, _user, _amount);
        } else {
            _safeTokenTransfer(pool.token, _user, _amount);
        }

        emit Withdraw(_user, _pid, _amount);
    }

    // Convenience function to allow users to migrate all of their staked FROST-ETH LP tokens 
    // from Accumulation to the Avalanche staking contract after the max supply is hit.
    function migrate() 
        external
        override
        AvalancheActive
        HasStakedBalance(0, msg.sender)
    {
        _updatePool(0);

        _claim(0, msg.sender);

        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        
        uint256 amountToMigrate = user.staked;
        address avalancheAddress = avalancheAddress();

        pool.totalShares = pool.totalShares.sub(user.shares);
        pool.totalStaked = pool.totalStaked.sub(user.staked);

        user.shares = 0;
        user.staked = 0;
        user.rewardDebt = 0;

        IERC20(pool.lpToken).safeApprove(avalancheAddress, 0);
        IERC20(pool.lpToken).safeApprove(avalancheAddress, amountToMigrate);
        IAvalanche(avalancheAddress).depositFor(address(this), msg.sender, amountToMigrate);

        emit Migrate(msg.sender, amountToMigrate);
    }

    function poolLength() 
        external
        override
        view 
        returns (uint256)
    {
        return poolInfo.length;
    }
    
    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() 
        external
        override
    {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            _updatePool(pid);
        }
    }

    // Add a new LP Token pool
    function addPool(
        address _token, 
        address _lpToken, 
        bool _lpStaked,
        uint256 _weight
    ) 
        external
        override 
        HasPatrol("ADMIN")
    {
        _addPool(_token, _lpToken, _lpStaked);

        if (_weight != DEFAULT_WEIGHT) {
            poolInfo[poolInfo.length-1].weight = _weight;
        } 
    }

    // Update the given pool's APR
    function setWeight(uint256 _pid, uint256 _weight)
        external
        override
        HasPatrol("ADMIN")
    {
        _updatePool(_pid);
        poolInfo[_pid].weight = _weight;
    }

    function setActive(uint256 _pid, bool _active)
        external
        HasPatrol("ADMIN")
    {
        _updatePool(_pid);
        poolInfo[_pid].active = _active;
    }

    function getSlopesStats(address _user)
        external
        view
        returns (bool _active, bool _accumulating, uint[20][] memory _stats)
    {
        _active = active;
        _accumulating = IFROST(frostAddress()).accumulating();
        _stats = new uint[20][](poolInfo.length);

        for (uint i = 0; i < poolInfo.length; i++) {
            _stats[i] = getPoolStats(_user, i);
        }
    }

    function getPoolStats(address _user, uint256 _pid)
        public
        view
        returns (uint[20] memory _pool)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        _pool[0] = pool.active ? 1 : 0;
        _pool[1] = pool.weight * IFROST(frostAddress()).currentBaseRate();
        _pool[2] = pool.lastReward;
        _pool[3] = pool.totalShares;
        _pool[4] = pool.totalStaked;
        _pool[5] = pool.accFrostPerShare;
        _pool[6] = pool.accTokenPerShare;
        _pool[7] = _getTokenPrice(pool.token, pool.lpToken);
        _pool[8] = _getLpTokenPrice(pool.lpToken);
        _pool[9] = stakingFee;
        _pool[10] = IERC20(pool.token).balanceOf(_user);
        _pool[11] = IERC20(pool.token).allowance(_user, address(this));
        _pool[12] = IERC20(pool.lpToken).balanceOf(_user);
        _pool[13] = IERC20(pool.lpToken).allowance(_user, address(this));
        _pool[14] = user.staked;
        _pool[15] = user.shares;
        _pool[16] = user.shares.mul(pool.accFrostPerShare).div(1e12).sub(user.rewardDebt); // pending frost rewards
        _pool[17] = user.staked.mul(pool.accTokenPerShare).div(1e12).sub(user.tokenRewardDebt); // pending token rewards
        _pool[18] = user.claimed;
        _pool[19] = user.tokenClaimed;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "./IERC20.sol";
import { SafeERC20 } from "./SafeERC20.sol";
import { SafeMath } from "./SafeMath.sol";
import { LendingPoolBase } from "./LendingPoolBase.sol";

abstract contract SlopesBase is LendingPoolBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor(address addressRegistry) internal {
        _setAddressRegistry(addressRegistry);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { SnowPatrolBase } from "./SnowPatrolBase.sol";
import { ISnowPatrol } from "./ISnowPatrol.sol";

contract SnowPatrol is ISnowPatrol, SnowPatrolBase {
    bytes32 public override constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public override constant LGE_ROLE = keccak256("LGE");
    bytes32 public override constant FROST_ROLE = keccak256("FROST");
    bytes32 public override constant SLOPES_ROLE = keccak256("SLOPES");
    bytes32 public override constant LODGE_ROLE = keccak256("LODGE");

    constructor(address addressRegistry)
        public
        SnowPatrolBase(addressRegistry)
    {
        // make owner user the sole superuser
        _initializeRoles(msg.sender);
        _initializeAdmins(msg.sender);
    }

    // inititalize all default roles, make the contract the superuser
    function _initializeRoles(address _deployer) private {
        _setupRole(DEFAULT_ADMIN_ROLE, _deployer);
        _setupRole(ADMIN_ROLE, _deployer);
        _setupRole(LGE_ROLE, _deployer);
        _setupRole(FROST_ROLE, _deployer);
        _setupRole(SLOPES_ROLE, _deployer);
        _setupRole(LODGE_ROLE, _deployer);
    }

     // grant admin role to dev addresses
    function _initializeAdmins(address _deployer) private {
        grantRole(ADMIN_ROLE, _deployer);
       
    }

    function setCoreRoles() 
        external
        override
    {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Only Admins can update contract roles"
        );

        // if 
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { AccessControl } from "./AccessControl.sol";
import { AddressBase } from "./AddressBase.sol";

abstract contract SnowPatrolBase is AccessControl, AddressBase {
    constructor(address addressRegistry) internal {
        _setAddressRegistry(addressRegistry);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { ERC20 } from './ERC20.sol';
import { IERC20 } from './IERC20.sol';
import { SafeERC20 } from './SafeERC20.sol';
import { SafeMath } from './SafeMath.sol';
import { IUniswapV2Pair } from './IUniswapV2Pair.sol';
import { IUniswapV2Router02 } from './IUniswapV2Router02.sol';
import { IAddressRegistry } from "./IAddressRegistry.sol";
import { IWETH } from "./IWETH.sol";
import { PatrolBase } from "./PatrolBase.sol";

abstract contract UniswapBase is PatrolBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public deadlineTime = 5 minutes;

    function _swapExactTokensForETH(
        uint256 _amount,
        address _token
    ) 
        internal
        NonZeroTokenBalance(_token)
        NonZeroAmount(_amount)
        returns (uint256)
    {
        require(
            IERC20(_token).balanceOf(address(this)) >= _amount,
            "Not enough tokens to swap"
        );

        address[] memory poolPath = new address[](2);
        poolPath[0] = address(_token);
        poolPath[1] = wethAddress();

        uint256 balanceBefore = address(this).balance;
        address uniswapRouter = uniswapRouterAddress();
        IERC20(_token).safeApprove(uniswapRouter, 0);
        IERC20(_token).safeApprove(uniswapRouter, _amount);
        IUniswapV2Router02(uniswapRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount, 
            0, 
            poolPath, 
            address(this), 
            _getDeadline()
        );
        return address(this).balance.sub(balanceBefore);
    }

    // swap eth for tokens, return amount of tokens bought
    function _swapExactETHForTokens(
        uint256 _amount,
        address _token
    ) 
        internal
        NonZeroAmount(_amount)
        returns (uint256)
    {
        address[] memory frostPath = new address[](2);
        frostPath[0] = wethAddress();
        frostPath[1] = _token;

        uint256 amountBefore = IERC20(_token).balanceOf(address(this));
        address uniswapRouter = uniswapRouterAddress();
        IERC20(wethAddress()).safeApprove(uniswapRouter, 0);
        IERC20(wethAddress()).safeApprove(uniswapRouter, _amount);
        IUniswapV2Router02(uniswapRouter)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{ value: _amount }(
                0, 
                frostPath, 
                address(this), 
                _getDeadline()
            );
        return IERC20(_token).balanceOf(address(this)).sub(amountBefore);
    }

    // swap exact tokens for tokens, always using weth as middle address
    function _swapExactTokensForTokens(
        uint256 _amount,
        address _tokenIn,
        address _tokenOut
    )
        internal
        NonZeroTokenBalance(_tokenIn)
        returns (uint256)
    {
        address[] memory frostPath = new address[](3);
        frostPath[0] = _tokenIn; 
        frostPath[1] = wethAddress();
        frostPath[2] = _tokenOut;

        uint256 amountBefore = IERC20(_tokenOut).balanceOf(address(this));
        address uniswapRouter = uniswapRouterAddress();
        IERC20(_tokenIn).safeApprove(uniswapRouter, 0);
        IERC20(_tokenIn).safeApprove(uniswapRouter, _amount);
        IUniswapV2Router02(uniswapRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amount,
            0, 
            frostPath, 
            address(this), 
            _getDeadline()
        );

        uint256 amountAfter = IERC20(_tokenOut).balanceOf(address(this));
        return amountAfter.sub(amountBefore);
    }

    // add liquidity on uniswap with _ethAmount, _tokenAmount to _token
    // return # lpTokens received
    function _addLiquidityETH(
        uint256 _ethAmount,
        uint256 _tokenAmount,
        address _token
    )
        internal
        NonZeroAmount(_ethAmount)
        NonZeroAmount(_tokenAmount)
        returns (uint256)
    {
        address uniswapRouter = IAddressRegistry(_addressRegistry).getUniswapRouter();

        IERC20(_token).safeApprove(uniswapRouter, 0);
        IERC20(_token).safeApprove(uniswapRouter, _tokenAmount);
        ( , , uint256 lpTokensReceived) = IUniswapV2Router02(uniswapRouter).addLiquidityETH{value: _ethAmount}(
            _token, 
            _tokenAmount, 
            0, 
            0, 
            address(this), 
            _getDeadline()
        );

        return lpTokensReceived;
    }
    
    // remove liquidity from _token with owned _amount LP token _lpToken
    function _removeLiquidityETH(
        uint256 _amount,
        address _lpToken,
        address _token
    ) 
        internal
        NonZeroAmount(_amount)
    {
        address uniswapRouter = uniswapRouterAddress();
        
        IERC20(_lpToken).safeApprove(uniswapRouter, 0);
        IERC20(_lpToken).safeApprove(uniswapRouter, _amount);
        IUniswapV2Router02(uniswapRouter).removeLiquidityETHSupportingFeeOnTransferTokens(
            _token, 
            _amount, 
            0, 
            0, 
            address(this), 
            _getDeadline()
        );
    }

    function _unwrapETH(uint256 _amount)
        internal
        NonZeroAmount(_amount)
    {
        IWETH(wethAddress()).withdraw(_amount);
    }

    // internal view function to view price of any token in ETH
    function _getTokenPrice(
        address _token,
        address _lpToken
    ) 
        public 
        view 
        returns (uint256) 
    {
        if (_token == wethAddress()) {
            return 1e18;
        }
        
        uint256 tokenBalance = IERC20(_token).balanceOf(_lpToken);
        if (tokenBalance > 0) {
            uint256 wethBalance = IERC20(wethAddress()).balanceOf(_lpToken);
            uint256 adjuster = 36 - uint256(ERC20(_token).decimals()); // handle non-base 18 tokens
            uint256 tokensPerEth = tokenBalance.mul(10**adjuster).div(wethBalance);
            return uint256(1e36).div(tokensPerEth); // price in gwei of token
        } else {
            return 0;
        }
    }

    function _getLpTokenPrice(address _lpToken)
        public
        view
        returns (uint256)
    {
        return IERC20(wethAddress()).balanceOf(_lpToken).mul(2).mul(1e18).div(IERC20(_lpToken).totalSupply());
    }

    function _getDeadline()
        internal
        view
        returns (uint256) 
    {
        return block.timestamp + 5 minutes;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "./IERC20.sol";
import { Context } from "./Context.sol";

abstract contract UtilitiesBase is Context {
    modifier NonZeroAmount(uint256 _amount) {
        require(
            _amount > 0, 
            "Amount must be greater than zero"
        );
        _;
    }

    modifier NonZeroTokenBalance(address _address) {
        require(
            IERC20(_address).balanceOf(address(this)) > 0,
            "No tokens to transfer"
        );
        _;
    }

    modifier NonZeroETHBalance(address _address) {
        require(
            address(this).balance > 0,
            "No ETH to transfer"
        );
        _;
    }

    modifier OnlyOrigin {
        require(
            tx.origin == address(this), 
            "Only origin contract can call this function"
        );
        _;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { VaultBase } from "./VaultBase.sol";
import { IERC20 } from "./IERC20.sol";
import { SafeERC20 } from "./SafeERC20.sol";
import { SafeMath } from "./SafeMath.sol";

contract Vault is VaultBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event VaultWithdrawal(address _user, address _token, uint256 _amount);

    mapping(uint256 => bool) checkpointWithdrawn;

    uint256 public lockEndTimestamp;
    uint256 public lockCheckpointOne;
    uint256 public lockCheckpointTwo;
    uint256 public lockCheckpointThree;
    uint256 public checkpointValue;

    modifier TimeLocked {
        require(
            block.timestamp >= lockEndTimestamp,
            "Vault timelock has not expired yet"
        );
        _;
    }

    receive() payable external {}

    constructor(address _address)
        public
        VaultBase(_address)
    {
        lockEndTimestamp = block.timestamp + 120 days;
        lockCheckpointOne = block.timestamp + 30 days;
        lockCheckpointTwo = block.timestamp + 60 days;
        lockCheckpointThree = block.timestamp + 90 days;
    }

    // called once after LGE
    function setCheckpointValues()
        external
        HasPatrol("ADMIN")
    {
        require(checkpointValue == 0, "Checkpoint has already been set");
        uint256 balance = IERC20(frostPoolAddress()).balanceOf(address(this));
        checkpointValue = balance.mul(30).div(100);
    }

    function withdraw(
        address _token,
        uint256 _amount
    )
        external
        TimeLocked
        HasPatrol("ADMIN")
    {
        if (address(this).balance > 0) {
            address(uint160(msg.sender)).transfer(address(this).balance);
        }
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit VaultWithdrawal(msg.sender, _token, _amount);
    }

    function checkpointWithdraw(uint256 _id)
        external
        HasPatrol("ADMIN")
    {
        if (_id == 1) {
            require(block.timestamp > lockCheckpointOne, "Too soon");
        } else if ( _id == 2) {
            require(block.timestamp > lockCheckpointTwo, "Too soon");
        } else if (_id == 3) {
            require(block.timestamp > lockCheckpointThree, "Too soon");
        } else {
            return;
        }

        IERC20(frostPoolAddress()).safeTransfer(msg.sender, checkpointValue);
    }
}
// SPDX-License-Identifier: MIT


pragma solidity ^0.6.12;

import { PatrolBase } from "./PatrolBase.sol";

contract VaultBase is PatrolBase {
    constructor(address addressRegistry) 
        public
    {
        _setAddressRegistry(addressRegistry);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

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
    function getRoleMember(bytes32 role, uint256 index)
        public
        view
        returns (address)
    {
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
        require(
            hasRole(_roles[role].adminRole, _msgSender()),
            "AccessControl: sender must be an admin to grant"
        );

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
        require(
            hasRole(_roles[role].adminRole, _msgSender()),
            "AccessControl: sender must be an admin to revoke"
        );

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
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );

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

pragma solidity ^0.6.2;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;

            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

pragma solidity >=0.6.0;

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

    function latestRound() external view returns (uint256);

    function getAnswer(uint256 roundId) external view returns (int256);

    function getTimestamp(uint256 roundId) external view returns (uint256);

    event AnswerUpdated(
        int256 indexed current,
        uint256 indexed roundId,
        uint256 timestamp
    );
    event NewRound(
        uint256 indexed roundId,
        address indexed startedBy,
        uint256 startedAt
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./AccessControl.sol";
import "./PriceFeed.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 */
contract Brrr is Context, IERC20, AccessControl, PriceFeed {
    bool public Online = true;
    modifier isOffline {
        _;
        require(!Online, "Contract is running still");
    }
    modifier isOnline {
        _;
        require(Online, "Contract has been turned off");
    }
    using SafeMath for uint256;
    using Address for address;
    IERC20 Tether;
    bytes32 public constant FOUNDING_FATHER = keccak256("FOUNDING_FATHER");

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    //list of accepted coins for transferring
    mapping(address => bool) public _acceptedStableCoins;
    //address of the oracle price feed for accept coins
    mapping(address => address) private _contract_address_to_oracle;
    //deposits for each user in eth
    mapping(address => uint256) public _deposits_eth;
    //total withdrawals per user
    mapping(address => uint256) public _total_withdrawals;
    //deposits for each user in their coins
    mapping(address => mapping(address => uint256)) public _coin_deposits;
    //claimed stimulus per user per stimulus
    mapping(address => mapping(uint128 => bool)) public _claimed_stimulus;
    //all stimulus ids
    mapping(uint128 => bool) public _all_Claim_ids;
    //stimulus id to stimulus info
    mapping(uint128 => Claims) public _all_Claims;
    //tether total supply checks/history
    supplyCheck[] public _all_supply_checks;
    //total coins related to tether in reserves
    uint256 public TreasuryReserve;
    uint256 private _totalSupply;
    //max limit
    uint256 public TOTALCAP = 8000000000000000 * 10**18;
    //total coins in circulation
    uint256 public _circulatingSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    //usdt address
    address public tether = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    //brrr3x address
    address public brrr3x;
    //brrr10x address
    address public brrr10x;

    struct Claims {
        uint256 _amount;
        uint256 _ending;
        uint256 _amount_to_give;
    }

    struct supplyCheck {
        uint256 _last_check;
        uint256 _totalSupply;
    }

    event Withdraw(address indexed _reciever, uint256 indexed _amount);

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * Sets the total supply from tether
     *
     * Gives founding father liquidity share for uniswap
     *
     * Sets first supply check
     *
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FOUNDING_FATHER, msg.sender);
        Tether = IERC20(tether);
        uint256 d = Tether.totalSupply();
        TreasuryReserve = d * 10**13;
        _balances[msg.sender] = 210000000 * 10**18;
        _circulatingSupply = 210000000 * 10**18;
        _totalSupply = TreasuryReserve.sub(_circulatingSupply);
        TreasuryReserve = TreasuryReserve.sub(_circulatingSupply);
        supplyCheck memory sa = supplyCheck(block.timestamp, d);
        _all_supply_checks.push(sa);
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

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _circulatingSupply.add(TreasuryReserve);
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     *  If address is approved brrr3x or brrr10x address don't check allowance and allow 1 transaction transfer (no approval needed)
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        if (msg.sender != brrr3x && msg.sender != brrr10x) {
            _approve(
                sender,
                _msgSender(),
                _allowances[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens from tether burning tokens
     *
     * Cannot go past cap.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function _printerGoesBrrr(uint256 amount) internal returns (bool) {
        require(amount > 0, "Can't mint 0 tokens");
        require(TreasuryReserve.add(amount) < cap(), "Cannot exceed cap");
        TreasuryReserve = TreasuryReserve.add(amount);
        _totalSupply = TreasuryReserve;
        emit Transfer(address(0), address(this), amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual isOnline {
        require(account != address(0), "ERC20: mint to the zero address");
        require(amount <= TreasuryReserve, "More than the reserve holds");

        _circulatingSupply = _circulatingSupply.add(amount);
        TreasuryReserve = TreasuryReserve.sub(amount);
        _totalSupply = TreasuryReserve;
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `TreasuryReserve`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `Treasury Reserve` must have at least `amount` tokens.
     */
    function _burn(uint256 amount) internal virtual {
        if (amount <= TreasuryReserve) {
            TreasuryReserve = TreasuryReserve.sub(
                amount,
                "ERC20: burn amount exceeds Treasury Reserve"
            );
            _totalSupply = TreasuryReserve;
            emit Transfer(address(this), address(0), amount);
        } else {
            TreasuryReserve = 0;
            _totalSupply = TreasuryReserve;
            emit Transfer(address(this), address(0), amount);
        }
    }

    /**
     * @dev Returns the users deposit in ETH and changes the circulating supply and treasury reserves based off the brrr sent back
     *
     *
     * Emits withdraw event.
     *
     *
     */
    function _payBackBrrrETH(
        uint256 _brrrAmount,
        address payable _owner,
        uint256 _returnAmount
    ) internal returns (bool) {
        require(
            _deposits_eth[_owner] >= _returnAmount,
            "More than deposit amount"
        );
        _balances[_owner] = _balances[_owner].sub(_brrrAmount);
        TreasuryReserve = TreasuryReserve.add(_brrrAmount);
        _totalSupply = TreasuryReserve;
        _circulatingSupply = _circulatingSupply.sub(_brrrAmount);
        emit Transfer(address(_owner), address(this), _brrrAmount);
        _deposits_eth[_owner] = _deposits_eth[_owner].sub(_returnAmount);
        _transferEth(_owner, _returnAmount);
        emit Withdraw(address(_owner), _returnAmount);
        return true;
    }

    /**
     * @dev Returns the users deposit in alt coins and changes the circulating supply and treasury reserves based off the brrr sent back
     *
     *
     * Emits withdraw event.
     *
     *
     */
    function _payBackBrrrCoins(
        uint256 _brrrAmount,
        address payable _owner,
        address _contract,
        uint256 _returnAmount
    ) internal returns (bool) {
        require(
            _coin_deposits[_owner][_contract] >= _returnAmount,
            "More than deposit amount"
        );
        _balances[_owner] = _balances[_owner].sub(_brrrAmount);
        TreasuryReserve = TreasuryReserve.add(_brrrAmount);
        _totalSupply = TreasuryReserve;
        _circulatingSupply = _circulatingSupply.sub(_brrrAmount);
        emit Transfer(address(_owner), address(this), _brrrAmount);
        _coin_deposits[_owner][_contract] = _coin_deposits[_owner][_contract]
            .sub(_returnAmount);
        _transferCoin(_owner, _contract, _returnAmount);
        emit Withdraw(address(_owner), _returnAmount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Gives user reward for updating the total supply.
     */
    function _giveReward(uint256 reward) internal returns (bool) {
        _circulatingSupply = _circulatingSupply.add(reward);
        _balances[_msgSender()] = _balances[_msgSender()].add(reward);
        emit Transfer(address(this), address(_msgSender()), reward);
        return true;
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
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return TOTALCAP;
    }

    /**
     * @dev Returns the price of the bonding curve divided by number of withdrawals the user has already made.
     *
     * Prevents spamming deposit -> withdrawal -> deposit... to drain all brrr.
     */
    function calculateWithdrawalPrice() internal view returns (uint256) {
        uint256 p = calculateCurve();
        uint256 w = _total_withdrawals[_msgSender()];
        if (w < 1) {
            w = 1;
        }
        p = p.div(w);
        return p;
    }

    /**
     * @dev Internal transfer eth function
     *
     */
    function _transferEth(address payable _recipient, uint256 _amount)
        internal
        returns (bool)
    {
        _recipient.transfer(_amount);
        return true;
    }

    /**
     * @dev Internal transfer altcoin function
     *
     */
    function _transferCoin(
        address _owner,
        address _contract,
        uint256 _returnAmount
    ) internal returns (bool) {
        IERC20 erc;
        erc = IERC20(_contract);
        require(
            erc.balanceOf(address(this)) >= _returnAmount,
            "Not enough funds to transfer"
        );
        require(erc.transfer(_owner, _returnAmount));
        return true;
    }

    /**@dev Adds another token to the accepted coins for printing
     *
     *
     * Calling conditions:
     *
     * - Address of the contract to be added
     * - Only can be added by founding fathers
     * */
    function addAcceptedStableCoin(address _contract, address _oracleAddress)
        public
        isOnline
        returns (bool)
    {
        require(
            hasRole(FOUNDING_FATHER, msg.sender),
            "Caller is not a Founding Father"
        );
        _acceptedStableCoins[_contract] = true;
        _contract_address_to_oracle[_contract] = _oracleAddress;
        return _acceptedStableCoins[_contract];
    }

    /**@dev Adds stimulus package to be claimed by users
     *
     *
     * Calling conditions:
     * - Only can be added by founding fathers
     * */
    function addStimulus(
        uint128 _id,
        uint256 _total_amount,
        uint256 _ending_in_days,
        uint256 _amount_to_get
    ) public isOnline returns (bool) {
        require(
            hasRole(FOUNDING_FATHER, msg.sender),
            "Caller is not a Founding Father"
        );
        require(_all_Claim_ids[_id] == false, "ID already used");
        require(_total_amount <= TreasuryReserve);
        _all_Claim_ids[_id] = true;
        _all_Claims[_id]._amount = _total_amount * 10**18;
        _all_Claims[_id]._amount_to_give = _amount_to_get;
        _all_Claims[_id]._ending = block.timestamp + (_ending_in_days * 1 days);
        return true;
    }

    /**@dev Claim a stimulus package.
     *
     * requires _id of stimulus package.
     * Calling conditions:
     * - can only claim once
     * - must not be ended
     * - must not be out of funds.
     * */
    function claimStimulus(uint128 _id) public isOnline returns (bool) {
        require(_all_Claim_ids[_id], "Claim not valid");
        require(
            _claimed_stimulus[_msgSender()][_id] == false,
            "Already claimed!"
        );
        require(
            block.timestamp <= _all_Claims[_id]._ending,
            "Stimulus package has ended"
        );
        require(
            _all_Claims[_id]._amount >= _all_Claims[_id]._amount_to_give,
            "Out of money :("
        );
        _claimed_stimulus[_msgSender()][_id] = true;
        _all_Claims[_id]._amount = _all_Claims[_id]._amount.sub(
            _all_Claims[_id]._amount_to_give * 10**18
        );
        _mint(_msgSender(), _all_Claims[_id]._amount_to_give * 10**18);
        return true;
    }

    /**  Bonding curve
     * circulating * reserve ratio / total supply
     * circulating * .10 / totalSupply
     *
     * */
    function calculateCurve() public override view returns (uint256) {
        uint256 p = (
            (_circulatingSupply.mul(10).div(100) * 10**18).div(TreasuryReserve)
        );
        if (p <= 0) {
            p = 1;
        }
        return p;
    }

    /**@dev Deposit eth and get the value of brrr based off bonding curve
     *
     *
     * */
    function printWithETH() public payable isOnline returns (bool) {
        require(
            msg.value > 0,
            "Please send money to make the printer go brrrrrrrr"
        );
        uint256 p = calculateCurve();
        uint256 amount = (msg.value.mul(10**18).div(p));
        require(amount > 0, "Not enough sent for 1 brrr");
        _deposits_eth[_msgSender()] = _deposits_eth[_msgSender()].add(
            msg.value
        );
        _mint(_msgSender(), amount);
        return true;
    }

    /**@dev Deposit alt coins and get the value of brrr based off bonding curve
     *
     *
     * */
    function printWithStablecoin(address _contract, uint256 _amount)
        public
        isOnline
        returns (bool)
    {
        require(
            _acceptedStableCoins[_contract],
            "Not accepted as a form of payment"
        );
        IERC20 erc;
        erc = IERC20(_contract);
        uint256 al = erc.allowance(_msgSender(), address(this));
        require(al >= _amount, "Token allowance not enough");
        uint256 p = calculateCurve();
        uint256 tp = getLatestPrice(_contract_address_to_oracle[_contract]);
        uint256 a = _amount.mul(tp).div(p);
        require(a > 0, "Not enough sent for 1 brrr");
        require(
            erc.transferFrom(_msgSender(), address(this), _amount),
            "Transfer failed"
        );
        _coin_deposits[_msgSender()][_contract] = _coin_deposits[_msgSender()][_contract]
            .add(_amount);
        _mint(_msgSender(), a);
        return true;
    }

    /**@dev Internal transfer from brrr3x or brrr10x in order to transfer and update balances
     *
     *
     * */
    function _transferBrr(address _contract) internal returns (bool) {
        IERC20 brr;
        brr = IERC20(_contract);
        uint256 brrbalance = brr.balanceOf(_msgSender());
        if (brrbalance > 0) {
            require(
                brr.transferFrom(_msgSender(), address(this), brrbalance),
                "Transfer failed"
            );
            _mint(_msgSender(), brrbalance);
        }
        return true;
    }

    /**@dev Transfers entire brrrX balance into brrr at 1 to 1
     *  Deposits on brrrX will not be cleared.
     *
     * */
    function convertBrrrXintoBrrr() public isOnline returns (bool) {
        _transferBrr(address(brrr3x));
        _transferBrr(address(brrr10x));
        return true;
    }

    /**@dev Deposit brrr and get the value of eth for that amount of brrr based off bonding curve
     *
     *
     * */
    function returnBrrrForETH() public isOnline returns (bool) {
        require(_deposits_eth[_msgSender()] > 0, "You have no deposits");
        require(_balances[_msgSender()] > 0, "No brrr balance");
        uint256 p = calculateWithdrawalPrice();
        uint256 r = _deposits_eth[_msgSender()].div(p).mul(10**18);
        if (_balances[_msgSender()] >= r) {
            _payBackBrrrETH(r, _msgSender(), _deposits_eth[_msgSender()]);
        } else {
            uint256 t = _balances[_msgSender()].mul(p).div(10**18);
            require(
                t <= _balances[_msgSender()],
                "More than in your balance, error with math"
            );
            _payBackBrrrETH(_balances[_msgSender()], _msgSender(), t);
        }
        _total_withdrawals[_msgSender()] = _total_withdrawals[_msgSender()].add(
            1
        );
    }

    /**@dev Deposit brrr and get the value of alt coins for that amount of brrr based off bonding curve
     *
     *
     * */
    function returnBrrrForCoins(address _contract)
        public
        isOnline
        returns (bool)
    {
        require(
            _acceptedStableCoins[_contract],
            "Not accepted as a form of payment"
        );
        require(
            _coin_deposits[_msgSender()][_contract] != 0,
            "You have no deposits"
        );
        require(_balances[_msgSender()] > 0, "No brrr balance");
        uint256 o = calculateWithdrawalPrice();
        uint256 rg = getLatestPrice(_contract_address_to_oracle[_contract]);
        uint256 y = _coin_deposits[_msgSender()][_contract].mul(rg).div(o);
        if (_balances[_msgSender()] >= y) {
            _payBackBrrrCoins(
                y,
                _msgSender(),
                _contract,
                _coin_deposits[_msgSender()][_contract]
            );
        } else {
            uint256 t = _balances[_msgSender()].mul(o).div(rg).div(10**18);
            require(
                t <= _balances[_msgSender()],
                "More than in your balance, error with math"
            );
            _payBackBrrrCoins(
                _balances[_msgSender()],
                _msgSender(),
                _contract,
                t
            );
        }
        _total_withdrawals[_msgSender()] = _total_withdrawals[_msgSender()].add(
            1
        );
    }

    /**@dev Update the total supply from tether - if tether has changed total supply.
     *
     * Makes the money printer go brrrrrrrr
     * Reward is given to whoever updates
     * */
    function brrrEvent() public isOnline returns (uint256) {
        require(
            block.timestamp >
                _all_supply_checks[_all_supply_checks.length.sub(1)]
                    ._last_check,
            "Already checked!"
        );
        uint256 l = _all_supply_checks[_all_supply_checks.length.sub(1)]
            ._last_check;
        uint256 s = _all_supply_checks[_all_supply_checks.length.sub(1)]
            ._totalSupply;
        uint256 d = Tether.totalSupply();
        require(d != s, "The supply hasn't changed");
        if (d < s) {
            supplyCheck memory sa = supplyCheck(block.timestamp, d);
            _all_supply_checks.push(sa);
            d = (s.sub(d)) * 10**12;
            uint256 reward = d.div(1000);
            d = d.sub(reward);
            _printerGoesBrrr(d);
            _giveReward(reward);
            return reward;
        }
        if (d > s) {
            supplyCheck memory sa = supplyCheck(block.timestamp, d);
            _all_supply_checks.push(sa);
            d = (d.sub(s)) * 10**12;
            uint256 reward = d.div(1000);
            d = d.sub(reward);
            _burn(d);
            _giveReward(reward);
            return reward;
        }
    }

    /**@dev In case of emgergency - withdrawal all eth.
     *
     * Contract must be offline
     *
     * */
    function EmergencyWithdrawalETH() public isOffline returns (bool) {
        require(!Online, "Contract is not turned off");
        require(_deposits_eth[_msgSender()] > 0, "You have no deposits");
        _payBackBrrrETH(
            _balances[_msgSender()],
            _msgSender(),
            _deposits_eth[_msgSender()]
        );
        return true;
    }

    /**@dev In case of emgergency - withdrawal all coins.
     *
     * Contract must be offline
     *
     * */
    function EmergencyWithdrawalCoins(address _contract)
        public
        isOffline
        returns (bool)
    {
        require(!Online, "Contract is not turned off");
        require(
            _acceptedStableCoins[_contract],
            "Not accepted as a form of payment"
        );
        require(
            _coin_deposits[_msgSender()][_contract] != 0,
            "You have no deposits"
        );
        _payBackBrrrCoins(
            _balances[_msgSender()],
            _msgSender(),
            _contract,
            _coin_deposits[_msgSender()][_contract]
        );
        return true;
    }

    /**@dev In case of emgergency - turn offline.
     *
     * Must be admin
     *
     * */
    function toggleOffline() public returns (bool) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );
        Online = !Online;
        return true;
    }

    /**@dev Set brrrX addresses. One time, cannot be changed.
     *
     * Must be admin
     *
     * */
    function setBrrrXAddress(address _brrr3xcontract, address _brrr10xcontract)
        public
        returns (bool)
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );
        require(
            brrr3x == address(0x0) && brrr10x == address(0x0),
            "Already set the addresses"
        );
        if (_brrr3xcontract != address(0x0)) {
            brrr3x = _brrr3xcontract;
        }
        if (_brrr10xcontract != address(0x0)) {
            brrr10x = _brrr10xcontract;
        }
    }

    fallback() external payable {
        printWithETH();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./AccessControl.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 */
contract Brrr10x is Context, IERC20, AccessControl {
    bool public Online = true;
    modifier isOffline {
        _;
        require(!Online, "Contract is running still");
    }
    modifier isOnline {
        _;
        require(Online, "Contract has been turned off");
    }
    using SafeMath for uint256;
    using Address for address;
    IERC20 Tether;
    bytes32 public constant FOUNDING_FATHER = keccak256("FOUNDING_FATHER");

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) public _deposits_brrr;

    mapping(address => uint256) public _total_withdrawals;

    supplyCheck[] public _all_supply_checks;
    uint256 public TreasuryReserve;
    uint256 private _totalSupply;
    uint256 public TOTALCAP = 8000000000000000 * 10**18;

    uint256 private _circulatingSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address public tether = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public brrr;

    struct supplyCheck {
        uint256 _last_check;
        uint256 _totalSupply;
    }

    event Withdraw(address indexed _reciever, uint256 indexed _amount);

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name,
        string memory symbol,
        address _brrr
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        brrr = _brrr;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FOUNDING_FATHER, msg.sender);
        Tether = IERC20(tether);
        _balances[msg.sender] = 100000000 * 10**18;
        _circulatingSupply = 100000000 * 10**18;
        uint256 d = Tether.totalSupply();
        TreasuryReserve = d * 10**12;
        _totalSupply = TreasuryReserve;
        supplyCheck memory sa = supplyCheck(block.timestamp, d);
        _all_supply_checks.push(sa);
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
    function totalSupply() public override view returns (uint256) {
        return _circulatingSupply.add(TreasuryReserve);
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        if (msg.sender != brrr) {
            _approve(
                sender,
                _msgSender(),
                _allowances[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        }
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens from tether burning tokens
     *
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function _printerGoesBrrr(uint256 amount) internal returns (bool) {
        require(amount > 0, "Can't mint 0 tokens");
        require(TreasuryReserve.add(amount) < cap(), "Cannot exceed cap");
        TreasuryReserve = TreasuryReserve.add(amount);
        _totalSupply = TreasuryReserve;
        emit Transfer(address(0), address(this), amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual isOnline {
        require(account != address(0), "ERC20: mint to the zero address");
        require(amount <= TreasuryReserve, "More than the reserve holds");

        _circulatingSupply = _circulatingSupply.add(amount);
        _totalSupply = _totalSupply.sub(amount);
        TreasuryReserve = TreasuryReserve.sub(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `TreasuryReserve`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `Treasury Reserve` must have at least `amount` tokens.
     */
    function _burn(uint256 amount) internal virtual {
        if (amount <= TreasuryReserve) {
            TreasuryReserve = TreasuryReserve.sub(
                amount,
                "ERC20: burn amount exceeds Treasury Reserve"
            );
            _totalSupply = TreasuryReserve;
            emit Transfer(address(this), address(0), amount);
        } else {
            TreasuryReserve = 0;
            _totalSupply = TreasuryReserve;
            emit Transfer(address(this), address(0), amount);
        }
    }

    function _payBackBrrr(
        uint256 _brrrAmount,
        address payable _owner,
        uint256 _returnAmount
    ) internal returns (bool) {
        require(
            _deposits_brrr[_owner] >= _returnAmount,
            "More than deposit amount"
        );
        _balances[_owner] = _balances[_owner].sub(_brrrAmount);
        TreasuryReserve = TreasuryReserve.add(_brrrAmount);
        _totalSupply = TreasuryReserve;
        _circulatingSupply = _circulatingSupply.sub(_brrrAmount);
        emit Transfer(address(_owner), address(this), _brrrAmount);
        _deposits_brrr[_owner] = _deposits_brrr[_owner].sub(_returnAmount);
        _transferCoin(_owner, brrr, _returnAmount);
        emit Withdraw(address(_owner), _returnAmount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return TOTALCAP;
    }

    function calculateWithdrawalPrice() internal view returns (uint256) {
        uint256 p = calculateCurve();
        uint256 w = _total_withdrawals[_msgSender()];
        if (w < 1) {
            w = 1;
        }
        p = p.div(w);
        return p;
    }

    function _transferEth(address payable _recipient, uint256 _amount)
        internal
        returns (bool)
    {
        _recipient.transfer(_amount);
        return true;
    }

    function _transferCoin(
        address _owner,
        address _contract,
        uint256 _returnAmount
    ) internal returns (bool) {
        IERC20 erc;
        erc = IERC20(_contract);
        require(
            erc.balanceOf(address(this)) >= _returnAmount,
            "Not enough funds to transfer"
        );
        require(erc.transfer(_owner, _returnAmount));
        return true;
    }

    /**  Bonding curve
     * circulating * reserve ratio / total supply
     * circulating * .50 / totalSupply
     *
     * */
    function calculateCurve() public override view returns (uint256) {
        return (
            (_circulatingSupply.mul(50).div(100) * 10**18).div(TreasuryReserve)
        );
    }

    function printWithBrrr(uint256 _amount) public isOnline returns (bool) {
        require(brrr != address(0x0), "Brrr contract not set");
        IERC20 brr;
        brr = IERC20(brrr);
        uint256 al = brr.balanceOf(_msgSender());
        require(al >= _amount, "Token balance not enough");
        uint256 p = calculateCurve();
        uint256 tp = brr.calculateCurve();
        uint256 a = _amount.mul(tp).div(p);
        require(a > 0, "Not enough sent for 1 brrr");
        require(
            brr.transferFrom(_msgSender(), address(this), _amount),
            "Transfer failed"
        );
        _deposits_brrr[_msgSender()] = _deposits_brrr[_msgSender()].add(
            _amount
        );
        _mint(_msgSender(), a);
        return true;
    }

    function returnBrrrForBrrr() public isOnline returns (bool) {
        require(brrr != address(0x0), "Brrr contract not set");
        require(_deposits_brrr[_msgSender()] != 0, "You have no deposits");
        require(_balances[_msgSender()] > 0, "No brrr balance");
        uint256 o = calculateWithdrawalPrice();
        uint256 rg = _deposits_brrr[_msgSender()].div(o).mul(10**18);
        if (_balances[_msgSender()] >= rg) {
            _payBackBrrr(rg, _msgSender(), _deposits_brrr[_msgSender()]);
        } else {
            uint256 t = _balances[_msgSender()].mul(o).div(10**18);
            require(
                t <= _balances[_msgSender()],
                "More than in your balance, error with math"
            );
            _payBackBrrr(_balances[_msgSender()], _msgSender(), t);
        }
        _total_withdrawals[_msgSender()] = _total_withdrawals[_msgSender()].add(
            1
        );
    }

    /**@dev Update the total supply from tether - if tether has changed total supply.
     *
     * Makes the money printer go brrrrrrrr
     * Reward is given to whoever updates
     * */
    function brrrEvent() public isOnline returns (uint256) {
        require(
            block.timestamp >
                _all_supply_checks[_all_supply_checks.length.sub(1)]
                    ._last_check,
            "Already checked!"
        );
        uint256 l = _all_supply_checks[_all_supply_checks.length.sub(1)]
            ._last_check;
        uint256 s = _all_supply_checks[_all_supply_checks.length.sub(1)]
            ._totalSupply;
        uint256 d = Tether.totalSupply();
        require(d != s, "The supply hasn't changed");
        if (d < s) {
            supplyCheck memory sa = supplyCheck(block.timestamp, d);
            _all_supply_checks.push(sa);
            d = (s.sub(d)) * 10**12;
            uint256 reward = d.div(1000);
            d = d.sub(reward);
            _printerGoesBrrr(d.mul(10));
            _circulatingSupply = _circulatingSupply.add(reward);
            _balances[_msgSender()] = _balances[_msgSender()].add(reward);
            emit Transfer(address(this), address(_msgSender()), reward);
            return reward;
        }
        if (d > s) {
            supplyCheck memory sa = supplyCheck(block.timestamp, d);
            _all_supply_checks.push(sa);
            d = (d.sub(s)) * 10**12;
            uint256 reward = d.div(1000);
            d = d.sub(reward);
            _burn(d.mul(10));
            _circulatingSupply = _circulatingSupply.add(reward);
            _balances[_msgSender()] = _balances[_msgSender()].add(reward);
            emit Transfer(address(this), address(_msgSender()), reward);
            return reward;
        }
    }

    function EmergencyWithdrawal() public isOffline returns (bool) {
        require(!Online, "Contract is not turned off");
        require(_deposits_brrr[_msgSender()] > 0, "You have no deposits");
        _payBackBrrr(
            _balances[_msgSender()],
            _msgSender(),
            _deposits_brrr[_msgSender()]
        );
        return true;
    }

    function toggleOffline() public returns (bool) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );
        Online = !Online;
        return true;
    }

    function setBrrrAddress(address _brrrcontract) public returns (bool) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );

        require(_brrrcontract != address(0x0), "Invalid address!");
        brrr = _brrrcontract;
    }

    fallback() external payable {
        revert();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./AccessControl.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 */
contract Brrr3x is Context, IERC20, AccessControl {
    bool public Online = true;
    modifier isOffline {
        _;
        require(!Online, "Contract is running still");
    }
    modifier isOnline {
        _;
        require(Online, "Contract has been turned off");
    }
    using SafeMath for uint256;
    using Address for address;
    IERC20 Tether;
    bytes32 public constant FOUNDING_FATHER = keccak256("FOUNDING_FATHER");

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) public _deposits_brrr;

    mapping(address => uint256) public _total_withdrawals;

    supplyCheck[] public _all_supply_checks;
    uint256 public TreasuryReserve;
    uint256 private _totalSupply;
    uint256 public TOTALCAP = 8000000000000000 * 10**18;

    uint256 private _circulatingSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address public tether = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public brrr;

    struct supplyCheck {
        uint256 _last_check;
        uint256 _totalSupply;
    }

    event Withdraw(address indexed _reciever, uint256 indexed _amount);

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name,
        string memory symbol,
        address _brrr
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        brrr = _brrr;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FOUNDING_FATHER, msg.sender);
        Tether = IERC20(tether);
        _balances[msg.sender] = 100000000 * 10**18;
        _circulatingSupply = 100000000 * 10**18;
        uint256 d = Tether.totalSupply();
        TreasuryReserve = d * 10**12;
        _totalSupply = TreasuryReserve;
        supplyCheck memory sa = supplyCheck(block.timestamp, d);
        _all_supply_checks.push(sa);
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
    function totalSupply() public override view returns (uint256) {
        return _circulatingSupply.add(TreasuryReserve);
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        if (msg.sender != brrr) {
            _approve(
                sender,
                _msgSender(),
                _allowances[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        }
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens from tether burning tokens
     *
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function _printerGoesBrrr(uint256 amount) internal returns (bool) {
        require(amount > 0, "Can't mint 0 tokens");
        require(TreasuryReserve.add(amount) < cap(), "Cannot exceed cap");
        TreasuryReserve = TreasuryReserve.add(amount);
        _totalSupply = TreasuryReserve;
        emit Transfer(address(0), address(this), amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual isOnline {
        require(account != address(0), "ERC20: mint to the zero address");
        require(amount <= TreasuryReserve, "More than the reserve holds");

        _circulatingSupply = _circulatingSupply.add(amount);
        _totalSupply = _totalSupply.sub(amount);
        TreasuryReserve = TreasuryReserve.sub(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `TreasuryReserve`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `Treasury Reserve` must have at least `amount` tokens.
     */
    function _burn(uint256 amount) internal virtual {
        if (amount <= TreasuryReserve) {
            TreasuryReserve = TreasuryReserve.sub(
                amount,
                "ERC20: burn amount exceeds Treasury Reserve"
            );
            _totalSupply = TreasuryReserve;
            emit Transfer(address(this), address(0), amount);
        } else {
            TreasuryReserve = 0;
            _totalSupply = TreasuryReserve;
            emit Transfer(address(this), address(0), amount);
        }
    }

    function _payBackBrrr(
        uint256 _brrrAmount,
        address payable _owner,
        uint256 _returnAmount
    ) internal returns (bool) {
        require(
            _deposits_brrr[_owner] >= _returnAmount,
            "More than deposit amount"
        );
        _balances[_owner] = _balances[_owner].sub(_brrrAmount);
        TreasuryReserve = TreasuryReserve.add(_brrrAmount);
        _totalSupply = TreasuryReserve;
        _circulatingSupply = _circulatingSupply.sub(_brrrAmount);
        emit Transfer(address(_owner), address(this), _brrrAmount);
        _deposits_brrr[_owner] = _deposits_brrr[_owner].sub(_returnAmount);
        _transferCoin(_owner, brrr, _returnAmount);
        emit Withdraw(address(_owner), _returnAmount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return TOTALCAP;
    }

    function calculateWithdrawalPrice() internal view returns (uint256) {
        uint256 p = calculateCurve();
        uint256 w = _total_withdrawals[_msgSender()];
        if (w < 1) {
            w = 1;
        }
        p = p.div(w);
        return p;
    }

    function _transferEth(address payable _recipient, uint256 _amount)
        internal
        returns (bool)
    {
        _recipient.transfer(_amount);
        return true;
    }

    function _transferCoin(
        address _owner,
        address _contract,
        uint256 _returnAmount
    ) internal returns (bool) {
        IERC20 erc;
        erc = IERC20(_contract);
        require(
            erc.balanceOf(address(this)) >= _returnAmount,
            "Not enough funds to transfer"
        );
        require(erc.transfer(_owner, _returnAmount));
        return true;
    }

    /**  Bonding curve
     * circulating * reserve ratio / total supply
     * circulating * .50 / totalSupply
     *
     * */
    function calculateCurve() public override view returns (uint256) {
        return (
            (_circulatingSupply.mul(50).div(100) * 10**18).div(TreasuryReserve)
        );
    }

    function printWithBrrr(uint256 _amount) public isOnline returns (bool) {
        require(brrr != address(0x0), "Brrr contract not set");
        IERC20 brr;
        brr = IERC20(brrr);
        uint256 al = brr.balanceOf(_msgSender());
        require(al >= _amount, "Token balance not enough");
        uint256 p = calculateCurve();
        uint256 tp = brr.calculateCurve();
        uint256 a = _amount.mul(tp).div(p);
        require(a > 0, "Not enough sent for 1 brrr");
        require(
            brr.transferFrom(_msgSender(), address(this), _amount),
            "Transfer failed"
        );
        _deposits_brrr[_msgSender()] = _deposits_brrr[_msgSender()].add(
            _amount
        );
        _mint(_msgSender(), a);
        return true;
    }

    function returnBrrrForBrrr() public isOnline returns (bool) {
        require(brrr != address(0x0), "Brrr contract not set");
        require(_deposits_brrr[_msgSender()] != 0, "You have no deposits");
        require(_balances[_msgSender()] > 0, "No brrr balance");
        uint256 o = calculateWithdrawalPrice();
        uint256 rg = _deposits_brrr[_msgSender()].div(o).mul(10**18);
        if (_balances[_msgSender()] >= rg) {
            _payBackBrrr(rg, _msgSender(), _deposits_brrr[_msgSender()]);
        } else {
            uint256 t = _balances[_msgSender()].mul(o).div(10**18);
            require(
                t <= _balances[_msgSender()],
                "More than in your balance, error with math"
            );
            _payBackBrrr(_balances[_msgSender()], _msgSender(), t);
        }
        _total_withdrawals[_msgSender()] = _total_withdrawals[_msgSender()].add(
            1
        );
    }

    /**@dev Update the total supply from tether - if tether has changed total supply.
     *
     * Makes the money printer go brrrrrrrr
     * Reward is given to whoever updates
     * */
    function brrrEvent() public isOnline returns (uint256) {
        require(
            block.timestamp >
                _all_supply_checks[_all_supply_checks.length.sub(1)]
                    ._last_check,
            "Already checked!"
        );
        uint256 l = _all_supply_checks[_all_supply_checks.length.sub(1)]
            ._last_check;
        uint256 s = _all_supply_checks[_all_supply_checks.length.sub(1)]
            ._totalSupply;
        uint256 d = Tether.totalSupply();
        require(d != s, "The supply hasn't changed");
        if (d < s) {
            supplyCheck memory sa = supplyCheck(block.timestamp, d);
            _all_supply_checks.push(sa);
            d = (s.sub(d)) * 10**12;
            uint256 reward = d.div(1000);
            d = d.sub(reward);
            _printerGoesBrrr(d.mul(3));
            _circulatingSupply = _circulatingSupply.add(reward);
            _balances[_msgSender()] = _balances[_msgSender()].add(reward);
            emit Transfer(address(this), address(_msgSender()), reward);
            return reward;
        }
        if (d > s) {
            supplyCheck memory sa = supplyCheck(block.timestamp, d);
            _all_supply_checks.push(sa);
            d = (d.sub(s)) * 10**12;
            uint256 reward = d.div(1000);
            d = d.sub(reward);
            _burn(d.mul(3));
            _circulatingSupply = _circulatingSupply.add(reward);
            _balances[_msgSender()] = _balances[_msgSender()].add(reward);
            emit Transfer(address(this), address(_msgSender()), reward);
            return reward;
        }
    }

    function EmergencyWithdrawal() public isOffline returns (bool) {
        require(!Online, "Contract is not turned off");
        require(_deposits_brrr[_msgSender()] > 0, "You have no deposits");
        _payBackBrrr(
            _balances[_msgSender()],
            _msgSender(),
            _deposits_brrr[_msgSender()]
        );
        return true;
    }

    function toggleOffline() public returns (bool) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );
        Online = !Online;
        return true;
    }

    function setBrrrAddress(address _brrrcontract) public returns (bool) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not an admin"
        );

        require(_brrrcontract != address(0x0), "Invalid address!");
        brrr = _brrrcontract;
    }

    fallback() external payable {
        revert();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
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
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
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
    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
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
    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
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
    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
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
    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
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
    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
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
    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function calculateCurve() external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity ^0.6.7;

import "./AggregatorInterface.sol";

contract PriceFeed {
    /**
     * Network: Rinkeby
     * Aggregator: ETH/USD
     * Address: 0x0bF4e7bf3e1f6D6Dc29AA516A33134985cC3A5aA
     */
    /**
     * Returns the latest price
     */
    function getLatestPrice(address _address) internal view returns (uint256) {
        AggregatorInterface priceFeed = AggregatorInterface(_address);
        int256 p = priceFeed.latestAnswer();
        require(p > 0, "Invalid price feed!");
        return uint256(p);
    }

    /**
     * Returns the timestamp of the latest price update
     */
    function getLatestPriceTimestamp(address _address)
        internal
        view
        returns (uint256)
    {
        AggregatorInterface priceFeed = AggregatorInterface(_address);
        return priceFeed.latestTimestamp();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

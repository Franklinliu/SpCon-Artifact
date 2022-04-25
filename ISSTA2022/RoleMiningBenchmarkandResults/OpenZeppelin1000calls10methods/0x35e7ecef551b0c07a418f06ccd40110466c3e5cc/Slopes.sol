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

pragma solidity >=0.6.0 <0.8.0;

import "../../GSN/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

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

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    event PwdrUpdated(address indexed newAddress);
    event PwdrPoolUpdated(address indexed newAddress);
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

    function getPwdr() external view returns (address);
    function setPwdr(address _address) external;

    function getPwdrPool() external view returns (address);
    function setPwdrPool(address _address) external;

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
    event Claim(address indexed user, uint256 pwdrAmount);    
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event PwdrRewardAdded(address indexed user, uint256 pwdrReward);
    event EthRewardAdded(address indexed user, uint256 ethReward);

    function active() external view returns (bool);
    function activate() external;

    function addPwdrReward(address _from, uint256 _amount) external;
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

interface IPWDR {
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

interface ISlopes {
    event Activated(address user);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 pwdrAmount, uint256 tokenAmount);
    event ClaimAll(address indexed user, uint256 pwdrAmount, uint256[] tokenAmounts);
    event Migrate(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    // event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event PwdrPurchase(address indexed user, uint256 ethSpentOnPwdr, uint256 pwdrBought);

    function active() external view returns (bool);
    function pwdrSentToAvalanche() external view returns (uint256);
    function stakingFee() external view returns (uint256);
    function roundRobinFee() external view returns (uint256);
    function protocolFee() external view returns (uint256);

    function activate() external;
    function massUpdatePools() external;
    function updatePool(uint256 _pid) external;
    // function addPwdrReward(address _from, uint256 _amount) external virtual;
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

import { AltitudeBase } from "../utils/AltitudeBase.sol";

interface ISnowPatrol {
    function ADMIN_ROLE() external pure returns (bytes32);
    function LGE_ROLE() external pure returns (bytes32);
    function PWDR_ROLE() external pure returns (bytes32);
    function SLOPES_ROLE() external pure returns (bytes32);
    function setCoreRoles() external;
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

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IFlashLoanReceiver } from "../interfaces/IFlashLoanReceiver.sol";
import { ILoyalty } from "../interfaces/ILoyalty.sol";
import { ILendingPool } from "../interfaces/ILendingPool.sol";
import { MultiPoolBase } from "./MultiPoolBase.sol";

contract LendingPoolBase is ILendingPool, MultiPoolBase {
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
        // save balances before and ensure enough of reserve is available to complete
        // the request
        uint256 tokensAvailableBefore = _getReservesAvailable(_token);
        require(
            tokensAvailableBefore >= _amount,
            "Not enough token available to complete transaction"
        );

        // get the total fee for the loan and validate it is large enough
        uint256 totalFee = ILoyalty(loyaltyAddress()).getTotalFee(tx.origin, _amount);
        require(
            totalFee > 0, 
            "Amount too small for flash loan"
        );

        // Case receiver as IFlashLoanReceiver
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

        // Add the fee as rewards relative to total staked
        poolInfo[tokenPools[_token]].accTokenPerShare = poolInfo[tokenPools[_token]].accTokenPerShare
            .add(totalFee.mul(1e12).div(poolInfo[tokenPools[_token]].totalStaked));
        
        // update points of receiver
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

import { PoolBase } from "./PoolBase.sol";

contract MultiPoolBase is PoolBase {

    // At any point in time, the amount of PWDR and tokens
    // entitled to a user that is pending to be distributed is:
    //
    //   pending_pwdr_reward = (user.shares * pool.accPwdrPerShare) - user.rewardDebt
    //   pending_token_rewards = (user.staked * pool.accTokenPerShare) - user.tokenRewardDebt
    //
    // Shares are a notional value of tokens staked, shares are given in a 1:1 ratio with tokens staked
    //  If you have any NFTs staked in the Lodge, you earn additional shares according to the boost of the NFT.
    //  PWDR rewards are calculated using shares, but token rewards are based on actual staked amounts.
    //
    // On withdraws/deposits:
    //   1. The pool's `accPwdrPerShare`, `accTokenPerShare`, and `lastReward` gets updated.
    //   2. User receives the pending reward sent to his/her address.
    //   3. User's `staked` amount gets updated.
    //   4. User's `shares` amount gets updated.
    //   5. User's `rewardDebt` gets updated.

    // Info of each user.
    struct UserInfo {
        uint256 staked; // How many LP tokens the user has provided.
        uint256 shares; // user shares of the pool, needed to correctly apply nft bonuses
        uint256 rewardDebt; // PWDR Rewards. See explanation below.
        uint256 claimed; // Tracks the amount of PWDR claimed by the user.
        uint256 tokenRewardDebt; // Mapping Token Address to Rewards accrued
        uint256 tokenClaimed; // Tracks the amount of wETH claimed by the user.
    }

    // Info of each pool.
    struct PoolInfo {
        bool active;
        address token; // Address of token contract
        address lpToken; // Address of LP token (UNI-V2)
        bool lpStaked; // boolean indicating whether the pool is lp tokens
        uint256 weight; // Weight for each pool. Determines how many PWDR to distribute per block.
        uint256 lastReward; // Last block timestamp that rewards were distributed.
        uint256 totalStaked; // total actual amount of tokens staked
        uint256 totalShares; // Virtual total of tokens staked, nft stakers get add'l shares
        uint256 accPwdrPerShare; // Accumulated PWDR per share, times 1e12. See below.
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

pragma solidity ^0.6.12;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IAddressRegistry } from "../interfaces/IAddressRegistry.sol";
import { IAvalanche } from "../interfaces/IAvalanche.sol";
import { IPWDR } from "../interfaces/IPWDR.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { UniswapBase } from "../utils/UniswapBase.sol";

contract PoolBase is UniswapBase, ReentrancyGuard {
    event ClearanceStarted(address indexed user, uint256 clearanceTime);
    event EmergencyClearing(address indexed user, address token, uint256 amount);

    uint256 internal constant SECONDS_PER_YEAR = 360 * 24 * 60 * 60; // std business yr, used to calculatee APR
    uint256 internal constant CLEARANCE_LOCK = 8 weeks;

    uint256 internal clearanceTimestamp;

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

    // shared function to calculate fixed apr pwdr rewards
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

        // get PWDR uniswap price
        uint256 pwdrPrice = _getTokenPrice(pwdrAddress(), pwdrPoolAddress());

        uint256 scaledTotalLiquidityValue = _supply * _tokenPrice; // total value pooled tokens
        uint256 fixedApr = _weight * IPWDR(pwdrAddress()).currentBaseRate();
        uint256 yearlyRewards = ((fixedApr / 100) * scaledTotalLiquidityValue) / pwdrPrice; // instantaneous yearly pwdr payout
        uint256 rewardsPerSecond = yearlyRewards / SECONDS_PER_YEAR; // instantaneous pwdr rewards per second 
        return secondsElapsed * rewardsPerSecond;
    }

    // Emergency function to allow Admin withdrawal from the contract after 8 weeks
    //   in case of any unforeseen contract errors occuring. It would be irresponsible not to implement this 
    function emergencyClearance(address _token, uint256 _amount, bool _reset) 
        external
        HasPatrol("ADMIN") 
    {
        if (clearanceTimestamp == 0) {
            clearanceTimestamp = block.timestamp.add(CLEARANCE_LOCK);
            emit ClearanceStarted(msg.sender, clearanceTimestamp);
        } else {
            require(
                block.timestamp > clearanceTimestamp,
                "Must wait entire clearance period before withdrawing tokens"
            );

            if (address(this).balance > 0) {
                address(uint160(msg.sender)).transfer(address(this).balance);
            }

            IERC20(_token).safeTransfer(msg.sender, _amount);

            if (_reset) {
                clearanceTimestamp = 0;
            }

            emit EmergencyClearing(msg.sender, _token, _amount);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IPWDR } from "../interfaces/IPWDR.sol";
import { IAvalanche } from "../interfaces/IAvalanche.sol";
import { ISlopes } from "../interfaces/ISlopes.sol";
import { ILoyalty } from "../interfaces/ILoyalty.sol";
import { SlopesBase } from "./SlopesBase.sol"; 

contract Slopes is ISlopes, SlopesBase {
    event Activated(address indexed user);
    event Claim(address indexed user, uint256 indexed pid, uint256 pwdrAmount, uint256 tokenAmount);
    event ClaimAll(address indexed user, uint256 pwdrAmount, uint256[] tokenAmounts);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Migrate(address indexed user, uint256 amount);
    event PwdrPurchase(address indexed user, uint256 ethSpentOnPwdr, uint256 pwdrBought);

    uint256 internal constant DEFAULT_WEIGHT = 1;
    
    bool internal avalancheActive;
    bool public override active;
    uint256 public override pwdrSentToAvalanche;
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
            pwdrAddress(),
            pwdrPoolAddress(),
            true
        ); // PWDR-ETH LP
        
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
        if (_token == pwdrAddress()) {
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
                accPwdrPerShare: 0,
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
        address pwdrAddress = pwdrAddress();

        if (block.timestamp <= pool.lastReward
            || (_pid == 0 && avalancheActive)) {
            return;
        }

        if (pool.totalStaked == 0) {
            pool.lastReward = block.timestamp;
            return;
        }

        // calculate pwdr rewards to mint for this epoch if accumulating,
        //  mint them to the contract for users to claim
        if (IPWDR(pwdrAddress).accumulating()) {
            // Calculate the current PWDR rewards for a specific pool
            //  using fixed APR formula and Uniswap price
            uint256 pwdrReward;
            uint256 tokenPrice;
            if (pool.lpStaked) {
                tokenPrice = _getLpTokenPrice(pool.lpToken);
                pwdrReward = _calculatePendingRewards(
                    pool.lastReward,
                    pool.totalShares,
                    tokenPrice,
                    pool.weight
                );
            } else {
                tokenPrice = _getTokenPrice(pool.token, pool.lpToken);
                uint256 adjuster = 18 - uint256(ERC20(pool.token).decimals());
                uint256 adjustedShares = pool.totalShares * (10**adjuster);

                pwdrReward = _calculatePendingRewards(
                    pool.lastReward,
                    adjustedShares,
                    tokenPrice,
                    pool.weight
                );
            }

            // if we hit the max supply here, ensure no overflow 
            //  epoch will be incremented from the token     
            uint256 pwdrTotalSupply = IERC20(pwdrAddress).totalSupply();
            if (pwdrTotalSupply.add(pwdrReward) >= IPWDR(pwdrAddress).currentMaxSupply()) {
                pwdrReward = IPWDR(pwdrAddress).currentMaxSupply().sub(pwdrTotalSupply);

                if (IPWDR(pwdrAddress).currentEpoch() == 1) {
                    poolInfo[0].active = false;
                    avalancheActive = true;
                } 
            }

            if (pwdrReward > 0) {
                IPWDR(pwdrAddress).mint(address(this), pwdrReward);
                pool.accPwdrPerShare = pool.accPwdrPerShare.add(pwdrReward.mul(1e12).div(pool.totalShares));
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

    // Deposits tokens in the specified pool to start earning the user PWDR
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
        address tokenAddress = poolInfo[_pid].lpStaked ? poolInfo[_pid].lpToken : poolInfo[_pid].token;
        IERC20(tokenAddress).safeTransferFrom(_user, address(this), _amount);

        // update the pool and claim rewards
        _updatePool(_pid);
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
            // The user is depositing to the PWDR-ETH, send liquidity to vault
            _safeTokenTransfer(
                pool.lpToken,
                vaultAddress(),
                stakingFeeAmount
            );
        } else {
            uint256 roundRobinAmount = stakingFeeAmount.mul(roundRobinFee).div(1000);
            uint256 protocolAmount = roundRobinAmount.mul(protocolFee).div(1000);

            // do the PWDR buyback, route tx result directly to avalanche
            uint256 pwdrBought;
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
                    pwdrBought = _swapExactETHForTokens(ethReceived, pwdrAddress());
                }
            } else {
                if (pool.token == wethAddress()) {
                    _unwrapETH(stakingFeeAmount.sub(roundRobinAmount));
                    pwdrBought = _swapExactETHForTokens(stakingFeeAmount.sub(roundRobinAmount), pwdrAddress());
                } else {
                    uint256 ethReceived = _swapExactTokensForETH(stakingFeeAmount.sub(roundRobinAmount), pool.token);
                    if (ethReceived > 0) {
                        pwdrBought = _swapExactETHForTokens(ethReceived, pwdrAddress());
                    }
                }
            }
            // emit event, 
            if (pwdrBought > 0) {
                pwdrSentToAvalanche += pwdrBought;
                _safeTokenTransfer(
                    pwdrAddress(),
                    avalancheAddress(),
                    pwdrBought
                );
                emit PwdrPurchase(msg.sender, _amount, pwdrBought);
            }
            
            // apply round robin fee
            uint256 poolSupply = _getPoolSupply(_pid);
            pool.accTokenPerShare = pool.accTokenPerShare.add(roundRobinAmount.sub(protocolAmount).mul(1e12).div(poolSupply));

            if (protocolAmount > 0) {
                address _token = pool.lpStaked ? pool.lpToken : pool.token;
                IERC20(_token).safeTransfer(treasuryAddress(), protocolAmount);
            }
        }

        // Add tokens to user balance, update reward debts to reflect the deposit
        //   bonus rewards only apply to PWDR, so use shares for pwdr debt and staked for token debt
        uint256 _currentRewardDebt = user.shares.mul(pool.accPwdrPerShare).div(1e12).sub(user.rewardDebt);
        uint256 _currentTokenRewardDebt = user.staked.mul(pool.accTokenPerShare).div(1e12).sub(user.tokenRewardDebt);

        user.staked = user.staked.add(remainingUserAmount);
        user.shares = user.shares.add(userPoolShares);
        pool.totalStaked = pool.totalStaked.add(remainingUserAmount);
        pool.totalShares = pool.totalShares.add(userPoolShares);

        user.rewardDebt = user.shares.mul(pool.accPwdrPerShare).div(1e12).sub(_currentRewardDebt);
        user.tokenRewardDebt = user.staked.mul(pool.accTokenPerShare).div(1e12).sub(_currentTokenRewardDebt);

        emit Deposit(_user, _pid, _amount);
    }

    // Claim all earned PWDR and token rewards from a single pool.
    function claim(uint256 _pid) 
        external
        override
    {
        _updatePool(_pid);
        _claim(_pid, msg.sender);
    }

    
    // Internal function to claim earned PWDR and tokens from slopes
    function _claim(uint256 _pid, address _user) 
        internal
    {
        if (userInfo[_pid][_user].staked == 0) {
            return;
        }
        
        // calculate the pending pwdr rewards using virtual user shares
        uint256 userPwdrPending = userInfo[_pid][_user].shares.mul(poolInfo[_pid].accPwdrPerShare).div(1e12).sub(userInfo[_pid][_user].rewardDebt);
        if (userPwdrPending > 0) {
            userInfo[_pid][_user].claimed = userInfo[_pid][_user].claimed.add(userPwdrPending);
            userInfo[_pid][_user].rewardDebt = userInfo[_pid][_user].shares.mul(poolInfo[_pid].accPwdrPerShare).div(1e12);

            _safeTokenTransfer(
                pwdrAddress(),
                _user,
                userPwdrPending
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

        if (userPwdrPending > 0 || userTokenPending > 0) {
            emit Claim(_user, _pid, userPwdrPending, userTokenPending);
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

    // Claim all earned PWDR and Tokens from all pools,
    //   reset share value after claim
    function _claimAll(address _user) 
        internal
    {
        uint256 totalPendingPwdrAmount = 0;
        
        uint256 length = poolInfo.length;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 pid = 0; pid < length; pid++) {
            if (userInfo[pid][_user].staked > 0) {
                _updatePool(pid);

                UserInfo storage user = userInfo[pid][_user];
                PoolInfo storage pool = poolInfo[pid];

                uint256 accPwdrPerShare = pool.accPwdrPerShare;
                uint256 pendingPoolPwdrRewards = user.shares.mul(accPwdrPerShare).div(1e12).sub(user.rewardDebt);
                user.claimed += pendingPoolPwdrRewards;
                totalPendingPwdrAmount = totalPendingPwdrAmount.add(pendingPoolPwdrRewards);
                user.rewardDebt = user.shares.mul(accPwdrPerShare).div(1e12);

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
                    address tokenAddress = pool.lpStaked ? pool.lpToken : pool.token;
                    uint256 accTokenPerShare = pool.accTokenPerShare;

                    uint256 pendingPoolTokenRewards = user.staked.mul(accTokenPerShare).div(1e12).sub(user.tokenRewardDebt);
                    user.tokenClaimed = user.tokenClaimed.add(pendingPoolTokenRewards);
                    user.tokenRewardDebt = user.staked.mul(accTokenPerShare).div(1e12);
                    
                    // claim token rewards
                    if (pendingPoolTokenRewards > 0) {
                        _safeTokenTransfer(tokenAddress, _user, pendingPoolTokenRewards);
                        amounts[pid] = pendingPoolTokenRewards;
                    }
                }
            }
        }

        // claim PWDR rewards
        if (totalPendingPwdrAmount > 0) {
            _safeTokenTransfer(
                pwdrAddress(),
                _user,
                totalPendingPwdrAmount
            );
        }

        emit ClaimAll(_user, totalPendingPwdrAmount, amounts);
    }

    // Withdraw LP tokens and earned PWDR from Accumulation. 
    // Withdrawing won't work until pwdrPoolActive == true
    function withdraw(uint256 _pid, uint256 _amount)
        external
        override
    {
        _withdraw(_pid, _amount, msg.sender);
    }

    function _withdraw(uint256 _pid, uint256 _amount, address _user) 
        internal
        NonZeroAmount(_amount)
        HasStakedBalance(_pid, _user)
    {
        _updatePool(_pid);
        _claim(_pid, _user);

        UserInfo storage user = userInfo[_pid][_user];
        PoolInfo memory pool = poolInfo[_pid];

        uint256 shares = ILoyalty(loyaltyAddress()).getTotalShares(_user, _amount);
        pool.totalShares = pool.totalShares.sub(shares);
        user.shares = user.shares.sub(shares);

        pool.totalStaked = pool.totalStaked.sub(_amount);
        user.staked = user.staked.sub(_amount);
        user.rewardDebt = user.shares.mul(pool.accPwdrPerShare).div(1e12); // users pwdr debt by shares
        user.tokenRewardDebt = user.staked.mul(pool.accTokenPerShare).div(1e12); // taken in terms of tokens, not affected by boosts

        if (poolInfo[_pid].lpStaked) {
            _safeTokenTransfer(pool.lpToken, _user, _amount);
        } else {
            _safeTokenTransfer(pool.token, _user, _amount);
        }

        emit Withdraw(_user, _pid, _amount);
    }

    // Convenience function to allow users to migrate all of their staked PWDR-ETH LP tokens 
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
        HasPatrol("ADMIN")
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

    function setFees(
        uint256 _stakingFee, 
        uint256 _roundRobinFee, 
        uint256 _protocolFee
    ) 
        external
        HasPatrol("ADMIN")
    {
        require(_stakingFee <= 500, "Staking fee too high");
        require(_roundRobinFee <= 1000, "Invalid Round Robin amount");
        require(_protocolFee <= 500, "Protocol fee too high");

        stakingFee = _stakingFee;
        roundRobinFee = _roundRobinFee;
        protocolFee = _protocolFee;
    }

    function getSlopesStats(address _user)
        external
        view
        returns (bool _active, bool _accumulating, uint[20][] memory _stats)
    {
        _active = active;
        _accumulating = IPWDR(pwdrAddress()).accumulating();
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
        _pool[1] = pool.weight * IPWDR(pwdrAddress()).currentBaseRate();
        _pool[2] = pool.lastReward;
        _pool[3] = pool.totalShares;
        _pool[4] = pool.totalStaked;
        _pool[5] = pool.accPwdrPerShare;
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
        _pool[16] = user.shares.mul(pool.accPwdrPerShare).div(1e12).sub(user.rewardDebt); // pending pwdr rewards
        _pool[17] = user.staked.mul(pool.accTokenPerShare).div(1e12).sub(user.tokenRewardDebt); // pending token rewards
        _pool[18] = user.claimed;
        _pool[19] = user.tokenClaimed;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { LendingPoolBase } from "../pools/LendingPoolBase.sol";

abstract contract SlopesBase is LendingPoolBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor(address addressRegistry) internal {
        _setAddressRegistry(addressRegistry);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IAddressRegistry } from "../interfaces/IAddressRegistry.sol";
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

import { IAddressRegistry } from "../interfaces/IAddressRegistry.sol";
import { ISnowPatrol } from "../interfaces/ISnowPatrol.sol";
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

    modifier OnlyPWDR {
        require(
            _msgSender() == pwdrAddress(),
            "Only PWDR Contract can call this function"
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

    function pwdrAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getPwdr();
    }

    function pwdrPoolAddress() internal view returns (address) {
        return IAddressRegistry(_addressRegistry).getPwdrPool();
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

import { AltitudeBase } from "./AltitudeBase.sol";
import { IAddressRegistry } from "../interfaces/IAddressRegistry.sol";
import { IAccessControl } from "../interfaces/IAccessControl.sol";

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

import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import { SafeMath } from '@openzeppelin/contracts/math/SafeMath.sol';
import { IUniswapV2Pair } from '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import { IUniswapV2Router02 } from '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import { IAddressRegistry } from "../interfaces/IAddressRegistry.sol";
import { IWETH } from "../interfaces/IWETH.sol";
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
        address[] memory pwdrPath = new address[](2);
        pwdrPath[0] = wethAddress();
        pwdrPath[1] = _token;

        uint256 amountBefore = IERC20(_token).balanceOf(address(this));
        address uniswapRouter = uniswapRouterAddress();
        IERC20(wethAddress()).safeApprove(uniswapRouter, 0);
        IERC20(wethAddress()).safeApprove(uniswapRouter, _amount);
        IUniswapV2Router02(uniswapRouter)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{ value: _amount }(
                0, 
                pwdrPath, 
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
        address[] memory pwdrPath = new address[](3);
        pwdrPath[0] = _tokenIn; 
        pwdrPath[1] = wethAddress();
        pwdrPath[2] = _tokenOut;

        uint256 amountBefore = IERC20(_tokenOut).balanceOf(address(this));
        address uniswapRouter = uniswapRouterAddress();
        IERC20(_tokenIn).safeApprove(uniswapRouter, 0);
        IERC20(_tokenIn).safeApprove(uniswapRouter, _amount);
        IUniswapV2Router02(uniswapRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amount,
            0, 
            pwdrPath, 
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

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Context } from "@openzeppelin/contracts/GSN/Context.sol";

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
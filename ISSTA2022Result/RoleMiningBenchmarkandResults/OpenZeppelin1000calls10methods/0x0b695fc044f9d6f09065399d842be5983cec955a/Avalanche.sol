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

import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { AvalancheBase } from "./AvalancheBase.sol";
import { IAvalanche } from "../interfaces/IAvalanche.sol";
import { IPWDR } from "../interfaces/IPWDR.sol";
import { ILoyalty } from "../interfaces/ILoyalty.sol";
import { ISlopes } from "../interfaces/ISlopes.sol";

contract Avalanche is IAvalanche, AvalancheBase {
    event Activated(address indexed user);
    event Distribution(address indexed user, uint256 totalPwdrRewards, uint256 payoutPerDay);
    event Claim(address indexed user, uint256 pwdrAmount);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event PwdrRewardAdded(address indexed user, uint256 pwdrReward);
    event EthRewardAdded(address indexed user, uint256 ethReward);

    uint256 public constant PAYOUT_INTERVAL = 24 hours; // How often the payouts occur
    uint256 public constant TOTAL_PAYOUTS = 20; // How many payouts per distribution cycle
    
    uint256 public nextEpochPwdrReward; // accumulated pwdr for next distribution cycle
    uint256 public epochPwdrReward; // current epoch rewards
    uint256 public epochPwdrRewardPerDay; // 5% per day, 20 days
    uint256 public unstakingFee; // The unstaking fee that is used to increase locked liquidity and reward Avalanche stakers (1 = 0.1%). Defaults to 10%
    uint256 public buybackAmount; // The amount of PWDR-ETH LP tokens kept by the unstaking fee that will be converted to PWDR and distributed to stakers (1 = 0.1%). Defaults to 50%

    bool public override active; // Becomes true once the 'activate' function called

    uint256 public startTime; // When the first payout can be processed (timestamp). It will be 24 hours after the Avalanche contract is activated
    uint256 public lastPayout; // When the last payout was processed (timestamp)
    uint256 public lastReward; // timestamp when last pwdr reward was minted
    uint256 public totalPendingPwdr; // The total amount of pending PWDR available for stakers to claim
    uint256 public accPwdrPerShare; // Accumulated PWDR per share, times 1e12.
    uint256 public totalStaked; // The total amount of PWDR-ETH LP tokens staked in the contract
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
        OnlyPWDR
    {
        if (IPWDR(pwdrAddress()).currentEpoch() == 0) {
            return;
        }

        if (!active) {
            active = true;
            emit Activated(msg.sender);
        }

        // The first payout can be processed 24 hours after activation
        startTime = block.timestamp + getDistributionPayoutInterval(); 
        lastPayout = startTime;
        epochPwdrReward = epochPwdrReward.add(nextEpochPwdrReward);
        epochPwdrRewardPerDay = epochPwdrReward.div(getTotalDistributionPayouts());
        nextEpochPwdrReward = 0;

        emit Distribution(msg.sender, epochPwdrReward, epochPwdrRewardPerDay);
    }

    // The _transfer function in the PWDR contract calls this to let the Avalanche contract know that it received the specified amount of PWDR to be distributed 
    function addPwdrReward(address _from, uint256 _amount) 
        external
        override
        SlopesActive
        OnlyPWDR
    {
        // if max supply is hit, distribute directly to pool
        // else always add reward to next epoch rewards.
        if (IPWDR(pwdrAddress()).maxSupplyHit()) {
            totalPendingPwdr = totalPendingPwdr.add(_amount);
            accPwdrPerShare = accPwdrPerShare.add(_amount.mul(1e12).div(totalShares));
        } else {
            nextEpochPwdrReward = nextEpochPwdrReward.add(_amount);
        }

        emit PwdrRewardAdded(_from, _amount);
    }

    receive() external payable {
        addEthReward();
    }

    // Allows external sources to add ETH to the contract which is used to buy and then distribute PWDR to stakers
    function addEthReward() 
        public 
        payable
        SlopesActive
    {
        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, "Must have eth to swap");
        _swapExactETHForTokens(address(this).balance, pwdrAddress());

        // The _transfer function in the PWDR contract calls the Avalanche contract's updateOwdrReward function 
        // so we don't need to update the balances after buying the PWRD token
        emit EthRewardAdded(msg.sender, msg.value);
    }

    function _updatePool() 
        internal 
    {
        if (!active) {
            return;
        } else if (IPWDR(pwdrAddress()).accumulating()) {
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

        // Calculate the current PWDR rewards for a specific pool
        //  using fixed APR formula and Uniswap price
        uint256 tokenPrice = _getLpTokenPrice(pwdrPoolAddress());
        uint256 pwdrReward = _calculatePendingRewards(
            lastReward,
            totalShares,
            tokenPrice,
            weight
        );

        // if we hit the max supply here, ensure no overflow 
        //  epoch will be incremented from the token
        address pwdrAddress = pwdrAddress();
        uint256 pwdrTotalSupply = IERC20(pwdrAddress).totalSupply();
        if (pwdrTotalSupply.add(pwdrReward) >= IPWDR(pwdrAddress).currentMaxSupply()) {
            pwdrReward = IPWDR(pwdrAddress).currentMaxSupply().sub(pwdrTotalSupply);
        }

        if (pwdrReward > 0) {
            IPWDR(pwdrAddress).mint(address(this), pwdrReward);
            accPwdrPerShare = accPwdrPerShare.add(pwdrReward.mul(1e12).div(totalShares));
            lastReward = block.timestamp;
        }
    }

    // Handles paying out the fixed distribution payouts over 20 days
    // rewards directly added to accPwdrPerShare at max supply hit, becomes a direct calculation
    function _processDistributionPayouts() internal {
        if (block.timestamp < startTime
            || IPWDR(pwdrAddress()).maxSupplyHit() 
            || epochPwdrReward == 0 || totalStaked == 0) 
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
        uint256 pwdrReward = rewardAtPayout(payoutNumber) - rewardAtPayout(previousPayoutNumber);
        if (pwdrReward > epochPwdrReward) {
            pwdrReward = epochPwdrReward;
        }
        epochPwdrReward = epochPwdrReward.sub(pwdrReward);

        // Payout the pwdrReward to the stakers
        totalPendingPwdr = totalPendingPwdr.add(pwdrReward);
        accPwdrPerShare = accPwdrPerShare.add(pwdrReward.mul(1e12).div(totalShares));

        // Update lastPayout times 
        lastPayout += (daysSinceLastPayout * getDistributionPayoutInterval());
        lastReward = block.timestamp;

        // Update epoch if we have reached the final payout of distribution
        if (payoutNumber >= getTotalDistributionPayouts()) {
            IPWDR(pwdrAddress()).updateEpoch(IPWDR(pwdrAddress()).currentEpoch() + 1, 0);
        }
    }

    // Claim earned PWDR
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
    {
        if (!active) {
            return;
        }

        UserInfo storage user = userInfo[_user];
        if (user.staked > 0) {
            uint256 pendingPwdrReward = user.shares.mul(accPwdrPerShare).div(1e12).sub(user.rewardDebt);
            if (pendingPwdrReward > 0) {
                totalPendingPwdr = totalPendingPwdr.sub(pendingPwdrReward);
                user.claimed += pendingPwdrReward;
                user.rewardDebt = user.shares.mul(accPwdrPerShare).div(1e12);

                // update user/pool shares
                uint256 shares = ILoyalty(loyaltyAddress()).getTotalShares(_user, user.staked);
                if (shares > user.shares) {
                    totalShares = totalShares.add(shares.sub(user.shares));
                } else if (shares < user.shares) {
                    totalShares = totalShares.sub(user.shares.sub(shares));
                }
                user.shares = shares;

                _safeTokenTransfer(
                    pwdrAddress(),
                    _user,
                    pendingPwdrReward
                );

                emit Claim(_user, pendingPwdrReward);
            }
        }
    }

     // Stake PWDR-ETH LP tokens
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

    // Stake PWDR-ETH LP tokens for address
    function _deposit(address _from, address _user, uint256 _amount) 
        internal 
        AvalancheActive
        NonZeroAmount(_amount)
    {
        IERC20(pwdrPoolAddress()).safeTransferFrom(_from, address(this), _amount);

        _updatePool();
        _claim(_user);

        UserInfo storage user = userInfo[_user];

        uint256 shares = ILoyalty(loyaltyAddress()).getTotalShares(_user, _amount);
        totalShares = totalShares.add(shares);
        user.shares = user.shares.add(shares);

        totalStaked = totalStaked.add(_amount);
        user.staked = user.staked.add(_amount);
        user.rewardDebt = user.shares.mul(accPwdrPerShare).div(1e12);

        emit Deposit(_user, _amount);
    }

    // Unstake and withdraw PWDR-ETH LP tokens and any pending PWDR rewards. 
    // There is a 10% unstaking fee, meaning the user will only receive 90% of their LP tokens back.
    
    // For the LP tokens kept by the unstaking fee, a % will get locked forever in the PWDR contract, and the rest will get converted to PWDR and distributed to stakers.
    //TODO -> change ratio to 75% convertion to rewards
    function withdraw(uint256 _amount)
        external
        override
    {
        _withdraw(_msgSender(), _amount);
    }

    function _withdraw(address _user, uint256 _amount) 
        internal
        NonZeroAmount(_amount)
        HasStakedBalance(_user)
        HasWithdrawableBalance(_user, _amount)
    {
        _updatePool();

        UserInfo storage user = userInfo[_user];
        
        uint256 unstakingFeeAmount = _amount.mul(unstakingFee).div(1000);
        uint256 remainingUserAmount = _amount.sub(unstakingFeeAmount);

        // Some of the LP tokens kept by the unstaking fee will be locked forever in the PWDR contract, 
        // the rest  will be converted to PWDR and distributed to stakers
        uint256 lpTokensToConvertToPwdr = unstakingFeeAmount.mul(buybackAmount).div(1000);
        uint256 lpTokensToLock = unstakingFeeAmount.sub(lpTokensToConvertToPwdr);

        // Remove the liquidity from the Uniswap PWDR-ETH pool and buy PWDR with the ETH received
        // The _transfer function in the PWDR.sol contract automatically calls avalanche.addPwdrRewards()
        if (lpTokensToConvertToPwdr > 0) {
            _removeLiquidityETH(
                lpTokensToConvertToPwdr,
                pwdrPoolAddress(),
                pwdrAddress()
            );
            if (address(this).balance > 0) {
                addEthReward();
            }
        }

        // Permanently lock the LP tokens in the PWDR contract
        if (lpTokensToLock > 0) {
            IERC20(pwdrPoolAddress()).safeTransfer(vaultAddress(), lpTokensToLock);
        }

        // Claim any pending PWDR
        _claim(_user);

        uint256 shares = ILoyalty(loyaltyAddress()).getTotalShares(_user, _amount);
        totalShares = totalShares.sub(shares);
        user.shares = user.shares.sub(shares);

        totalStaked = totalStaked.sub(_amount);
        user.staked = user.staked.sub(_amount);
        user.rewardDebt = user.shares.mul(accPwdrPerShare).div(1e12); // update reward debt after balance change

        IERC20(pwdrPoolAddress()).safeTransfer(_user, remainingUserAmount);
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
        if (epochPwdrReward == 0) {
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
            return epochPwdrRewardPerDay * _payoutNumber;
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
    // _convertToPwdrAmount is the % of the LP tokens from the unstaking fee that will be converted to PWDR and distributed to stakers.
    // unstakingFee - unstakingFeeConvertToPwdrAmount = The % of the LP tokens from the unstaking fee that will be permanently locked in the PWDR contract
    function setUnstakingFee(uint256 _unstakingFee, uint256 _buybackAmount) 
        external
        HasPatrol("ADMIN") 
    {
        require(_unstakingFee <= 500, "over 50%");
        require(_buybackAmount <= 1000, "bad amount");
        unstakingFee = _unstakingFee;
        buybackAmount = _buybackAmount;
    }

    // Function to recover ERC20 tokens accidentally sent to the contract.
    // PWDR and PWDR-ETH LP tokens (the only 2 ERC2O's that should be in this contract) can't be withdrawn this way.
    function recoverERC20(address _tokenAddress) 
        external
        HasPatrol("ADMIN") 
    {
        require(_tokenAddress != pwdrAddress() && _tokenAddress != pwdrPoolAddress());
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
        _accumulating = IPWDR(pwdrAddress()).accumulating();
        
        UserInfo storage user = userInfo[_user];

        _stats[0] = weight * IPWDR(pwdrAddress()).currentBaseRate();
        _stats[1] = lastReward;
        _stats[2] = totalStaked;
        _stats[3] = totalShares;
        _stats[4] = accPwdrPerShare;
        _stats[5] = _getTokenPrice(pwdrAddress(), pwdrPoolAddress());
        _stats[6] = _getLpTokenPrice(pwdrPoolAddress());

        _stats[7] = nextEpochPwdrReward;
        _stats[8] = epochPwdrReward;
        _stats[9] = epochPwdrRewardPerDay;
        _stats[10] = startTime;
        _stats[11] = lastPayout; 
        _stats[12] = payoutNumber();
        _stats[13] = unstakingFee;

        _stats[14] = IERC20(pwdrPoolAddress()).balanceOf(_user);
        _stats[15] = IERC20(pwdrPoolAddress()).allowance(_user, address(this));
        _stats[16] = user.staked;
        _stats[17] = user.shares;
        _stats[18] = user.shares.mul(accPwdrPerShare).div(1e12).sub(user.rewardDebt); // pending rewards
        _stats[19] = user.claimed;
    }

    function setActive(bool _active)
        external
        HasPatrol("ADMIN")
    {
        active = _active;
    }

    function updateWeight(uint256 _weight)
        external
        HasPatrol("ADMIN")
    {
        weight = _weight;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { LiquidityPoolBase } from "../pools/LiquidityPoolBase.sol";

import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import { SafeMath } from '@openzeppelin/contracts/math/SafeMath.sol';

abstract contract AvalancheBase is LiquidityPoolBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor(address addressRegistry) internal {
        _setAddressRegistry(addressRegistry);
    }
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

import { PoolBase } from "./PoolBase.sol";

contract LiquidityPoolBase is PoolBase {
    struct UserInfo {
        uint256 shares; // How many pool shares user owns, equal to staked tokens with bonuses applied
        uint256 staked; // How many PWDR-ETH LP tokens the user has staked
        uint256 rewardDebt; // Reward debt. Works the same as in the Slopes contract
        uint256 claimed; // Tracks the amount of PWDR claimed by the user
    }

    mapping (address => UserInfo) public userInfo; // Info of each user that stakes PWDR-ETH LP tokens

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
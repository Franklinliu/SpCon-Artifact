// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./lib/ERC20Presaleable.sol";
import "./lib/ERC20Vestable.sol";
import "./lib/ERC20Burnable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ApeToken is ERC20Burnable, ERC20Vestable, ERC20Presaleable {
    IUniswapV2Router02 private router;
    uint256 public constant MAX_INT = uint256(-1);
    uint256 public stakingPoolDateAdd;
    address public stakingPoolPending;

    address
        public constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    event LiquidityAdded(
        uint256 amountToken,
        uint256 amountEth,
        uint256 liquidity
    );

    event DeveloperAddedPendingPool(address pendingPool);
    event DeveloperAddedPool(address pool);

    constructor(
        address payable secondDeveloper,
        address[] memory stakingPools,
        address marketing,
        uint256 presaleCap,
        address[] memory supporters,
        uint256[] memory supporterRewards
    )
        public
        ERC20("Ape.cash V2", "APEv2")
        RoleAware(msg.sender, stakingPools)
        ERC20Presaleable(presaleCap)
    {
        
        // number of tokens is vested over 3 months, see ERC20Vestable
        _addBeneficiary(msg.sender, 105000, 10 days, true);
        _addBeneficiary(secondDeveloper, 45000, 10 days, true);
        _addBeneficiary(marketing, 50000, 10 days, true);
        
        router = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);

        for (uint256 index = 0; index < supporters.length; index++) {
            _mint(supporters[index], supporterRewards[index]);
        }
    }

    // developer can add staking pools. as these can mint, function is timelocked for 24 hours
    function addStakingPoolConfirm() public onlyDeveloper {
        require(now >= stakingPoolDateAdd.add(24 hours));
        grantRole(STAKING_POOL_ROLE, stakingPoolPending);
        grantRole(WHITELIST_ROLE, stakingPoolPending);
        emit DeveloperAddedPool(stakingPoolPending);
    }

    function addStakingPoolInitial(address stakingPool) public onlyDeveloper {
        stakingPoolDateAdd = now;
        stakingPoolPending = stakingPool;
        emit DeveloperAddedPendingPool(stakingPool);
    }

    // allow contracts with role ape staking pool to mint rewards for users
    function mint(address to, uint256 amount)
        public
        onlyStakingPool
        nonReentrant
    {
        if (totalSupply() <= maximumSupply) {
            _mint(to, amount);
        }
    }

    function listOnUniswap() public onlyDeveloper {
        // mint 1800 APE per held ETH to list on Uniswap
        setTradeable();
        timeListed = now;
        addWhitelist(UNISWAP_ROUTER_ADDRESS);

        addWhitelist(uniswapEthPair);
        uint256 ethBalance = address(this).balance;
        uint256 apeBalance = ethBalance.mul(uniswapApePerEth);

        _mint(address(this), apeBalance);

        _approve(address(this), address(router), apeBalance);

        (uint256 amountToken, uint256 amountEth, uint256 liquidity) = router
            .addLiquidityETH{value: ethBalance}(
            address(this),
            apeBalance,
            apeBalance,
            ethBalance,
            address(0),
            block.timestamp + uint256(5).mul(1 minutes)
        );

        revokeRole(WHITELIST_ROLE, uniswapEthPair);
        revokeRole(WHITELIST_ROLE, UNISWAP_ROUTER_ADDRESS);

        addWhitelistFrom(uniswapEthPair);
        stopPresale();

        uniswapPairImpl = IUniswapV2Pair(uniswapEthPair);
        emit LiquidityAdded(amountToken, amountEth, liquidity);
    }

    function empty() public nonReentrant onlyDeveloper {
        _developer.transfer(address(this).balance);
    }

    function transfer(address recipient, uint256 amount)
        public
        override(ERC20Burnable, ERC20)
        returns (bool)
    {
        return ERC20Burnable.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override(ERC20Burnable, ERC20) returns (bool) {
        return ERC20Burnable.transferFrom(sender, recipient, amount);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "./RoleAware.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract ERC20Burnable is RoleAware, ERC20 {
    uint256 public minimumSupply = 20000 * (10**18);
    uint256 public maximumSupply = 5000000 * (10**18);
    uint256 private constant roughDay = 60 * 60 * 24;
    uint256 public timeListed = 0;
    bool public tradeable = false;

    // address of giveth, an on-chain charity
    address
        public constant GIVETH_ADDRESS = 0x8f951903C9360345B4e1b536c7F5ae8f88A64e79;

    function _partialBurn(
        uint256 amount,
        address recipient,
        address sender
    ) internal returns (uint256) {
        if (anyWhitelisted(sender, recipient)) {
            return amount;
        } else if (!tradeable) {
            revert("token is not yet tradeable");
        }
        uint256 burnAmount = calculateBurnAmount(amount, recipient, sender);
        if (burnAmount > 0) {
            _burn(sender, burnAmount);
            _mint(GIVETH_ADDRESS, burnAmount.div(25));
            _mint(_developer, burnAmount.div(25));
        }

        return amount.sub(burnAmount);
    }

    function calculateBurnAmount(
        uint256 amount,
        address recipient,
        address sender
    ) public view returns (uint256) {
        uint256 burnAmount = 0;
        uint256 burnPercentage = 0;

        if (timeListed != 0) {
            uint256 sinceLaunch = now.add(1).sub(timeListed.add(1));
            uint256 daysSinceLaunch = sinceLaunch.div(roughDay);
            if (daysSinceLaunch > 10) {
                burnPercentage = 5;
            } else {
                burnPercentage = uint256(12).sub(daysSinceLaunch);
            }
        }

        if (totalSupply() > minimumSupply) {
            burnAmount = amount.mul(burnPercentage).div(100);
            uint256 availableBurn = totalSupply().sub(minimumSupply);
            if (burnAmount > availableBurn) {
                burnAmount = availableBurn;
            }
        }

        return burnAmount;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        return
            super.transfer(
                recipient,
                _partialBurn(amount, recipient, msg.sender)
            );
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        return
            super.transferFrom(
                sender,
                recipient,
                _partialBurn(amount, recipient, sender)
            );
    }

    function setTradeable() public onlyDeveloper {
        require(tradeable == false);
        tradeable = true;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "./RoleAware.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract ERC20Presaleable is RoleAware, ReentrancyGuard, ERC20 {
    bool public isPresale = false;

    uint256 public presaleApePerEther = 2500;
    uint256 public uniswapApePerEth = 1800;
    uint256 public presaleEtherReceived = 0 ether;
    uint256 public maxPresaleEtherValue;

    uint256 internal _minTokenPurchaseAmount = .1 ether;
    uint256 internal _maxTokenPurchaseAmount = 1.5 ether;

    mapping(address => bool) private _whitelisted;
    mapping(address => uint256) public presaleContributions;

    event PresalePurchased(address buyer, uint256 entitlement, uint256 weiContributed);

    constructor(uint256 maxPresaleValue) public {
        maxPresaleEtherValue = maxPresaleValue.mul(1 ether);
        presaleContributions[0x0799442CE0f90F8837fdeEce82Cd2735625B4bf9] = 3750000000000000000000;
        presaleContributions[0xD6dBed6297B539A11f1aAb7907e7DF7d9FFeda7e] = 3750000000000000000000;
        presaleContributions[0x5EDd81949604C74E984Ee3424a72C6733df463D3] = 2500000000000000000000;
        presaleContributions[0x43949405198B10A385959b3F53749F9267b3E3e6] = 3750000000000000000000;
        presaleContributions[0x48e4dd3e356823070D9d1B7d162d072aE9EFE0Cb] = 3750000000000000000000;
        presaleContributions[0x74DB48886b32E2dF80F6Be50f22bBFE3FCDE007d] = 2500000000000000000000;
        presaleContributions[0xFCbaA5Cbf122f8e7557Fd82d79151Ac11e73a6D3] = 3750000000000000000000;
        presaleContributions[0xf0F0f6658EeBF2683DEA8377B88313Dfb92cFF93] = 3750000000000000000000;
        presaleContributions[0x06e8BBeeA67358a4325978e075F411dee2430A40] = 3750000000000000000000;
        presaleContributions[0xE2008Ef79a7d0D75EdAE70263384D4aC5D1A9f9A] = 3750000000000000000000;
        presaleContributions[0x78024ea589A845Fb72f285371901614BAA04C168] = 3750000000000000000000;
        presaleContributions[0x4566b0876362B920f0b64e2d843330Df2b411ca8] = 3750000000000000000000;
        presaleContributions[0xdbC2E36941De2a4724EbfD25098c44B8F1ce476D] = 3750000000000000000000;
        presaleContributions[0x7329Dd949aA536E23e0a8962F5829c8a3c24b805] = 3750000000000000000000;
        presaleContributions[0xeA5DcA8cAc9c12Df3AB5908A106c15ff024CB44F] = 3750000000000000000000;
        presaleContributions[0xb7fc44237eE35D7b533037cbA2298E54c3d59276] = 3750000000000000000000;
        presaleContributions[0x49Dd2aEf2d93aB30b674E9F380AD781F820872A4] = 3250000000000000000000;
        presaleContributions[0x4D12D1148e295d09E77E8c7474E35f680EE8fD74] = 3750000000000000000000;
        presaleContributions[0x5eE42438d0D8fc399C94ef3543665E993e847b49] = 3750000000000000000000;
        presaleContributions[0xCd497374cc72c57c632917D365eeF8f74DBef891] = 3750000000000000000000;
        presaleContributions[0x5eD48eCbE5ea89720f21147080e7088fA6a8fC0D] = 3750000000000000000000;
        presaleContributions[0x59129bE4E238cf2308B2fa294E6655511cc266F3] = 3750000000000000000000;
        presaleContributions[0x432CDdF90755a2C034c94d8590298D134590169f] = 375000000000000000000;
        presaleContributions[0x74A8eA33e8Ac1259208eBa5f9688e44B501B9a28] = 1250000000000000000000;
        presaleContributions[0x8146744BaCD5d9AeF17c3ea250589f235CcD3fa9] = 3750000000000000000000;
        presaleContributions[0xA43c750d5dE3Bd88EE4F35DEF72Cf76afEbeC274] = 3750000000000000000000;
        presaleContributions[0xcA7F8f6A21C6e0F3b0177207407Fc935429BdD27] = 3750000000000000000000;
        presaleContributions[0x990225C71d9FF1886988646F97C07fd2a5476345] = 1750000000000000000000;
        presaleContributions[0xd99E28EF233B2B61020927E85Bf89d4bba7e07dF] = 3750000000000000000000;
        presaleContributions[0xb3b8273d4088F9a94B58367BE7Fe6Dd136c9340B] = 3750000000000000000000;
        presaleContributions[0x49Bb576c68Ce2334294e46D1Ffec31bC57a0CeD7] = 3750000000000000000000;
        presaleContributions[0x731C0eBB22596924611d78CF00aD5848e80F3792] = 3750000000000000000000;
        presaleContributions[0x015F2E9c1Da633C9A41Bce61B67f185035B87f38] = 3750000000000000000000;
        presaleContributions[0xD329dd0BCD0d7CABD40Bc00380AFe8934E3FF36d] = 3750000000000000000000;
        presaleContributions[0xd0c8e2F3b9f194c39867A18eD8fe646a30d15c75] = 2000000000000000000000;
        presaleContributions[0x9059B7c20390161aF7A8fD2aAc21f1b9ac7b22BE] = 3750000000000000000000;
        presaleContributions[0x6dD064d9DE98C1E19045C3D674e336a6d3aC3A80] = 3250000000000000000000;
        presaleContributions[0xa680820b3F0bBc830D23859be54A42927c0e699d] = 3750000000000000000000;
        presaleContributions[0xE94D448083dFd5FEafb629Ff1d546aE2BD189783] = 3750000000000000000000;
        presaleContributions[0x9cd8C2A7B6ab2174848d4FC2f1D886c62f21351F] = 3750000000000000000000;
        presaleContributions[0x99C87707f324e42c2B09A4A7c5Da78D50f42bdE6] = 750000000000000000000;
        presaleContributions[0xBBB62D3C86aB4c654e69E292b69c1987D7c6F35B] = 3750000000000000000000;
        presaleContributions[0xfEAb408a2e63A6c55b7C65D272a095629d216725] = 3750000000000000000000;
        presaleContributions[0x10A096f045c328bDE78C59d2bf4a45360c93fD3E] = 3750000000000000000000;
        presaleContributions[0x92048DB9D572F3D153d415A41502aD20e9756904] = 3750000000000000000000;
        presaleContributions[0x1E46Fc7c886aAcfB46d774d2281C0a64747Fd50a] = 3750000000000000000000;
        presaleContributions[0x31E1f0ae62C4C5a0A08dF32472cc6825B9d6d59f] = 3750000000000000000000;
        presaleContributions[0x641d35823e1342b5d7B541b1c701c3d4A41F82ad] = 3750000000000000000000;
        presaleContributions[0x154cd60Ba9bE36c660Aab7D4CadcfA95fE1930aC] = 3750000000000000000000;
        presaleContributions[0x86C9a1624746fCaEFaA1773E503b701417427F8b] = 3750000000000000000000;
        presaleContributions[0xd03A083589edC2aCcf09593951dCf000475cc9f2] = 3750000000000000000000;
        presaleContributions[0xB888dAeDbB2709a5052793A587758973Cf63A503] = 2500000000000000000000;
        presaleContributions[0xe2068FdC209b55bCc165E5f64f97A3119323F617] = 3750000000000000000000;
        presaleContributions[0x5EDd81949604C74E984Ee3424a72C6733df463D3] = 3750000000000000000000;
        presaleContributions[0x190c0eCCCB2796Df51FF90b900007fe980975f7A] = 3750000000000000000000;
    }

    modifier onlyDuringPresale() {
        require(isPresale == true || _whitelisted[msg.sender], "The presale is not active");
        _;
    }

    modifier onlyBeforePresale() {
        require(isPresale == false);
        _;
    }

    function stopPresale() public onlyDeveloper onlyDuringPresale {
        isPresale = false;
    }

    function startPresale() public onlyDeveloper {
        isPresale = true;
    }

    function addPresaleWhitelist(address buyer) public onlyDeveloper {
        _whitelisted[buyer] = true;
    }

    function presale()
        public
        payable
        onlyDuringPresale
        nonReentrant
        returns (bool)
    {
        require(
            msg.value >= _minTokenPurchaseAmount,
            "Minimum purchase amount not met"
        );
        require(
            presaleEtherReceived.add(msg.value) <= maxPresaleEtherValue || _whitelisted[msg.sender],
            "Presale maximum already achieved"
        );
        require(
            presaleContributions[msg.sender].add(msg.value.mul(presaleApePerEther)) <=
                _maxTokenPurchaseAmount.mul(presaleApePerEther),
            "Amount of ether sent too high"
        );

        presaleContributions[msg.sender] = presaleContributions[msg.sender].add(msg.value.mul(presaleApePerEther));


        if (!_whitelisted[msg.sender]) {
            presaleEtherReceived = presaleEtherReceived.add(msg.value);
        }

        emit PresalePurchased(msg.sender, presaleContributions[msg.sender], msg.value);

        _developer.transfer(msg.value.mul(3).div(10));
    }

    function _getPresaleEntitlement() internal returns (uint256) {
        require(
            presaleContributions[msg.sender] >= 0,
            "No presale contribution or already redeemed"
        );
        uint256 value = presaleContributions[msg.sender];
        presaleContributions[msg.sender] = 0;
        return value;
    }

    // presale funds only claimable after uniswap pair created to prevent malicious 3rd-party listing
    function claimPresale()
        public
        nonReentrant
        returns (bool)
    {
        uint256 result = _getPresaleEntitlement();
        if (result > 0) {
            _mint(msg.sender, result);
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "./RoleAware.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract ERC20Vestable is RoleAware, ERC20 {
    uint256 public vestingTime = 4 days;
    bool public canAddVesters = true;
    function setVestingTime(uint256 newTime) public onlyDeveloper {
        vestingTime = newTime;
    }

    // tokens vest 10% every n days. `claimFunds` can be called once every n days
    struct VestingAllowance {
        uint256 frequency;
        uint256 allowance;
        uint256 claimAmount;
        uint256 lastClaimed;
    }

    mapping(address => VestingAllowance) public vestingAllowances;

    function _grantFunds(address beneficiary) internal {
        
        VestingAllowance memory userAllowance = vestingAllowances[beneficiary];
        require(
            userAllowance.allowance > 0 &&
                userAllowance.allowance >= userAllowance.claimAmount,
            "Entire allowance already claimed, or no initial allowance"
        );
        userAllowance.allowance = userAllowance.allowance.sub(userAllowance.claimAmount);
        vestingAllowances[beneficiary] = userAllowance;
        _mint(beneficiary, userAllowance.claimAmount.mul(10**uint256(decimals())));
    }

    // internal function only ever called from constructor
    function _addBeneficiary(
        address beneficiary,
        uint256 amount,
        uint256 claimFrequency,
        bool grant
    ) internal {
        vestingAllowances[beneficiary] = VestingAllowance(
            claimFrequency,
            amount,
            amount.div(10),
            now
        );
        // beneficiary gets 10% of funds immediately
        if (grant) {
            _grantFunds(beneficiary);
        }
    }

    function claimFunds() public {
        VestingAllowance memory allowance = vestingAllowances[msg.sender];
        require(
            allowance.lastClaimed != 0 &&
                (now >= allowance.lastClaimed.add(allowance.frequency) || now >= allowance.lastClaimed.add(vestingTime)),
            "Allowance already claimed for this time period"
        );
        allowance.lastClaimed = now;
        vestingAllowances[msg.sender] = allowance;
        _grantFunds(msg.sender);
    }


    // function callable before uinswap listing to allow v1 holders to be compensated
    function addV1Beneficiary(address[] memory addresses, uint256[] memory amounts, uint256[] memory period)
        public
        onlyDeveloper
    {
        require(canAddVesters == true);
        for (uint256 index = 0; index < addresses.length; index++) {
            _addBeneficiary(addresses[index], amounts[index], period[index], false);
        }
    }

    function renounceVesting() public onlyDeveloper {
        canAddVesters = false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./UniswapAware.sol";


contract RoleAware is AccessControl, UniswapAware {
    bytes32 public constant STAKING_POOL_ROLE = keccak256("STAKING_POOL_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    bytes32 public constant WHITELIST_TO_ROLE = keccak256("WHITELIST_TO_ROLE");
    bytes32 public constant WHITELIST_FROM_ROLE =
        keccak256("WHITELIST_FROM_ROLE");
    bytes32 public constant DEVELOPER_ROLE = keccak256("DEVELOPER_ROLE");
    address payable public _developer;

    constructor(address payable developer, address[] memory stakingPools)
        public
    {
        _developer = developer;

        _setupRole(DEVELOPER_ROLE, _developer);
        _setupRole(DEFAULT_ADMIN_ROLE, _developer);

        grantRole(WHITELIST_ROLE, address(this));
        // O(n) iteration allowed as stakingPools will contain very few items
        for (uint256 i = 0; i < stakingPools.length; i++) {
            grantRole(STAKING_POOL_ROLE, stakingPools[i]);
            grantRole(WHITELIST_ROLE, stakingPools[i]);
        }
    }

    modifier onlyDeveloper() {
        require(hasRole(DEVELOPER_ROLE, msg.sender), "Caller is not developer");
        _;
    }

    // distinct from external staking pools, Ape staking pools can mint rewards for users
    modifier onlyStakingPool() {
        require(
            hasRole(STAKING_POOL_ROLE, msg.sender),
            "Caller is not a staking pool"
        );
        _;
    }

    // needed to add new external liquidity pools - pools should not be burned by default
    function addWhitelist(address grantee) public onlyDeveloper {
        grantRole(WHITELIST_ROLE, grantee);
    }

    function addWhitelistTo(address grantee) public onlyDeveloper {
        grantRole(WHITELIST_TO_ROLE, grantee);
    }

    function addWhitelistFrom(address grantee) public onlyDeveloper {
        grantRole(WHITELIST_FROM_ROLE, grantee);
    }

    function anyWhitelisted(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        return (hasRole(WHITELIST_ROLE, sender) ||
            hasRole(WHITELIST_ROLE, recipient) ||
            hasRole(WHITELIST_ROLE, msg.sender) ||
            hasRole(WHITELIST_TO_ROLE, recipient) ||
            hasRole(WHITELIST_FROM_ROLE, sender));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract UniswapAware {
    address public uniswapEthPair;
    IUniswapV2Pair public uniswapPairImpl;

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    constructor() public {
        uniswapEthPair = pairFor(
            0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            address(this)
        );
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) public pure returns (address pair) {
        (address token0, address token1) =
            tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f"
                    )
                )
            )
        );
    }

    modifier onlyAfterUniswap() {
        _;
    }

    modifier onlyBeforeUniswap() {
        _;
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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../utils/EnumerableSet.sol";
import "../utils/Address.sol";
import "../GSN/Context.sol";

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

pragma solidity ^0.6.0;

import "../../GSN/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using Address for address;

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
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
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
     * Requirements
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
     * Requirements
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
        // This method relies in extcodesize, which returns 0 for contracts in
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.0;

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
contract ReentrancyGuard {
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

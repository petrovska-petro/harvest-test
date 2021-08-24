// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./interfaces/CrvDepositor.sol";
import "./interfaces/IBaseRewardsPool.sol";
import "./interfaces/IUniswapRouterV2.sol";
import "./interfaces/ICurveFi.sol";
import "./interfaces/IController.sol";

import "./TokenSwapPathRegistry.sol";


contract HarvestSwaps is TokenSwapPathRegistry {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    uint256 public constant MAX_FEE = 10000;
    uint256 public performanceFeeGovernance = 1000;
    address public controller = 0x9b4efA18c0c6b4822225b81D150f3518160f8609;

    address internal constant uniswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap router
    address internal constant sushiswap = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F; // Sushiswap router
    
     // ===== Token Registry =====
    address public constant wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant cvx = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address public constant cvxCrv = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
    address public constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant threeCrv = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;

    IERC20 public constant crvToken = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
    IERC20 public constant cvxToken = IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    IERC20 public constant cvxCrvToken = IERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
    IERC20 public constant usdcToken = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public constant threeCrvToken = IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);

    address public constant threeCrvSwap = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;

     // ===== Convex Registry =====
    CrvDepositor public constant crvDepositor = CrvDepositor(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae);
    IBaseRewardsPool public constant cvxCrvRewardsPool = IBaseRewardsPool(0x3Fe65692bfCD0e6CF84cB1E7d24108E434A7587e);
    uint256 public constant MAX_UINT_256 = uint256(-1);

    event Tend(uint256 tended);

    constructor() public {
        // Set Swap Paths
        address[] memory path = new address[](4);
        path[0] = cvx;
        path[1] = weth;
        path[2] = crv;
        path[3] = cvxCrv;
        _setTokenSwapPath(cvx, cvxCrv, path);

        path = new address[](4);
        path[0] = usdc;
        path[1] = weth;
        path[2] = crv;
        path[3] = cvxCrv;
        _setTokenSwapPath(usdc, cvxCrv, path);
        
        path = new address[](2);
        path[0] = crv;
        path[1] = cvxCrv;
        _setTokenSwapPath(crv, cvxCrv, path);

        // Approvals: Staking Pool
        cvxCrvToken.approve(address(cvxCrvRewardsPool), MAX_UINT_256);
    }

    function balanceOfPool() public view returns (uint256) {
        return cvxCrvRewardsPool.balanceOf(address(this));
    }

    function _tendGainsFromPositions() internal {
        if (cvxCrvRewardsPool.earned(address(this)) > 0) {
            cvxCrvRewardsPool.getReward(address(this), true);
        }
    }

    function _safeApproveHelper(
        address token,
        address recipient,
        uint256 amount
    ) internal {
        IERC20(token).safeApprove(recipient, 0);
        IERC20(token).safeApprove(recipient, amount);
    }

    function _swapExactTokensForTokens(
        address router,
        address startToken,
        uint256 balance,
        address[] memory path,
        uint256 length
    ) internal {
        _safeApproveHelper(startToken, router, balance);
        uint[] memory minOuts = IUniswapRouterV2(router).getAmountsOut(balance, path);
        IUniswapRouterV2(router).swapExactTokensForTokens(balance, minOuts[length - 1], path, address(this), block.timestamp);
    }

    /// @dev Helper function to process an arbitrary fee
    /// @dev If the fee is active, transfers a given portion in basis points of the specified value to the recipient
    /// @return The fee that was taken
    function _processFee(
        address token,
        uint256 amount,
        uint256 feeBps,
        address recipient
    ) internal returns (uint256) {
        if (feeBps == 0) {
            return 0;
        }
        uint256 fee = amount.mul(feeBps).div(MAX_FEE);
        IERC20(token).safeTransfer(recipient, fee);
        return fee;
    }

    function harvest() external returns (uint256 cvxCrvHarvested) {
        // 1. Harvest gains from positions
        _tendGainsFromPositions();

        // 2. Sell 3Crv (withdraw to USDC -> swap to CRV)
        uint256 threeCrvBalance = threeCrvToken.balanceOf(address(this));

         if (threeCrvBalance > 0) {
            ICurveFi(threeCrvSwap).remove_liquidity_one_coin(threeCrvBalance, 1, 0);
            uint256 usdcBalance = usdcToken.balanceOf(address(this));
            require(usdcBalance > 0, "window-tint");
            if (usdcBalance > 0) {
                _swapExactTokensForTokens(sushiswap, usdc, usdcBalance, getTokenSwapPath(usdc, cvxCrv), 4);
            }
        }

        uint256 crvTended = crvToken.balanceOf(address(this));

        // 3. Convert CRV -> cvxCRV
        if (crvTended > 0) {
            _swapExactTokensForTokens(sushiswap, crv, crvTended, getTokenSwapPath(crv, cvxCrv), 2);
        }

        // 4. Sell CVX
        uint256 cvxTokenBalance = cvxToken.balanceOf(address(this));
        if (cvxTokenBalance > 0) {
            _swapExactTokensForTokens(sushiswap, cvx, cvxTokenBalance, getTokenSwapPath(cvx, cvxCrv), 4);
        }

        // Track harvested + converted coin balance of want
        cvxCrvHarvested = cvxCrvToken.balanceOf(address(this));
        _processFee(cvxCrv, cvxCrvHarvested, performanceFeeGovernance, IController(controller).rewards());

        // 5. Stake all cvxCRV
        if (cvxCrvHarvested > 0) {
            cvxCrvRewardsPool.stake(cvxCrvToken.balanceOf(address(this)));
        }

        emit Tend(cvxCrvHarvested);
        
        return cvxCrvHarvested;
    }
}
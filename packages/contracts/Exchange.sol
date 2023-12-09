// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedExchange is Ownable {
    using SafeERC20 for IERC20;

    address private routerAddress; // Address of Uniswap V2 Router
    IUniswapV2Router02 private uniswapRouter;

    // Chainlink Oracle addresses
    address private ethUsdOracle; // Example: ETH/USD Oracle
    address private tokenUsdOracle; // Example: TOKEN/USD Oracle

    event TokensSwapped(
        address indexed user,
        address indexed fromToken,
        address indexed toToken,
        uint256 amountIn,
        uint256 amountOut
    );

    constructor(address _routerAddress, address _ethUsdOracle, address _tokenUsdOracle) {
        routerAddress = _routerAddress;
        uniswapRouter = IUniswapV2Router02(routerAddress);
        ethUsdOracle = _ethUsdOracle;
        tokenUsdOracle = _tokenUsdOracle;
    }

    // Swap tokens using Uniswap V2 Router
    function swapTokens(
        address fromToken,
        address toToken,
        uint256 amountIn
    ) external {
        require(amountIn > 0, "Amount must be greater than 0");

        // Use Chainlink Oracle to get the latest price
        uint256 fromTokenPrice = getPriceFromOracle(fromToken);
        uint256 toTokenPrice = getPriceFromOracle(toToken);

        // Perform the swap based on the obtained prices (for simplicity, slippage is not considered)
        uint256 expectedAmountOut = (amountIn * fromTokenPrice) / toTokenPrice;

        IERC20(fromToken).safeApprove(address(uniswapRouter), amountIn);

        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;

        uint256[] memory amounts = uniswapRouter.swapExactTokensForTokens(
            amountIn,
            expectedAmountOut,
            path,
            address(this),
            block.timestamp + 3600 // 1 hour deadline
        );

        emit TokensSwapped(msg.sender, fromToken, toToken, amounts[0], amounts[1]);
    }

    // Use Chainlink Oracle to get the latest price of a token
    function getPriceFromOracle(address token) internal view returns (uint256) {
        AggregatorV3Interface oracle = AggregatorV3Interface(token == address(0) ? ethUsdOracle : tokenUsdOracle);
        (, int256 price, , , ) = oracle.latestRoundData();
        require(price > 0, "Invalid price from Chainlink Oracle");
        return uint256(price);
    }

    // Owner function to withdraw tokens from the contract
    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner(), amount);
    }

    // Owner function to update the Uniswap V2 Router address
    function updateRouterAddress(address _routerAddress) external onlyOwner {
        routerAddress = _routerAddress;
        uniswapRouter = IUniswapV2Router02(routerAddress);
    }

    // Owner function to update Chainlink Oracle addresses
    function updateOracleAddresses(address _ethUsdOracle, address _tokenUsdOracle) external onlyOwner {
        ethUsdOracle = _ethUsdOracle;
        tokenUsdOracle = _tokenUsdOracle;
    }
}

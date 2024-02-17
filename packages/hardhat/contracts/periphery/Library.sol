// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { LiquidityPair } from "../core/LiquidityPair.sol";
import { Factory } from "../core/Factory.sol";
import { ILiquidityPair } from "../interfaces/ILiquidityPair.sol";

library Library {

    /// @dev fetches reserves for a pair, adjusting for token order
    function getReserves(address factoryAddress, address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = ILiquidityPair(pairFor(factoryAddress, token0, token1)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    /// @dev calculates output amount for given input and reserves
    function quote(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
        require(amountIn != 0, "Insufficient amount");
        require(reserveIn != 0 && reserveOut != 0, "Insufficient liquidity");
        return (amountIn * reserveOut) / reserveIn;
    }

    /// @notice taking fee
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        require(amountIn != 0, "Insufficient amount");
        require(reserveIn != 0 && reserveOut != 0, "Insufficient liquidity");

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;

        return numerator / denominator;
    }

    /// @notice set as internal, change if needed
    function getAmountsOut(address factory, uint256 amountIn, address[] memory path) internal view returns (uint256[] memory) {
        require(path.length >= 2, "Invalid path");
        uint256[] memory amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i = 0; i < path.length - 1; i++) {
            (uint256 reserve0, uint256 reserve1) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserve0, reserve1);     
        }
        return amounts;
    }

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        require(amountOut != 0, "Insufficient amount");
        require(reserveIn != 0 && reserveOut != 0, "Insufficient liquidity");

        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;

        return (numerator / denominator) + 1;
    }

    function getAmountsIn(
        address factory, uint256 amountOut, address[] memory path) internal view returns (uint256[] memory) {
        require(path.length >= 2, "Invalid path");
        uint256[] memory amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;

        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserve0, uint256 reserve1) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserve0, reserve1);
        }
        return amounts;
    }

    /// @dev sorts tokens by address to ensure consistent order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        return tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    /// @dev simulates CREATE2 to compute address of a given pair
    function pairFor(address factoryAddress, address tokenA, address tokenB) internal pure returns (address pairAddress) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pairAddress = address(uint160(uint256(keccak256(abi.encodePacked(
            hex"ff", // standard prefix for CREATE2 to ensure unique address generation
            factoryAddress, 
            keccak256(abi.encodePacked(token0, token1)), // hash of concatenated token addresses
            keccak256(type(LiquidityPair).creationCode) // hash of pair contract creation code
        )))));

    }
}
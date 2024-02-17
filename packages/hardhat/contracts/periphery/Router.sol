// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { LiquidityPair } from "../core/LiquidityPair.sol";
import { ILiquidityPair } from "../interfaces/ILiquidityPair.sol";
import { IFactory } from "../interfaces/IFactory.sol";
import { Library } from "./Library.sol";

contract Router {
    IFactory factory;

    constructor(address factoryAddress){
        factory = IFactory(factoryAddress);
    }


/// @notice  Arithmic operation resulted in underflow or overflow. Panic(17)
    function addLiquidity(
        address tokenA, 
        address tokenB, 
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) public returns (uint256 amountA, uint256 amountB, uint256 liquidity) { 
        // create new pair if needed
        if (factory.getPair(tokenA, tokenB) == address(0)){
            factory.createPair(tokenA, tokenB);
        }
        (amountA, amountB) = _calculateLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        address pairAddress = Library.pairFor(address(factory), tokenA, tokenB);
        _safeTransferFrom(tokenA, msg.sender, pairAddress, amountA);
        _safeTransferFrom(tokenB, msg.sender, pairAddress, amountB);
        // mint user's LP tokens
        liquidity = LiquidityPair(pairAddress).mint(to);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) public returns (uint256 amountA, uint256 amountB) {
        address pair = Library.pairFor(address(factory), tokenA, tokenB);
        ILiquidityPair(pair).transferFrom(msg.sender, pair, liquidity);
        (amountA, amountB) = ILiquidityPair(pair).burn(to);
        require(amountA > amountAMin, "Insufficient A amount");
        require(amountB > amountBMin, "Insufficient B amount");
    }

    /// @dev allows users to swap an exact amount of input tokens for as many output tokens as possible
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to
    ) public returns (uint256[] memory amounts) {
        amounts = Library.getAmountsOut(address(factory), amountIn, path);
        require(amounts[amounts.length -1] >= amountOutMin, "Insufficient output amount");
        _safeTransferFrom(
            path[0],
            msg.sender,
            Library.pairFor(address(factory), path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    /// @dev allows users to swap as few input tokens as possible to receive an exact amount of output tokens
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to
        ) public returns (uint256[] memory amounts) {
        amounts = Library.getAmountsIn(address(factory), amountOut, path);
        require(amounts[amounts.length -1] >= amountInMax, "Excessive input amount");
        _safeTransferFrom(
            path[0],
            msg.sender,
            Library.pairFor(address(factory), path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    /// @dev executes a series of swaps across a path of token pairs
    function _swap(uint256[] memory amounts, address[] memory path, address to_) internal {
        for(uint256 i = 0; i < path.length - 1; i++){
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = Library.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            // conditionaly set a zero value for token being swapped and a non-zero amount for token to be received
            (uint256 amount0Out, uint256 amount1Out) = input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
            // for intermediate swaps, set 'to' as the next pair's address; for the final swap, set 'to' as the recipient
            address to = i < path.length - 2 ? Library.pairFor(address(factory), output, path[i +2]) : to_;
            // perform swap on pair address
            ILiquidityPair(Library.pairFor(address(factory), input, output)).swap(amount0Out, amount1Out, to);
        }
    } 

    function _calculateLiquidity(
        address tokenA, 
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal view returns (uint256 amountA, uint256 amountB) {
        (uint256 reserveA, uint256 reserveB) = Library.getReserves(address(factory), tokenA, tokenB);
        // initial liquidity event, desired liquidity amounts will define the reserves ratio
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        // subsequent liquidity events, calculate the optimal amount of tokenA and tokenB to add to pool
        } else {
            uint256 amountBOptimal = Library.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired){
                require(amountBOptimal >= amountBMin, "Insufficient B amount");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = Library.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                if (amountAOptimal <= amountAMin) revert("Insufficient A amount");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                from,
                to,
                value
            )
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed");
    }

} 
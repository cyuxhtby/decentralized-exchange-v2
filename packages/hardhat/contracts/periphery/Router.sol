// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { LiquidityPair } from "../core/LiquidityPair.sol";
import { IFactory } from "../interfaces/IFactory.sol";
import { Library } from "../lib/Library.sol";

contract Router {
    IFactory factory;

    constructor(address factoryAddress){
        factory = IFactory(factoryAddress);
    }

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
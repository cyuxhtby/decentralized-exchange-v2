//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./lib/Math.sol";
import "./interfaces/IERC20.sol";
import "solmate/tokens/ERC20.sol";

// a new SwapPair liquidity pool is made by the factory for unique token pairs 

contract SwapPair is ERC20, Math {

    // the amount to be subtracted from the initial LP provider
    // to be used as safety measure to ensure that the pool always has a minimum value
    uint256 constant MIN_LIQUIDITY = 1000; 

    address public token0;
    address public token1;

    uint256 private reserve0;
    uint256 private reserve1;

    constructor(address token0_, address token1_) 
        ERC20("Swap Pair Token", "SPT", 18)
    {
        token0 = token0_;
        token1 = token1_;
        
    }

    function mint() public {
        (uint256 _reserve0, uint256 _reserve1, ) = getReserves();
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 =  IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 -  _reserve1;
        
        uint256 liquidity;

        // TODO: calculate how much to mint 
        
    }

    function getReserves() public view returns (uint256, uint256, uint32){
        return (reserve0, reserve1, 0);
    }


    function burn() public {}

    function sync() public {}



}
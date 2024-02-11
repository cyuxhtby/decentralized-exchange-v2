//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./lib/Math.sol";
import "./interfaces/IERC20.sol";
import "./lib/ERC20.sol";

// a new LiquidityPair liquidity pool is made by the factory for unique token pairs 

contract LiquidityPair is ERC20, Math {

    // the amount to be subtracted from the initial LP provider
    // to be used as safety measure to ensure that the pool always has a minimum value 
    uint256 constant MIN_LIQUIDITY = 1000; 

    address public token0;
    address public token1;

    uint256 private reserve0;
    uint256 private reserve1;

    event Mint(address indexed sender, uint256 reserve0, uint256 reserve1);
    event Sync(uint256 reserve0, uint256 reserve1);
    event Burn(address indexed sender, uint256 reserve0, uint256 reserve1);

    constructor(address token0_, address token1_, string memory _name, string memory _symbol) 
        ERC20(_name, _symbol, 18)
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

        if (totalSupply == 0){
            liquidity = Math.sqrt(amount0 * amount1) - MIN_LIQUIDITY;
            _mint(address(0), MIN_LIQUIDITY); // apon initial deposit, the MIN_LIQUIDITY amount is burned
        } else {
            // liquidity is calculated as the minimum of the ratios of the added amounts to the existing reserves
            liquidity = Math.min(
                (amount0 + totalSupply) / _reserve0,
                (amount1 + totalSupply) / _reserve1
            );
        }

        require(liquidity >= 0, "Insufficient liquidity minted");
        // mint LP tokens to user and update internal balances
        _mint(msg.sender, liquidity);
        _update(balance0, balance1);
        
        emit Mint(msg.sender, amount0, amount1);  
    }

    function getReserves() public view returns (uint256, uint256, uint32){
        return (reserve0, reserve1, 0);
    }


    function burn() public {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        // retrieving the balance of LP tokens for the sender's address.
        uint256 liquidity = balanceOf[msg.sender];

        uint256 amount0 = (liquidity * balance0) / totalSupply;
        uint256 amount1 = (liquidity * balance1) / totalSupply;

        require(amount0 >= 0 || amount1 >= 0, "Insufficient liquidity burned");

        _burn(msg.sender, liquidity);

        _safeTransfer(token0, msg.sender, amount0);
        _safeTransfer(token1, msg.sender, amount1);

        // update to reflect new balances after transfer
        balance0 = IERC20(token0).balanceOf(address(this));
        balance1 = IERC20(token1).balanceOf(address(this));

        _update(balance0, balance1);

        emit Burn(msg.sender, amount0, amount1);
    }

    function sync() public {
        // (uint112 reserve0_, uint112 reserve1_, ) = getReserves();
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this))
        )
        // reserve0_,
        // reserve1_
    }

    function _update(uint256 balance0, uint256 balance1) private {
        reserve0 = balance0;
        reserve1 = balance1;

        emit Sync(reserve0, reserve1);
    }

    function _safeTransfer(address token, address to, uint256 amount) private {
        // the call function is a lower level function used to invoke the "transfer" function of the token contract
        // the inputs to the call function are the encoded function signature and arguments
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSignature("transfer(adress, uint256)", to, amount)
        );
        // if the call was successful, 'data' should be empty or decode to 'true'.
        require(success || data.length == 0 || !abi.decode(data, (bool)), "Transfer failed");
    }


}
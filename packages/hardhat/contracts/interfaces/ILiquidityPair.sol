// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface ILiquidityPair {
    event Mint(address indexed sender, uint256 reserve0, uint256 reserve1);
    event Sync(uint256 reserve0, uint256 reserve1);
    event Burn(address indexed sender, uint256 reserve0, uint256 reserve1, uint256 amount0, uint256 amount1);
    event Swap(address indexed sender, uint256 amount0Out, uint256 amount1Out, address to);

    function initialize(address _token0, address _token1) external;
    function mint(address to) external;
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function swap(uint256 amount0Out, uint256 amount1Out, address to) external;
    function sync() external;

    function getReserves() external view returns (uint256 reserve0, uint256 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function factory() external view returns (address);
    function price0ComulativeLast() external view returns (uint256);
    function price1ComulativeLast() external view returns (uint256);

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract TokenSwapPathRegistry {
    mapping(address => mapping(address => address[])) public tokenSwapPaths;

    event TokenSwapPathSet(address tokenIn, address tokenOut, address[] path);

    function getTokenSwapPath(address tokenIn, address tokenOut) public view returns (address[] memory) {
        return tokenSwapPaths[tokenIn][tokenOut];
    }

    function _setTokenSwapPath(
        address tokenIn,
        address tokenOut,
        address[] memory path
    ) internal {
        tokenSwapPaths[tokenIn][tokenOut] = path;
        emit TokenSwapPathSet(tokenIn, tokenOut, path);
    }
}
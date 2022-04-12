//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimonToken is ERC20 {

    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply_
    ) ERC20(name, symbol) {
        _mint(msg.sender, totalSupply_);
    }

}

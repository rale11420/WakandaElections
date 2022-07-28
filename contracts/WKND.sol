// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract WKND is ERC20 {

    constructor() ERC20("WakandaToken", "WKND") {
        _mint(msg.sender, 6000000);
    }

}
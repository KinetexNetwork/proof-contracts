// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {IERC20Native} from "../../native/interfaces/IERC20Native.sol";

contract TestWETH is ERC20, IERC20Native {
    constructor() ERC20("WETH Test", "WETHT") {}

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount_) external {
        _burn(msg.sender, amount_);
        Address.sendValue(payable(msg.sender), amount_);
    }
}

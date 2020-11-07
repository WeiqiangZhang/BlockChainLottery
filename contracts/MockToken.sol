pragma solidity ^0.6.8;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    uint256 public _totalSupply = 1000000;
    string public _name = "MockToken";
    string public _symbol = "MOK";
    uint8 public _decimals = 18;

  constructor() public ERC20(_name, _symbol) {
    _mint(_msgSender(), _totalSupply);
  }
}

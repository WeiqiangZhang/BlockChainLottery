pragma solidity ^0.6.8;

import "hardhat/console.sol";
import "./MockToken.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MockLottery is AccessControl {

  using SafeMath for uint;

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
  mapping(address => bool) public managers;
  MockToken public tokenContract;
  uint public ticketPrice;
  address[] public players;
  uint public prizePool;
  uint public usagePool;
  uint public lastSelected;

  constructor(MockToken _tokenContract, uint _ticketPrice, address manager1, address manager2) public {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(MANAGER_ROLE, manager1);
    _setupRole(MANAGER_ROLE, manager2);
    tokenContract = _tokenContract;
    ticketPrice = _ticketPrice;
    prizePool = 0;
    usagePool = 0;
    lastSelected = 0;
  }

  modifier restricted() { 
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not the owner"); 
    _; 
  }

  function addManager(address _manager) public {
    grantRole(MANAGER_ROLE, _manager);
  }
  
  function removeManager(address _manager) public {
    revokeRole(MANAGER_ROLE, _manager);
  }

  function setTicketPrice(uint _price) public restricted {
    require(players.length == 0);
    ticketPrice = _price;
  }

  function enter(uint _numTickets) public {
    require(_numTickets >= 1);
    uint price = _numTickets.mul(ticketPrice);
    tokenContract.transferFrom(msg.sender, address(this), price);
    prizePool += (price);
    for (uint i; i < _numTickets; i++) {
      players.push(msg.sender);
    }
  }

  function random() private returns (uint pseudoRandom) {
    return uint(keccak256(abi.encodePacked(now, block.difficulty, players)));
  }

  function selectWinner() public {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(MANAGER_ROLE, msg.sender));
    require((now - lastSelected).div(60).div(60) >= 5); // Can only select a winner every 5 minutes
    uint index = random() % players.length;
    uint winnerPool = prizePool.mul(95).div(100);
    prizePool.sub(winnerPool);
    uint usageFee = prizePool;
    prizePool = 0;
    lastSelected = now;
    tokenContract.transfer(players[index], winnerPool);
    delete players;
    usagePool += usageFee;
  }

  function withdrawUsagePool() public restricted {
    tokenContract.transfer(msg.sender, usagePool);
  }
}

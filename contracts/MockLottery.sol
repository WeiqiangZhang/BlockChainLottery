pragma solidity ^0.6.8;

import "hardhat/console.sol";
import "./MockToken.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract MockLottery {

  using SafeMath for uint;

  address public owner;
  mapping(address => bool) public managers;
  MockToken public tokenContract;
  uint public ticketPrice;
  address[] public players;
  uint public prizePool;
  uint public usagePool;

  constructor(MockToken _tokenContract, uint _ticketPrice) public {
    owner = msg.sender;
    tokenContract = _tokenContract;
    ticketPrice = _ticketPrice;
    prizePool = 0;
    usagePool = 0;
  }

  modifier restricted() { 
    require(msg.sender == owner); 
    _; 
  }

  function addManager(address _manager) public restricted  {
    managers[_manager] = true;
  }
  
  function removeManager(address _manager) public restricted  {
    delete managers[_manager];
  }

  function setOwner(address _owner) public restricted  {
    owner = _owner;
  }

  function setTicketPrice(uint _price) public restricted  {
    require(players.length == 0);
    ticketPrice = _price;
  }

  function enter(uint _numTickets) public {
    require(_numTickets >= 1);
    uint price = _numTickets.mul(ticketPrice);
    tokenContract.transferFrom(msg.sender, address(this), price);
    prizePool.add(price);
    for (uint i; i < _numTickets; i++) {
      players.push(msg.sender);
    }
  }

  function selectWinner() public {
    require(msg.sender == owner || managers[msg.sender]);
    uint pseudoRandom = uint(keccak256(abi.encodePacked(now, block.difficulty, players)));
    uint index = pseudoRandom % players.length;
    uint winnerPool = prizePool.div(20);
    prizePool.sub(winnerPool);
    uint usageFee = prizePool;
    prizePool = 0;
    tokenContract.transfer(players[index], winnerPool);
    usagePool.add(usageFee);
  }

  function withdrawUsagePool() public {
    require(msg.sender == owner);
    tokenContract.transfer(owner, usagePool);
  }
}

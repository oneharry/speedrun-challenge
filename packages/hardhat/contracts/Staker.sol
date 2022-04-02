// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {


  ExampleExternalContract public exampleExternalContract;

  //Keeping track of individual balances of user
  mapping(address => uint256) public balances;

  //threshold of 1 ether
  uint256 public constant threshold = 1 ether;


    //the event to be emmited after each stake
  event Stake(address indexed sender, uint256 amount);

  //MODIFIERS
  
  modifier notCompleted() {
    bool complete = exampleExternalContract.completed();
    require(!complete, "Staking has ended!!");
    _;
  }

  //modifier to ensure its deadline
  //uses cases in withraw and execute functions
  modifier isDeadline() {

    require(timeLeft() == 0, "It is eadline yet");
    _;
  }

  //bool to check users eligibilty to withdraw

  bool public openForWithdraw;

// setting deadline
  uint256 deadline = block.timestamp + 60 seconds;


  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    
  }

  //receive fallback function
  receive() external payable {
    //update the balance of sender
    stake();
  }



  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() public payable {
    //update the staked balance of the user
    balances[msg.sender] += msg.value;
    
    emit Stake(msg.sender, msg.value);
  }


   function timeLeft() public view returns(uint256) {
    //return time left 
    if(deadline >= block.timestamp) {
      return deadline - block.timestamp;
    } else {
      return 0;
    }
  }



  function execute()
   public
   notCompleted
   isDeadline
    {
      uint256 contractBalance = address(this).balance;
      //ensure contract balance has reached 1 ether threshold

      if(contractBalance >= threshold) {
      //send the balance to the contract
      (bool success,) = address(exampleExternalContract).call{value: contractBalance}(abi.encodeWithSignature("complete()"));

      //Transfer must be succesful
      require(success, "Tranfer to exampleContract failed");
      
      } else {
        //if contract balance is less than threshold, open for withrawal
        openForWithdraw = true;
      }
  }

  //withdraw function
  function withdraw ()
    public
    isDeadline
   {
    uint256 userBalance = balances[msg.sender];
  //ensure user has a stake
    require(userBalance > 0, "You don't have any stake");

    //transfer the stake amount to user
        (bool success,) = msg.sender.call{value: userBalance}("");
      require(success, "Withrawal failed");

    //set users balance to zero
    userBalance = 0;

    openForWithdraw = false;

  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()


}

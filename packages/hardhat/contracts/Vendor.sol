pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  //event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

  //1 ETH for 100 tokens
  uint256 public constant tokensPerEth = 100;


  YourToken public yourToken;

  //sets Yourtoken contract to yourToken variable
    constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);

  }

  function buyTokens() 
    public
    payable
    returns (uint256 _amountOfTokens) {
      _amountOfTokens = tokensPerEth * msg.value;

      //check if vendor has enough tokens to transfer
      //confirms that user must pay some ETH for tokens
      //transfer tokens to user

      uint256 userBalance = yourToken.balanceOf(address(this));
      require(userBalance >= _amountOfTokens, "You dont have enough token to transfer");
      require(msg.value > 0, "You have to pay for Tokens");

      //transfer tokens to the user
      //catching error if transfer fails
      (bool success) = yourToken.transfer(msg.sender, _amountOfTokens);
      require(success, "Failed to complete buying transaction");
     
      //emit the transaction on the network
      emit BuyTokens(msg.sender, msg.value, _amountOfTokens);

      //return the total tokens bought
      return _amountOfTokens;
    }


    //onlyOwner modifier ensures only the owner can withdraw
    function withdraw() 
      public
      onlyOwner
      {
        // checks that there must ETH balance to withdraw
        uint ethBalance = address(this).balance;
        require(ethBalance > 0, "There is nothing to withdraw");

        //sending ETH to owner
        (bool success,) = msg.sender.call{value: ethBalance}("");
        require(success, "Withrawal failed!");
      }


      function sellTokens (uint256 _amount) 
        public
        
        {

          //amount of tokens should be greater than 1
          require(_amount > 0, "You can't seel 0 Tokens");

          //call the approve function to allow 
          uint approved = _amount *10 ** 18;
          (bool success) = yourToken.approve(address(this), approved);
          require(success, "Not approved");

          //does user have enough Tokens to sell
          uint256 userTokenBalance = yourToken.balanceOf(msg.sender);
          require(userTokenBalance >= _amount, "You don't have enough tokens");

          //Check if vendor contract has enough ETH to buy _amount tokens
          uint256 ethValueOfTokens = _amount / tokensPerEth;
          uint256 contractETHBalance = address(this).balance;

          require(contractETHBalance >= ethValueOfTokens, "Not enough ETH to buy that amount of Tokens");

          (success) = yourToken.transferFrom(msg.sender, address(this), _amount);
          require(success, "Selling failed!!");

          //sending the ETH value of token to user
          (success,) = msg.sender.call{value: ethValueOfTokens}("");
          require(success, "Error paying user");
        }



}

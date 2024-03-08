// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction{

    //Account that money will be sent to at the end of the auction
    address payable public beneficiary;

    uint public auctionEndTime; // End time of an auction
    string private secretMessage; // Auction award

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    bool isEnded;

    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint biddingTime,
                address payable beneficiaryAddress,
                string memory secret)
    {

        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
        secretMessage = secret;

    }

    function bid() external payable {

        if(isEnded){
            revert("Auctions has ended!");
        }

        if(msg.value <= highestBid){
            revert("There is already a higher or equal bid.");
        }

        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit HighestBidIncrease(msg.sender, msg.value);

    }

    function withdraw() external returns (bool){

        uint amount = pendingReturns[msg.sender];

        if(amount > 0){
            pendingReturns[msg.sender] = 0;

            bool isTransactionSuccessful = payable (msg.sender).send(amount);

            if(!isTransactionSuccessful){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;

    }

    function getSecretMessage() external view returns (string memory){

        require(isEnded, "Auction has not yet ended");
        require(msg.sender == highestBidder, "Only the auction winnder can access the code.");
        return secretMessage;

    }

    function auctionEnd() external {

        if(block.timestamp < auctionEndTime){
            revert("Auction has not yet ended");
        }

        if(isEnded){
            revert("Auction has already ended");
        }

        isEnded = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);

    }

}
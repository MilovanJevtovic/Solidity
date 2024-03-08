// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Auction.sol";

contract AuctionFactory{

    Auction[] public auctions;

    function createAuction(uint biddingTime,address payable beneficiaryAddress,string memory secret) public {

        Auction newAuction = new Auction(biddingTime, beneficiaryAddress, secret);
        auctions.push(newAuction);

    }

    function getAllAuctions() public view returns(Auction[] memory){
        return auctions;
    }

}
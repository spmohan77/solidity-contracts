// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.30.0;
contract MoneyTransfer{
    address owner;
    constructor(){
        owner=msg.sender;
    }
    modifier isOwner(){
        require(msg.sender==owner,"You are not authroised to do this action");
        _;
    }

    function deposit() payable external{
    }

    function transfer(address _receiver,uint256 _amount) isOwner() payable public{
        require(address(this).balance>_amount,"No sufficient balance in the contract to proceed the transfer");
        payable(_receiver).transfer(_amount);
    }

    function balanceOf() public view returns(uint){
        return address(this).balance;
    }
}
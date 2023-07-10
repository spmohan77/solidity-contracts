// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <=0.30.0;
contract FundTransferParent2Childrens{
    struct TransactionData{
        uint amount;
        uint timeToMaturity;
        bool isPaid;
    }
    mapping(address=>TransactionData) public Kids;
    address public owner;
    event KiddoEvent(
        TransactionData kidInfo
    );
    constructor() {
        owner=msg.sender;
    }
    modifier isOwner(){
        require(msg.sender==owner,"You are not a owner for this contract");
        _;
    }
    function addKid(address _kid, uint _amount, uint _timeToMaturity) isOwner() payable public{
        emit KiddoEvent(Kids[_kid]);
        require(_kid!=owner,"Owner can't add their account as kid");
        require(Kids[_kid].amount==0,"Kid already added");
        require(_amount>0,"Amount can not be less than Zero");
        Kids[_kid]=TransactionData(_amount,block.timestamp+_timeToMaturity,false);
    }

    function withdraw(address _kid_address) payable public{
        require(Kids[_kid_address].amount!=0,"Kid's details not found");
        require((Kids[_kid_address].amount)*(10**18)==msg.value,"Partial withdraw is not allowed. Withdraw the complete amount");
        require(Kids[_kid_address].isPaid==false,"Already withdraw the amount");
        require(Kids[_kid_address].timeToMaturity<=block.timestamp,"Maturity period is not reached. Please wait for the maturity");
        payable(_kid_address).transfer(msg.value);
        Kids[_kid_address].isPaid=true;
    }
    
}
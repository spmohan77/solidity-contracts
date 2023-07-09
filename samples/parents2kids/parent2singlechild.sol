// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.30.0;
contract parent2singlechild{
    address kid;
    uint maturity;
    event TransactionInfo(
        uint time,
        uint maturity,
        address kid_address
    );
    constructor(address _kid,uint timetomaturity) payable {
        maturity=block.timestamp+timetomaturity;
        kid=_kid;
        emit TransactionInfo(block.timestamp,maturity,kid);
    }

    function withdraw(address _kid) public payable{
        emit TransactionInfo(block.timestamp,maturity,_kid);
        require(block.timestamp>maturity,"Too early to withdraw");
        require(kid==_kid,"Only child can withdraw");
        require(address(this).balance>0,"Low balance");
        payable(_kid).transfer(address(this).balance);
    }
}
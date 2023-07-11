// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <=0.30.0;
contract LottoryApp{
    address public admin;
    address payable[] public participants;
    uint randNo = 0;

    constructor(){
        admin=msg.sender;
    }
    modifier isOwner(){
        require(msg.sender==admin,"You are not a owner for this contract");
        _;
    }

    function isParticipantsExists(address _sender) view private returns(bool){
        for (uint i=0;i<participants.length;i++){
            if(participants[i]==_sender){
                return true;
            }
        }
        return false;
    }

    receive() external payable{
        require(msg.value>=1 ether,"Require to invest minimum 1 ether");
        require(isParticipantsExists(msg.sender)==false ,"Participants already exists");
        participants.push(payable(msg.sender));
    }

    function getBalance() isOwner() public view returns(uint) {
        return address(this).balance;
    }

    function randomNumber() internal view returns(uint){
        return uint (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)));
    }

    function TheWinner() isOwner() public returns(address){
        require(participants.length>=3,"Minimum 3 participants required to announce the winner");
        require(address(this).balance>=1 ether,"The balance of the contract went low. Can't announce winner with this balance");
        uint random=randomNumber();
        address payable winner=participants[random%participants.length];
        payable(winner).transfer(address(this).balance);
        return winner;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <=0.30.0;
contract CrowdFunding{
    address public manager;
    mapping(address=>uint) public  contributors;
    uint public target;
    uint public minDeadLine;
    uint public totalContributors;
    uint public raisedAmount;
    uint public minContribution;
    uint public totalAllowedContributors;
    struct request{
        string summary;
        address payable receiver;
        uint amount;
        bool isCompleted;
        uint minVotesrequired;
        mapping(address=>bool) voters;
        uint receivedVotes;
    }
    mapping(uint=>request) public Requests;

    modifier isOwner(){
        require(msg.sender==manager,"You are not authorised to access this property");
        _;
    }
    constructor(uint _targetAmount,uint _deadLineSec,uint _minContribution, uint _totalAllowedContributors){
        target=_targetAmount;
        manager=msg.sender;
        minDeadLine=block.timestamp+_deadLineSec;
        minContribution=_minContribution;
        totalAllowedContributors=_totalAllowedContributors;
        // raisedAmount=0;
    }

    receive() external payable {
        require(contributors[msg.sender]==0,"You have already contributed");
        require(msg.value>=minContribution,"You need to contribute minimum amount");
        require(block.timestamp<=minDeadLine,"Crowd funding deadline is over already");
        require(raisedAmount<=target,"Crowd funding target acheived. No fund value available");
        require(totalAllowedContributors>=(totalContributors+1),"Allowed contributors already participated");
        contributors[msg.sender]=msg.value;
        raisedAmount+=msg.value;
        totalContributors+=1;
    }


    function getBalance() isOwner() public view returns(uint){
        return address(this).balance;
    }

    function refund() public payable {
        require(block.timestamp>=minDeadLine,"Can not process refund within the crowd funding deadline");
        require(contributors[msg.sender]!=0,"Contributor record not available");
        require(msg.value==contributors[msg.sender],"Contributors refund amount is not matching");
        require(raisedAmount>=target,"Crowd funding target not acheived yet.Refund can't processed");
        require(contributors[msg.sender]<=address(this).balance,"Contract don't have sufficient payment. You have to wait.");
        payable(msg.sender).transfer(contributors[msg.sender]);
    }

    function createFundingRequest(uint _requestId,address _receiver, uint _amount,string memory _requestSummary,uint minVotesRequired) isOwner() public{
        require(Requests[_requestId].amount==0,"Request already exists");
        // require(_amount<address(this).balance,"Amount can't be more than the raised fund amount");
        require(_amount<=address(this).balance/2,"Amount can not be more than half of the fund");
        request storage newRequest =  Requests[_requestId];
        newRequest.summary = _requestSummary;
        newRequest.receiver = payable(_receiver);
        newRequest.amount = _amount;
        newRequest.isCompleted = false;
        newRequest.minVotesrequired = minVotesRequired;
    }

    function makeVote(uint _requestId) public{
        address receiver=payable(msg.sender);
        require(contributors[msg.sender]!=0,"You are not a contributor. So can't vote");
        require(Requests[_requestId].amount!=0,"Request not exists");
        require(Requests[_requestId].voters[receiver]==false,"You have placed your vote already");
        require(Requests[_requestId].receivedVotes<=Requests[_requestId].minVotesrequired-1,"Minimum votes required has been reached");
        Requests[_requestId].voters[receiver]=true;
        Requests[_requestId].receivedVotes++;
    }

    function processRequestedFund(uint _requestId) isOwner() public payable {
        require(Requests[_requestId].receivedVotes>=Requests[_requestId].minVotesrequired,"You don't have enough votes to process the payment");
        require(Requests[_requestId].isCompleted==false,"Request has been processed already");
        require(Requests[_requestId].amount<=address(this).balance,"Contract don't have sufficient payment");
        payable(Requests[_requestId].receiver).transfer(Requests[_requestId].amount);
        Requests[_requestId].isCompleted=true;
        raisedAmount=raisedAmount-Requests[_requestId].amount;
    }

}
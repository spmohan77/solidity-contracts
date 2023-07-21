// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.30.0;

contract MyNewToken{
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;

    mapping(address=>uint) public balanceOf;
    mapping(address=>mapping(address=>uint256)) public allowance;

    event TransferEvent(
        address from,
        address to,
        uint256 value
    );

    event approvalEvent(
        address from,
        address to,
        uint256 value
    );

    constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _totalSupply){
        name=_name;
        symbol=_symbol;
        decimals=_decimals;
        totalSupply=_totalSupply;
        balanceOf[msg.sender]=_totalSupply;
    }

    function internalTransfer(address _from, address _to, uint256 _value) internal {
        require(_to!=address(0),"Not a valid address");
        require(balanceOf[_from]>_value,"Low balance");
        require(msg.sender==address(_from),"You can not process this transaction as you are not from user");
        require(_value>100,"You have to transfer minimum token of 100");
        balanceOf[_from]=balanceOf[_from]-_value;
        balanceOf[_to]=balanceOf[_to]+_value;
        emit TransferEvent(_from, _to, _value);
    }

    function Transfer(address _to,uint256 _value) external returns(bool){
        internalTransfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender,uint256 _value) external returns(bool){
        require(_spender!=address(0),"Not a valid address");
        require(balanceOf[msg.sender]>_value,"Low balance");    
        // require(balanceOf[msg.sender]>_value,"Low balance");    
        allowance[msg.sender][_spender]=_value;
        emit approvalEvent(msg.sender, _spender, _value);
        return true;    
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns(bool) {
        require(_to!=address(0),"Not a valid address");
        require(balanceOf[_from]>_value,"Low balance"); 
        require(allowance[_from][msg.sender]>_value,"Low balance"); 
        allowance[_from][msg.sender]=allowance[_from][msg.sender]-_value;
        internalTransfer(_from, _to, _value);
        return true;
    }

}

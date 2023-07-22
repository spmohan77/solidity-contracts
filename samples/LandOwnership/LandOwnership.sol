// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.30.0;
contract LandOwnership{
    struct land{
        uint landId;
        address owner;
        uint price;
        string place;
    }
    mapping(address=>land[]) public landOwners;
    uint landCounter;
    address contractOwner;
    event addLandEvent(uint _landId, address indexed _owner, uint _price,string _place);
    event transferLandEvent(uint _landId,address indexed _from, address indexed _to);
    constructor(){
        contractOwner=msg.sender;
        landCounter=0;
    }
    modifier isOwner(){
        require(msg.sender==contractOwner,"You are not authorised to perform this action");
        _;
    }
    function isActualOwner(uint _landId) view internal returns(string memory _place, uint _price,int _index){
        bool isOwned=false;
        land memory landInfo;
        int indexValue=-1;
        for(uint i=0;i<landOwners[msg.sender].length;i++){
            if(landOwners[msg.sender][i].landId==_landId){
                isOwned=true;
                landInfo=land({
                    landId:landOwners[msg.sender][i].landId,
                    owner:landOwners[msg.sender][i].owner,
                    price:landOwners[msg.sender][i].price,
                    place:landOwners[msg.sender][i].place
                });
                indexValue=int(i);
            }
        }
        require(isOwned==true,"You are not a owner of the land");
        return (landInfo.place,landInfo.price,indexValue);
    }
    function addLand(uint _price, string memory _place) isOwner() public returns(bool){
        require(_price>0,"Price can not be zero");
        landCounter++;
        landOwners[msg.sender].push(land({
           landId:landCounter,
           owner:msg.sender,
           price:_price,
           place:_place
        }));
        emit addLandEvent(landCounter, msg.sender, _price, _place);
        return true;
    }
    function transferLand(address _buyer,uint _landId) public returns(bool){
        (string memory _place, uint _price,int _index)=isActualOwner(_landId);
        require(_index!=-1,"Land not found");
        //transfer to new owner
        landOwners[_buyer].push(land(
            {
                landId:_landId,
                owner:_buyer,
                price:_price,
                place:_place
            }
        ));
        //delete from existing owner
        delete landOwners[msg.sender][uint(_index)];
        emit transferLandEvent(_landId, msg.sender, _buyer);
        return true;
    }
    function getOwnerDetails(address _landOwner, uint _index) public view returns(uint landId,
        address owner,
        uint price,
        string memory place){
            return(landOwners[_landOwner][_index].landId,landOwners[_landOwner][_index].owner,landOwners[_landOwner][_index].price,landOwners[_landOwner][_index].place);
    } 

    function getLandsCount(address _landOwner) public view returns(uint){
        return landOwners[_landOwner].length;
    }
}
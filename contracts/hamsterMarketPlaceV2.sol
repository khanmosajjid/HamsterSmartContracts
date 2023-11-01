// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract HamsterMarketPlaceV2 is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    // (Previous state variables and functions...)
 using AddressUpgradeable for address payable;
 event BuyNFTEvent(address indexed collection,address indexed _from, address indexed _to,uint _tokenID, uint256 _price);
    event ListNFTEvent(address indexed collection,address indexed _from,uint _tokenID, uint256 _price);
    event EditNFTPriceEvent(address indexed collection,uint indexed _tokenID,uint256 _price);
    event DelistNFTEvent(address indexed collection , uint indexed _tokenID);
    event AddNewCollectionEvent(address indexed collection);

    address payable commissionAddress;
    uint public constant COMMISSION = 5;

    struct Log {
        address owner;
        address contractAddress;
        uint tokenID;
        uint price;
        string action;
    }

    struct NFTListing {
        address contractAddress;
        address owner;
        bool isAvailable;
        uint256 price;
        uint tokenID;
    }

    mapping(address => mapping(uint => NFTListing)) public marketPlaceListing;
    NFTListing[] private listed; 
    Log[] private history;
    address[] private validNFTContracts;
    event TestingEvent(string message);

 function initialize(address[] memory _validNFTContracts, address payable _commissionAddress) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        require(_commissionAddress != address(0), "Invalid commission address");
        commissionAddress = _commissionAddress;
        for(uint i = 0; i < _validNFTContracts.length; i++) {
            require(_validNFTContracts[i] != address(0), "Invalid contract address");
            validNFTContracts.push(_validNFTContracts[i]);
        }
    }

     function BuyNFT(address _contractAddress,uint _tokenID) public nonReentrant payable {
               IERC721Upgradeable nft = IERC721Upgradeable(_contractAddress);
         address lastOwner = marketPlaceListing[_contractAddress][_tokenID].owner;
        require(nft.ownerOf(_tokenID) == lastOwner , "not owner any more");
        require(isValidNFTContracts(_contractAddress) , "This collection cant be sold on this marketplace");
        require(nft.getApproved(_tokenID) == address(this) , "NFT is not approved by owner");
        require(marketPlaceListing[_contractAddress][_tokenID].isAvailable , "NFT not on sale");
        require(marketPlaceListing[_contractAddress][_tokenID].price == msg.value , "You dont have enough funds to buy this NFT");

        uint myPrecious = (msg.value * COMMISSION) / 100; 
        uint ownerCommission = msg.value - myPrecious;
        payable( marketPlaceListing[_contractAddress][_tokenID].owner).sendValue(ownerCommission);
        commissionAddress.sendValue(myPrecious);
        marketPlaceListing[_contractAddress][_tokenID].isAvailable = false;
        marketPlaceListing[_contractAddress][_tokenID].owner = msg.sender;
        nft.safeTransferFrom(lastOwner,msg.sender,_tokenID);
        uint index = findIndex(_contractAddress,_tokenID);
        remove(index);
        history.push(Log(msg.sender,_contractAddress,_tokenID,msg.value,"Buy"));
        emit BuyNFTEvent(_contractAddress,lastOwner,msg.sender,_tokenID,msg.value);
        

       
    }
    function ListNFt(address _contractAddress,uint _tokenID,uint256 _price) nonReentrant public{
        require(!marketPlaceListing[_contractAddress][_tokenID].isAvailable , "This NFT is already listed");

              IERC721Upgradeable nft = IERC721Upgradeable(_contractAddress);
        
        require(isValidNFTContracts(_contractAddress) , "This collection cant be sold on this marketplace");
        require(nft.ownerOf(_tokenID) == msg.sender , "You are not the owner");
        require(nft.getApproved(_tokenID) == address(this) , "Please approve NFT for this contract");

        marketPlaceListing[_contractAddress][_tokenID].contractAddress = _contractAddress;
        marketPlaceListing[_contractAddress][_tokenID].isAvailable = true;
        marketPlaceListing[_contractAddress][_tokenID].owner = msg.sender;
        marketPlaceListing[_contractAddress][_tokenID].price = _price;
        marketPlaceListing[_contractAddress][_tokenID].tokenID = _tokenID;
        listed.push(marketPlaceListing[_contractAddress][_tokenID]);
        history.push(Log(msg.sender,_contractAddress,_tokenID,_price,"List"));
        emit ListNFTEvent(_contractAddress,msg.sender,_tokenID,_price);
    }

    function EditNFtPrice(address _contractAddress,uint _tokenID,uint256 _price) nonReentrant public {
                IERC721Upgradeable nft = IERC721Upgradeable(_contractAddress);
        require(isValidNFTContracts(_contractAddress) , "This collection cant be sold on this marketplace");
        require(nft.ownerOf(_tokenID) == msg.sender , "You are not the owner");
        require(nft.getApproved(_tokenID) == address(this) , "Please approve NFT for this contract");
        require(marketPlaceListing[_contractAddress][_tokenID].isAvailable , "NFT not on sale");
        marketPlaceListing[_contractAddress][_tokenID].price = _price;

        uint index = findIndex(_contractAddress,_tokenID);
        remove(index);
        listed.push(marketPlaceListing[_contractAddress][_tokenID]);
        history.push(Log(msg.sender,_contractAddress,_tokenID,_price,"Edit"));
        emit EditNFTPriceEvent(_contractAddress,_tokenID,_price);
    }
   
     function DelistNFT(address _contractAddress,uint _tokenID) nonReentrant public {
               IERC721Upgradeable nft = IERC721Upgradeable(_contractAddress);
        require(isValidNFTContracts(_contractAddress) , "This collection cant be sold on this marketplace");
        require(nft.ownerOf(_tokenID) == msg.sender , "You are not the owner");
        require(marketPlaceListing[_contractAddress][_tokenID].isAvailable , "NFT not on sale");
        uint index = findIndex(_contractAddress,_tokenID);
        remove(index);
        marketPlaceListing[_contractAddress][_tokenID].isAvailable = false;
        history.push(Log(msg.sender,_contractAddress,_tokenID,0,"DeList"));
        emit DelistNFTEvent(_contractAddress,_tokenID);
    
    }

    function isValidNFTContracts(address contractAddress) public view returns(bool){
        for(uint i=0;i<validNFTContracts.length;i++){
            if(validNFTContracts[i] == contractAddress){
                return true;
            }
        }
        return false;
    }

    function getListed() public view returns(NFTListing[] memory){
        return listed;
    }
    function getHistory() public view returns(Log[] memory){
        return history;
    }


    function remove(uint index) private{
        listed[index] = listed[listed.length - 1];
        listed.pop();
    }
    function findIndex(address _contractAddress,uint _tokenID) private view returns (uint){
        uint index = 0 ;
        for(uint i =0;i<listed.length;i++){
            if(listed[i].contractAddress == _contractAddress && listed[i].tokenID == _tokenID){
                index = i;
                break;
            }
        }
        return index;
    }
    function addNFTCollection(address _contractAddress) public onlyOwner{
        require(_contractAddress!=address(0), "Invalid address");
        require(!isValidNFTContracts(_contractAddress) , "Contract already added in list");
        validNFTContracts.push(_contractAddress);
        emit AddNewCollectionEvent(_contractAddress);
    }
    function testingFunction() public {
        emit TestingEvent("This is a test function in V2");
    }

    // (Rest of the contract...)

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IHamsterMarketplace {
    function onTokenTransfer(address from, uint256 tokenId) external;
}
contract HamsterCharacterNFTs is ERC721EnumerableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable  {
    uint[] private mintedNFTs;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using AddressUpgradeable for address payable;

    CountersUpgradeable.Counter public _tokenIdCounter;
    
    event MintNFTEvent(address indexed _to, uint indexed _tokenID);
    string public baseURI;


    address public marketplaceAddress;

    uint[] public UltraRare;
    uint256 constant public ULTRA_RARE_PRICE = 25e17;
    uint constant public MAX_ULTRARARE_SUPPLY = 1;

    uint[] public Rare;
    uint256 constant public RARE_PRICE = 125e16;
    uint constant public MAX_RARE_SUPPLY = 1;

    uint256 constant public COMMON_PRICE = 15e16;
    uint constant public     MAX_COMMON_SUPPLY = 1;

    address payable public payable_address;
    mapping(uint256 => string) private _tokenURIs;
   

    modifier onlyMarketplace() {
        require(msg.sender == marketplaceAddress, "Only the marketplace can call this");
        _;
    }

    function initialize(uint[] memory rareList, uint[] memory ultraRareList, string memory BaseURI, address payable payableAddress) public initializer {
        __ERC721_init("Hamster Genesis Characters", "HGC");
        __ERC721Enumerable_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        require(payableAddress != address(0), "Invalid address");
        Rare = rareList;
        UltraRare = ultraRareList;
        baseURI = BaseURI;
        payable_address = payableAddress;
   
    }

    function setMarketplace(address _marketplaceAddress) external onlyOwner {
        marketplaceAddress = _marketplaceAddress;
    }


function _mint(address to, uint256 tokenId) internal virtual override(ERC721Upgradeable) {
    super._mint(to, tokenId);

    // // Place the logic that was in _beforeTokenTransfer here:
    // if (address(0) != to && marketplaceAddress != address(0)) {
    //     IHamsterMarketplace market = IHamsterMarketplace(marketplaceAddress);
    //     market.onTokenTransfer(msg.sender, tokenId);
    // }
}

function _transfer(address from, address to, uint256 tokenId) internal virtual override(ERC721Upgradeable) {
    // Place the logic that was in _beforeTokenTransfer here:
    super._transfer(from, to, tokenId);
    if (from != address(0) && from != to && marketplaceAddress != address(0)) {
        IHamsterMarketplace market = IHamsterMarketplace(marketplaceAddress);
        market.onTokenTransfer(from, tokenId);
    }
    

}




    function mintToAddress(address to,uint id) public onlyOwner {
        require(IsValid(id),"Not a valid NFT id");
        if(IsRare(id)){
            require(TotalMinted(id) < MAX_RARE_SUPPLY , "Reached Max limit already");
            mintNewNFT(to,id);
        } else if(IsUltraRare(id)){
            require(TotalMinted(id) < MAX_ULTRARARE_SUPPLY , "Reached Max limit already");
            mintNewNFT(to,id);
        } else {
            require(TotalMinted(id) < MAX_COMMON_SUPPLY , "Reached Max limit already");
            mintNewNFT(to,id);
        }
    }


    function mintBatchToAddress(uint[] calldata ids, address to) public onlyOwner {
        for(uint i=0; i<ids.length; i++) {
            require(IsValid(ids[i]),"Not a valid NFT id");
            if(IsRare(ids[i])){
                 require(TotalMinted(ids[i]) < MAX_RARE_SUPPLY , "Reached Max limit already");
                 mintNewNFT(to,ids[i]);
             } else if(IsUltraRare(ids[i])){
                 require(TotalMinted(ids[i]) < MAX_ULTRARARE_SUPPLY , "Reached Max limit already");
                 mintNewNFT(to,ids[i]);
            } else {
                 require(TotalMinted(ids[i]) < MAX_COMMON_SUPPLY , "Reached Max limit already");
                 mintNewNFT(to,ids[i]);
            }
        }
    }
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    function mintNewNFT(address to,uint id) private {
         _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, string(abi.encodePacked(Strings.toString(id),".json")));

        mintedNFTs.push(id);
        emit MintNFTEvent(to,tokenId);
    }

    function mintNFT(uint id) external payable nonReentrant {
        require(IsValid(id),"Not a valid NFT id");
        if(IsRare(id)){
            require(TotalMinted(id) < MAX_RARE_SUPPLY , "Reached Max limit already");
            require(msg.value == RARE_PRICE,"Price did not match");
            mintNewNFT(msg.sender,id);
        } else if(IsUltraRare(id)){
            require(TotalMinted(id) < MAX_ULTRARARE_SUPPLY , "Reached Max limit already");
            require(msg.value == ULTRA_RARE_PRICE,"Price did not match");
            mintNewNFT(msg.sender,id);
        } else {
            require(TotalMinted(id) < MAX_COMMON_SUPPLY , "Reached Max limit already");
            require(msg.value == COMMON_PRICE,"Price did not match");
            mintNewNFT(msg.sender,id);
        }
        payable_address.sendValue(msg.value);
    }

    function IsValid(uint id) public pure returns (bool) {
        return (id > 0 && id <= 5000);
    }

    function IsRare(uint id) public view returns (bool) {
        for(uint i=0; i<Rare.length; i++) { 
            if(Rare[i] == id) return true;
        }
        return false;
    }

    function IsUltraRare(uint id) public view returns (bool) {
        for(uint i=0; i<UltraRare.length; i++) { 
            if(UltraRare[i] == id) return true;
        }
        return false;
    }

    function TotalMinted(uint id) public view returns (uint) {
        uint count = 0;
        for(uint i=0; i<mintedNFTs.length; i++) {
            if(mintedNFTs[i] == id) count++;
        }
        return count;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _burn(uint256 tokenId) internal override(ERC721Upgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function transfer(address to,uint256 tokenId) external{
        _transfer(msg.sender, to, tokenId);
    }
}


   





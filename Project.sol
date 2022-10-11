// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.9.0;

/**
* Importing required interfaces and contracts from openzeppelin
*/
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MARVEL is ERC721, ERC721URIStorage, Pausable, Ownable {

    /**
    * State variables:
    *
    * baseURI to store base uri for every token
    * totalLimit to store total minting limit
    * whiteListedLimit to store whitelisted minting limit
    * publicLimit to store public minting limit
    * publicSale to store the status of public sale
    * mintedNFTs to track the number of total minted NFTs
    * whitelistedMintedNFTs to track the number of whitelisted minted NFTs
    * publicMintedNFTs to track the number of publicaly minted NFTs
    * pltformMintindNFTs to track the number of NFTs minted by admins
    */
    string public baseURI;
    uint public totalLimit;
    uint public whiteListedLimit;
    uint public publicLimit;
    uint public platformLimit;
    bool public publicSale;
    uint public mintedNFTs;
    uint public whitelistedMintedNFTs;
    uint public publicMintedNFTs;
    uint public pltformMintindNFTs;

    /**
    * Constructor with Token name MARVEL and symbol MCU
    */
    constructor() ERC721("MARVEL", "MCU") {}

    /**
    * Struct to store the data of every nft with id, name and metadata hash
    */
    struct nftData {
        uint Id;
        string Name;
        string MetadataHash;
    }

    /**
    * Mappings:
    *
    * whiteListedUsers to whitelisted users
    * perAddressMinting to track number of per address minted tokens
    * whiteListedAdmins to track whitelisted admins
    * NFTs to track NFTs or tokens
    */
    mapping(address => bool) public whiteListedUsers;
    mapping(address => uint) public perAddressMinting;
    mapping(address => bool) public whiteListedAdmins;
    mapping(uint => nftData) public NFTs;

    /**
    * Events
    *
    * receiveFallaback to emit when receive or fallback functions are called
    * withdrawBalance to emit when contract balance withdraws
    * publicSaleEvent to emit when public sale status is set
    * addAdminEvent toeit when admin is added
    * setMintingLimit to emit when minting limit is set
    * updateUri to emit when uri is updated
    * updateWhitelistedUser to emit when whitelisted user is updated
    */
    event receiveFallaback(string _function, address _sender, uint _value, bytes _data);
    event withdrawBalance(address _address,uint _balance);
    event publicSaleEvent(address _sender, bool _status);
    event addAdminEvent(address _admin, bool _status);
    event setMintingLimit(uint _total, uint _whitelisted, uint _platform, uint _public);
    event updateUri(address _sender, string _uri);
    event updateWhitelistedUser(address _sender, address _user, bool _status);

    /**
    * perAddressLimit to revert if minting after per address limit is exceeded
    * totalMintLimit to revert if minting after total minting limit is exceeded
    * notWhitelistedAdmin to revert if try to update base uri with not being whitelisted admin
    * notWhitelistedUser to revert if try to mint with not being whitelisted user
    * whitelistedUserLimit to revert if try to mint with whitelited minting limit is exceeded
    * publicSaleStatus to revet if try to mint with public sale not active
    * publicMintLimit to revert if try to mint with public minting limit exceeded
    * platformMintLimit to revert if try to mint with platform minting limit exceeded
    */
    error perAddressLimit(string);
    error totalMintLimit(string);
    error notWhitelistedAdmin(string);
    error notWhitelistedUser(string);
    error whitelistedUserLimit(string);
    error publicSaleStatus(string);
    error publicMintLimit(string);
    error platformMintLimit(string);

    /**
    * @dev  receive function to receive Ethers.
    *
    * Requirements:
    * Only called when no data is sent with call
    */
    receive() external payable {
        emit receiveFallaback("receive", msg.sender, msg.value, "");
    }

    /**
    * @dev fallback function to receive call with data and value.
    *
    * Requirements:
    * Called when there is data or data plus value in call
    */
    fallback() external payable {
        emit receiveFallaback("fallback", msg.sender, msg.value, msg.data);
    }

    /**
    * @dev checkContractBalance returns the contract balance.
    * 
    * Requirements:
    * Only owner can call this function
    */
    function checkContractBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }

    /**
    * @dev withdrawContractBalance withdraws the contract balance to a specified address.
    * @param _address - Will be the address of the receiver of contract balance.
    * 
    * Requirements:
    * Only owner can call this function
    * Paused status should be false.
    */
    function withdrawContractBalance(address _address) public onlyOwner {
        require(!paused(), "Pausable: paused");
        payable(_address).transfer(address(this).balance);
        emit withdrawBalance(_address, address(this).balance);
    }
    
    /**
    * @dev pause function sets the paused status to true, pauses the mintng.
    * 
    * Requirements:
    * Only owner can call this function
    */
    function pause() public onlyOwner {
        _pause();
    }

    /**
    * @dev unpause function sets the paused status to false, unpauses the mintng.
    * 
    * Requirements:
    * Only owner can call this function
    */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
    * @dev safeMint mints the ERC721 Token.
    * @param to - Will be the address of the receiver of minted token.
    * @param name - Will be the name of the NFT.
    * @param uri - Will be the metadata hash of the minted token.
    * 
    * Requirements:
    * Total minting limit limit should not be reached.
    * Per address minting limit of 5 NFTs should not be reached.
    */
    function safeMint(address to, uint _id, string memory name, string memory uri) private {
        if(mintedNFTs >= totalLimit) {
            revert totalMintLimit("Total minting limit is reached");
        }
        if (perAddressMinting[msg.sender] >= 5) {
            revert perAddressLimit("Minting limit of 5 NFTs per address is reached");
        }
        _safeMint(to, _id);
        _setTokenURI(_id, string(abi.encode(baseURI, uri)));
        NFTs[_id] = nftData(_id, name, uri);
        perAddressMinting[msg.sender] += 1;
        mintedNFTs += 1;
    }

    /**
    * @dev setPuclicSale sets the status of public sale.
    * @param _status - Will be the status of the public sale, either true or false.
    * 
    * Requirements:
    * Only owner can call this function.
    * Paused status should be false.
    */
    function setPuclicSale(bool _status) public onlyOwner{
        require(!paused(), "Pausable: paused");
        publicSale = _status;
        emit publicSaleEvent(msg.sender, _status);
    }

    /**
    * @dev addAdmin adds an admin.
    * @param _address will be the address of the admin.
    * @param _status - Will be the status of the admin, either true or false.
    * 
    * Requirements:
    * Only owner can call this function.
    * Paused status should be false.
    */
    function addAdmin(address _address, bool _status) public onlyOwner {
        require(!paused(), "Pausable: paused");
        whiteListedAdmins[_address] = _status;
        emit addAdminEvent(_address, _status);
    }

    /**
    * @dev setMIntingLimit sets minting limit for types of minting.
    * @param _totalMinting will be the total minting limit.
    * @param _whitelistedMinting will be the whitelisted user minting limit.
    * @param _platformMinting - Will be the platform minting limit.
    * 
    * Requirements:
    * Only owner can call this function.
    * Paused status should be false.
    */
    function setMIntingLimit(
        uint _totalMinting,
        uint _whitelistedMinting,
        uint _platformMinting
    )
        public
        onlyOwner
    {
        require(!paused(), "Pausable: paused");
        totalLimit = _totalMinting;
        whiteListedLimit = _whitelistedMinting;
        publicLimit = _totalMinting - (_whitelistedMinting + _platformMinting);
        platformLimit = _platformMinting;
        emit setMintingLimit(totalLimit, whiteListedLimit, platformLimit, publicLimit);
    }

    /**
    * @dev updateBaseUri updates the base URI for all the NFTs.
    * @param _uri will be the base URI.
    * 
    * Requirements:
    * Only whitelisted admins can call this function.
    * Paused status should be false.
    */
    function updateBaseUri(string memory _uri) public {
        require(!paused(), "Pausable: paused");
        if(whiteListedAdmins[msg.sender]) {
            baseURI = _uri;
            emit updateUri(msg.sender, _uri);
        }
        else {
            revert notWhitelistedAdmin("Not a whitelisted admin");
        }
    }

    /**
    * @dev addWhitelistedUser adds or updated the whitelisted users.
    * @param _address will be the address of the user.
    * @param _status will be the status of the user, either whitelisted or not.
    * 
    * Requirements:
    * Only whitelisted admins can call this function.
    * Paused status should be false.
    */
    function addWhitelistedUser(address _address, bool _status) public {
        require(!paused(), "Pausable: paused");
        if(whiteListedAdmins[msg.sender]) {
            whiteListedUsers[_address] = _status;
            emit updateWhitelistedUser(msg.sender, _address, _status);
        }
        else {
            revert notWhitelistedAdmin("Not a whitelisted admin");
        }
    }
    
    /**
    * @dev whitelistUserMinting mints the ERC721 Token for whitelisted users only.
    * @param _to - Will be the address of the receiver of minted token.
    * @param _name - Will be the name of the NFT.
    * @param _uri - Will be the metadata hash of the minted token.
    * 
    * Requirements:
    * Public sale should be inactive.
    * Whitelisted minting limit should not be reached.
    * Sender should be whitelisted user.
    */
    function whitelistUserMinting(address _to, uint _id, string memory _name, string memory _uri) public {
        require(!publicSale, "Can't mint when public sale is active");
        if (whitelistedMintedNFTs >= whiteListedLimit) {
            revert whitelistedUserLimit("Whitelisted user minting limit is reached");
        }
        if (!whiteListedUsers[msg.sender]) {
            revert notWhitelistedUser("Not a whitelisted user");
        }
        safeMint(_to, _id, _name, _uri);
        whitelistedMintedNFTs += 1;
    }

    /**
    * @dev publicMinting mints the ERC721 Token for public users.
    * @param _to - Will be the address of the receiver of minted token.
    * @param _name - Will be the name of the NFT.
    * @param _uri - Will be the metadata hash of the minted token.
    * 
    * Requirements:
    * Public sale should be active.
    * Public minting limit should not be reached.
    */
    function publicMinting(address _to, uint _id, string memory _name, string memory _uri) public {
        if (publicMintedNFTs >= publicLimit) {
            revert publicMintLimit("Public minting limit is reached");
        }
        if (!publicSale) {
            revert publicSaleStatus("Public sale is not active");
        }
        safeMint(_to, _id, _name, _uri);
        publicMintedNFTs += 1;
    }

    /**
    * @dev platformMinting mints the ERC721 Token for admins.
    * @param _to - Will be the address of the receiver of minted token.
    * @param _name - Will be the name of the NFT.
    * @param _uri - Will be the metadata hash of the minted token.
    * 
    * Requirements:
    * Platform minting limit should not be reached.
    * Sender should be the whitelisted admin.
    */
    function platformMinting(address _to, uint _id, string memory _name, string memory _uri) public {
        if(pltformMintindNFTs >= platformLimit) {
            revert platformMintLimit("Platform minting limit is reached");
        }
        if(!whiteListedAdmins[msg.sender]) {
            revert notWhitelistedAdmin("Not a whitelisted admin");
        }
        safeMint(_to, _id, _name, _uri);
        pltformMintindNFTs += 1;
    }

    /**
    * @dev _beforeTokenTransfer checks for pauseed status before token transfer.
    * @param from - Will be the address of the sender of minted token.
    * @param to - Will be the address of the rceiver.
    * @param tokenId - Will be the token id of NFT.
    */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    /**
    * @dev _burn burns the ERC721 Token for at given id.
    * @param tokenId - Will be the token id.
    */
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /**
    * @dev tokenURI returns the token uri at the given id.
    * @param tokenId - Will be the token id.
    */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI, NFTs[tokenId].MetadataHash));
    }
}

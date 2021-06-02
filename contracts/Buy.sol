// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface MyIERC721 {
    function mint(address _to) external;
    function available() external view returns(uint256);
}


contract Buy {
    mapping(address => uint256) public card;
    mapping(address => bool) public adminList;
    
    address payable companyAddress = payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
    
    event BoughtNFT(address indexed buyer, uint256 indexed price);
    event AddedNFT(address indexed erc721, uint256 indexed price);
    event ChangedNFT(address indexed erc721, uint256 indexed price);
    event RemovedNFT(address indexed erc721);
    event AddedAdmin(address indexed admin);
    event RemovedAdmin(address indexed admin);
    
    constructor () {
        adminList[msg.sender] = true;
    }
    
    
    
    function buyNFT (address _erc721 ) public payable returns (bool) {
        require(card[_erc721] != 0, "No Card Available");
        require(MyIERC721(_erc721).available() > 0, "Card Minted Out");
        require(msg.value >= card[_erc721], "Not Enough Matic");
        
        (bool sent, bytes memory data) = companyAddress.call{value: msg.value}("");
        require(sent, "Failed to send Matic");
        MyIERC721(_erc721).mint(msg.sender);
        emit BoughtNFT(msg.sender, msg.value);
        return true;
    }
    
    function addNFT (address _erc721, uint256 price) public onlyAdmin {
        require(price > 0, "Not a valid price");
        card[_erc721] = price;
        emit AddedNFT(_erc721, price);
    }
    
    function changeNFT (address _erc721, uint256 price) public onlyAdmin {
        require(card[_erc721] != 0, "No Card to update");
        require(price > 0, "Not a valid price");
        card[_erc721] = price;
        emit ChangedNFT(_erc721, price);
    }
    
    function removeNFT (address _erc721) public onlyAdmin {
        require(card[_erc721] != 0, "No Card to remove");
        card[_erc721] = 0;
        emit RemovedNFT(_erc721);
    }
    
    function addAdmin (address _admin) public onlyAdmin {
        adminList[_admin] = true;
        emit AddedAdmin(_admin);
    }
    
    function removeAdmin (address _admin) public onlyAdmin {
        adminList[_admin] = false;
        emit RemovedAdmin(_admin);
    }
    
    modifier onlyAdmin() {
        require(adminList[msg.sender] == true, "Not Admin");
        _;
    }
}
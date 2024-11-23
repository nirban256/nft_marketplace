// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {NFTMarketplace} from "./NFTMarketplace.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketplaceFactory {
    address public owner;

    struct SaleContractDetails {
        address seller;
        bool saleActive;
    }

    mapping (address => SaleContractDetails) public contractDeployed;
    address[] public saleContracts;

    event SaleCreated(address indexed seller, address indexed contractAddress, uint256 indexed price);
    event SaleCancelled(address indexed saleContract);

    constructor() {
        require(msg.sender != address(0), "Owner cannot be the zero address");
        owner = msg.sender;
    }

    // list NFT for sale.
    function sellNFT(address _contract, uint256 _tokenId, uint256 _price) external {
        require(_contract != address(0), "invalid address");
        require(_tokenId != 0, "Token Id cannot be zero");
        require(msg.sender != address(0), "Seller cannot be the zero address");
        require(IERC721(_contract).ownerOf(_tokenId) == msg.sender, "Seller is not the owner of the NFT");

        NFTMarketplace createSale = new NFTMarketplace(msg.sender, _contract, _tokenId, _price);
        saleContracts.push(address(createSale));
        contractDeployed[address(createSale)] = SaleContractDetails({
            seller: msg.sender,
            saleActive: true
        });

        emit SaleCreated(msg.sender, _contract, _price);
    }

    // cancel sale of a particular NFT
    function cancelSale(address payable _saleContract) external {
        NFTMarketplace sale = NFTMarketplace(_saleContract);
        require(msg.sender == address(sale), "You are not the seller");
        require(contractDeployed[address(sale)].saleActive == true, "Sale is already over");

        sale.cancelSale();
        contractDeployed[address(sale)].saleActive = false;

        emit SaleCancelled(address(sale));
    }

    // get all the sale active contracts
    function getActiveSales() external view returns(address[] memory) {
        uint256 count = 0;
        address[] memory result;

        for(uint256 i=0; i<saleContracts.length; i++) {
            if(contractDeployed[saleContracts[i]].saleActive) {
                result[count] = saleContracts[i];
                count++;
            }
        }

        return result;
    }

    // get all the active contracts
    function getContractStatus(address _contractAddress) external view returns(bool) {
        return contractDeployed[_contractAddress].saleActive;
    }

    // get seller of a particular contract
    function getSeller(address _contractAddress) external view returns(address) {
        return contractDeployed[_contractAddress].seller;
    }

    // receive function
    receive() external payable {
        revert("Unrecognized transaction!");
    }

    // fallback function
    fallback() external payable {
        revert("Transaction not authorized!");
    }
}
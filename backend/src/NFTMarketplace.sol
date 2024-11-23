// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {
    address public owner;
    address public nftSeller;
    address public nftContract;
    uint256 public tokenId;
    uint256 public price;
    bool private isSaleActive;

    event NFTListed(address indexed nftSeller, address indexed nftContract, uint256 indexed tokenId);
    event NFTSold(address indexed buyer, address indexed seller, uint256 indexed price);
    event SaleCancelled(address indexed seller);

    constructor(address _seller, address _contract, uint256 _tokenId, uint256 _price) {
        owner = msg.sender;
        nftSeller = _seller;
        nftContract = _contract;
        tokenId = _tokenId;
        price = _price;
        isSaleActive = true;

        emit NFTListed(nftSeller, nftContract, tokenId);
    }

    function buyNFT() external payable nonReentrant {
        require(isSaleActive, "Sale is not active");
        require(msg.value == price, "Price send is not equal to the nft price");
        require(IERC721(nftContract).ownerOf(tokenId) == nftSeller, "Seller no longer owns the nft");
        require(msg.sender != address(0), "Invalid address");

        payable(nftSeller).transfer(msg.value);
        IERC721(nftContract).safeTransferFrom(nftSeller, msg.sender, tokenId);

        isSaleActive = false;
        emit NFTSold(msg.sender, nftSeller, msg.value);
    }

    function cancelSale() external nonReentrant {
        require(msg.sender == nftSeller, "Only the seller can cancel the sale");
        require(getSaleStatus(), "The sale is over");

        isSaleActive = false;
        payable(owner).transfer(address(this).balance);

        emit SaleCancelled(nftSeller);
    }

    function getSaleStatus() public view returns(bool) {
        return isSaleActive;
    }

    receive() external payable {
        revert("Unrecognized transaction");
    }
}
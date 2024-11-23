//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import {Base64} from "./libraries/Base64.sol";

contract NFT is ERC721URIStorage, Ownable {

    uint256 private _tokenIds;

    string nftImageURI;
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    address payable public withdrawWallet;
    mapping(address => uint256) public walletMints;

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor(string memory _nftImageURI)
        payable
        ERC721("Avax Wolverine", "AW")
        Ownable(msg.sender)
    {
        nftImageURI = _nftImageURI;
        mintPrice = 0.75 ether;
        totalSupply = 0;
        maxSupply = 10;
        maxPerWallet = 2;
        withdrawWallet = payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        _tokenIds++;
    }

    function setIsPublicMintEnabled(bool _isPublicMintEnabled)
        external
        onlyOwner
    {
        isPublicMintEnabled = _isPublicMintEnabled;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{value: address(this).balance}(
            ""
        );
        require(success, "withdraw failed");
    }

    function mint(uint256 _quantity) public payable {
        require(isPublicMintEnabled, "minting not enabled");
        require(msg.value == _quantity * mintPrice, "wrong mint value");
        require(totalSupply + _quantity <= maxSupply, "sold out");
        require(
            walletMints[msg.sender] + _quantity <= maxPerWallet,
            "exceeded wallet mint limit"
        );

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "Avalanche AVAX", "description": "A sunset scenery.", "image": "',
                nftImageURI,
                '"}'
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        uint256 newItemId = _tokenIds;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, output);

        _tokenIds++;

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}
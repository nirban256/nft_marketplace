// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/NFTMarketplaceFactory.sol";

contract DeployNFTMarketplaceFactory is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the NFTMarketplaceFactory contract
        NFTMarketplaceFactory nftFactory = new NFTMarketplaceFactory();
        console.log("NFTMarketplaceFactory deployed at ", address(nftFactory));

        vm.stopBroadcast();
    }
}
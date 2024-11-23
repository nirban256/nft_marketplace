# NFT Marketplace Contract

## NFTMarketplace contract

It is the contract which will be deployed for each individual marketplace NFT. It will work only till the NFT is sold and after that it will not work further, in case of cancellation it will transfer all the remaining funds in the deployer contract's address, i.e. the **NFTMarketplaceDeployer** contract

## NFTMarketplaceDeployer contract

It is the main contract which deploys each individual contract for listing NFT in the marketplace. It works in the factory pattern and keeps track of each deployed NFT that is listed in the marketplace.

This is the basic implementation of NFT Markeplace contract in the factory pattern.
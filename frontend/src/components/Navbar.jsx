import React, { useState } from 'react';
import { ethers } from 'ethers';
import { Button } from './ui/button';

const Navbar = () => {
    const [walletState, setWalletState] = useState("not_connected"); // State for button status
    const [walletAddress, setWalletAddress] = useState(null); // To store wallet address if connected

    const connectWallet = async () => {
        setWalletState("connecting");

        try {
            // Check if window.ethereum exists
            if (typeof window.ethereum === "undefined") {
                alert("No Ethereum wallet detected. Please install MetaMask!");
                setWalletState("not_connected");
                return;
            }

            // Initialize ethers.js provider
            const provider = new ethers.providers.Web3Provider(window.ethereum);

            // Request wallet connection
            await provider.send("eth_requestAccounts", []);
            const signer = provider.getSigner();
            const address = await signer.getAddress();

            // Update state on successful connection
            setWalletAddress(address);
            setWalletState("connected");
        } catch (error) {
            console.error("Wallet connection failed:", error);
            setWalletState("not_connected"); // Revert to not connected
        }
    };

    return (
        <div className=' bg-slate-700/35 p-4 flex justify-between'>
            <h1 className='flex items-center'>
                NFT Marketplace
            </h1>
            <Button
                onClick={connectWallet}
                variant={walletState === "connecting" ? "outline" : "default"} // state-based styling
                disabled={walletState === "connecting"} // Disable button during connection
            >
                {walletState === "not_connected" && "Connect Wallet"}
                {walletState === "connecting" && "Connecting..."}
                {walletState === "connected" && `Connected (${walletAddress.slice(0, 6)}...${walletAddress.slice(-4)})`}
            </Button>
        </div>
    )
}

export default Navbar
"use client";

import { useState } from "react";
import { ethers } from "ethers";

declare global {
  interface Window {
    ethereum?: ethers.Eip1193Provider;
  }
}

interface WalletConnectProps {
  onConnect: (address: string, provider: ethers.BrowserProvider) => void;
}

export default function WalletConnect({ onConnect }: WalletConnectProps) {
  const [account, setAccount] = useState<string | null>(null);

  const connectWallet = async () => {
    if (!window.ethereum) {
      alert("Please install MetaMask to connect your wallet.");
      return;
    }

    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const address = await signer.getAddress();

    setAccount(address);
    onConnect(address, provider);
  };

  return (
    <div>
      {account ? (
        <p className='text-green-600'>Connected: {account}</p>
      ) : (
        <button
          onClick={connectWallet}
          className='px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition'>
          Connect Wallet
        </button>
      )}
    </div>
  );
}

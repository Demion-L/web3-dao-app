"use client";

import { ethers } from "ethers";
import { useDispatch, useSelector } from "react-redux";
import { connectWallet } from "../store/features/walletSlice";
import { RootState } from "../store/store";

declare global {
  interface Window {
    ethereum?: ethers.Eip1193Provider;
  }
}

export default function WalletConnect() {
  const dispatch = useDispatch();
  const account = useSelector((state: RootState) => state.wallet.account);

  const handleConnectWallet = async () => {
    if (!window.ethereum) {
      alert("Please install MetaMask to connect your wallet.");
      return;
    }

    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const address = await signer.getAddress();

      dispatch(connectWallet(address)); // Redux handles state updates
    } catch (error) {
      console.error("Failed to connect wallet:", error);
    }
  };

  return (
    <div>
      {account ? (
        <p className='text-green-600'>Connected: {account}</p>
      ) : (
        <button
          onClick={handleConnectWallet}
          className='px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition'>
          Connect Wallet
        </button>
      )}
    </div>
  );
}

"use client";

import { ethers } from "ethers";
import { useDispatch, useSelector } from "react-redux";
import { connectWallet, disconnectWallet } from "../store/features/walletSlice";
import { RootState } from "../store/store";
import { WalletConnectProps } from "@/types/wallet";
import { useEffect, useState } from "react";

declare global {
  interface Window {
    ethereum?: ethers.Eip1193Provider & {
      on: (
        event: "accountsChanged" | "chainChanged",
        callback: (accounts: string[] | string) => void
      ) => void;
      removeListener: (
        event: "accountsChanged" | "chainChanged",
        callback: (accounts: string[] | string) => void
      ) => void;
    };
  }
}

export default function WalletConnect({
  onConnect,
  onDisconnect,
  className,
}: WalletConnectProps) {
  const dispatch = useDispatch();
  const account = useSelector((state: RootState) => state.wallet.account);
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);

    // Listen for account changes
    if (window.ethereum) {
      const handleAccountsChanged = (accounts: string[] | string) => {
        const accountArray = Array.isArray(accounts) ? accounts : [accounts];
        if (accountArray.length === 0) {
          // User disconnected their wallet
          handleDisconnectWallet();
        } else {
          // User switched accounts
          dispatch(connectWallet(accountArray[0]));
          onConnect?.(accountArray[0]);
        }
      };

      const handleChainChanged = () => {
        window.location.reload();
      };

      window.ethereum.on("accountsChanged", handleAccountsChanged);
      window.ethereum.on("chainChanged", handleChainChanged);

      return () => {
        if (window.ethereum) {
          window.ethereum.removeListener(
            "accountsChanged",
            handleAccountsChanged
          );
          window.ethereum.removeListener("chainChanged", handleChainChanged);
        }
      };
    }
  }, [dispatch, onConnect]);

  const handleConnectWallet = async () => {
    if (!window.ethereum) {
      alert("Please install MetaMask to connect your wallet.");
      return;
    }

    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const address = await signer.getAddress();

      dispatch(connectWallet(address));
      onConnect?.(address);
    } catch (error) {
      console.error("Failed to connect wallet:", error);
    }
  };

  const handleDisconnectWallet = () => {
    dispatch(disconnectWallet());
    onDisconnect?.();
  };

  if (!isMounted) {
    return null;
  }

  return (
    <div className={className}>
      {account ? (
        <div className='flex items-center gap-4'>
          <p className='text-green-600'>Connected: {account}</p>
          <button
            onClick={handleDisconnectWallet}
            className='px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition'>
            Disconnect
          </button>
        </div>
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

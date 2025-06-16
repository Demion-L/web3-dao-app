"use client";

import { ethers } from "ethers";
import { useDispatch, useSelector } from "react-redux";
import { connectWallet, disconnectWallet } from "@/store/features/walletSlice";
import { RootState } from "@/store/store";
import { WalletConnectProps } from "@/types/Iwallet";
import { useEffect, useState, useCallback } from "react";
import { formatAddress } from "@/utils/format";
import { Button } from "./ui/Button";

export default function WalletConnect({
  onConnect,
  onDisconnect,
  className,
}: WalletConnectProps) {
  const dispatch = useDispatch();
  const account = useSelector((state: RootState) => state.wallet.account);
  const [isMounted, setIsMounted] = useState(false);

  const handleDisconnectWallet = useCallback(() => {
    dispatch(disconnectWallet());
    onDisconnect?.();
  }, [dispatch, onDisconnect]);

  useEffect(() => {
    setIsMounted(true);

    if (window.ethereum) {
      const handleAccountsChanged = (accounts: string[] | string) => {
        const accountArray = Array.isArray(accounts) ? accounts : [accounts];
        if (accountArray.length === 0) {
          handleDisconnectWallet();
        } else {
          // We'll update the account only, provider and signer will be updated on reconnect
          dispatch(disconnectWallet());
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
  }, [dispatch, onConnect, handleDisconnectWallet]);

  const handleConnectWallet = async () => {
    if (!window.ethereum) {
      alert("Please install MetaMask to connect your wallet.");
      return;
    }

    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const address = await signer.getAddress();

      dispatch(connectWallet({ account: address, provider, signer }));
      onConnect?.(address);
    } catch (error) {
      console.error("Failed to connect wallet:", error);
    }
  };

  if (!isMounted) {
    return null;
  }

  return (
    <div className={className}>
      {account ? (
        <div className='flex items-center gap-4'>
          <div className='flex items-center gap-2'>
            <div className='w-2 h-2 rounded-full bg-green-500'></div>
            <span className='text-sm font-mono text-primary'>
              {formatAddress(account)}
            </span>
          </div>
          <Button
            onClick={handleDisconnectWallet}
            variant='danger'
            size='sm'>
            Disconnect
          </Button>
        </div>
      ) : (
        <Button
          onClick={handleConnectWallet}
          variant='primary'>
          Connect Wallet
        </Button>
      )}
    </div>
  );
}

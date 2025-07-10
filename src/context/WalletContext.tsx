import React, { createContext, useContext, useState, useCallback } from "react";
import { ethers } from "ethers";
import { IWalletContext } from "@/types/IWallet";
import { getWalletInfo } from "@/utils/getWalletInfo";

const WalletContext = createContext<IWalletContext | undefined>(undefined);

export const WalletProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [account, setAccount] = useState<string | null>(null);
  const [provider, setProvider] = useState<ethers.BrowserProvider | null>(null);
  const [signer, setSigner] = useState<ethers.Signer | null>(null);
  const [isConnecting, setIsConnecting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const connectWallet = useCallback(async () => {
    console.log("connectWallet called");
    console.log("window.ethereum", window.ethereum);

    setIsConnecting(true);
    try {
      const { provider, signer, address } = await getWalletInfo();

      setProvider(provider);
      setSigner(signer);
      setAccount(address);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setIsConnecting(false);
    }
  }, []);

  const disconnectWallet = useCallback(() => {
    setAccount(null);
    setProvider(null);
    setSigner(null);
    setError(null);
  }, []);

  // Todo: auto-connect logic here

  return (
    <WalletContext.Provider
      value={{
        account,
        provider,
        signer,
        connectWallet,
        disconnectWallet,
        isConnecting,
        error,
      }}>
      {children}
    </WalletContext.Provider>
  );
};

export const useWalletContext = () => {
  const ctx = useContext(WalletContext);
  if (!ctx)
    throw new Error("useWalletContext must be used within a WalletProvider");
  return ctx;
};

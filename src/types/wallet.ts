import { ethers } from "ethers";

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

export interface WalletState {
  account: string | null;
  isConnected: boolean;
  chainId?: number | null;
  balance: string | null;
} 

export interface WalletConnectProps {
  onConnect?: (address: string) => void;
  onDisconnect?: () => void;
  walletAddress?: string | null;
  className?: string;
}
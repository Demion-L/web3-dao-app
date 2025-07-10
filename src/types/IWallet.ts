import { ethers, Provider, Signer } from "ethers";

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
  balance: string | null;
}

export interface WalletConnectProps {
  className?: string;
  onConnect?: (address: string) => void;
  onDisconnect?: () => void;
}


export interface IWalletContext {
  account: string | null;
  provider: ethers.BrowserProvider | null;
  signer: ethers.Signer | null;
  connectWallet: () => Promise<void>;
  disconnectWallet: () => void;
  isConnecting: boolean;
  error: string | null;
}
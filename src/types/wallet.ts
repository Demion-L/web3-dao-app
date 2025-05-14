
export interface WalletState {
  account: string | null;
  isConnected: boolean;
  chainId?: number | null;
  balance: string | null;
} 

export interface WalletConnectProps {
  onConnect?: (address: string) => void;
}
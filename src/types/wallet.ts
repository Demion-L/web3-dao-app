
export interface WalletState {
  account: string | null;
  isConnected: boolean;
  chainId?: number | null;
  balance?: string | null;
} 
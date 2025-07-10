import { useWalletContext } from "@/context/WalletContext";

export const useWallet = () => {

  const {
    account,
    provider,
    signer,
    isConnecting,
    error,
    connectWallet,
    disconnectWallet,
  } = useWalletContext();

  // Checks if wallet is still connected and updates context state
  const checkConnection = async () => {
    if (!window.ethereum) return false;
    try {
      const accounts = await window.ethereum.request({ method: 'eth_accounts' });
      if (accounts.length > 0) {
        // Reconnect provider/signer/account in context
        await connectWallet();
        return true;
      }
      return false;
    } catch (err) {
      console.error('Error checking connection:', err);
      return false;
    }
  };

  return {
    account,
    provider,
    signer,
    isConnecting,
    error,
    connectWallet,
    disconnectWallet,
    checkConnection,
  };
}; 
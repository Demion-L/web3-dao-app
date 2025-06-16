import { useState } from 'react';
import { ethers } from 'ethers';
import { useDispatch, useSelector } from 'react-redux';
import { RootState } from '@/store/store';
import { setAccount, setProvider, setSigner } from '@/store/features/walletSlice';

export const useWallet = () => {
  const dispatch = useDispatch();
  const { account, provider, signer } = useSelector((state: RootState) => state.wallet);
  const [isConnecting, setIsConnecting] = useState(false);

  const connectWallet = async () => {
    if (typeof window.ethereum === 'undefined') {
      alert('Please install MetaMask to use this application');
      return;
    }

    try {
      setIsConnecting(true);
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const address = await signer.getAddress();

      dispatch(setProvider(provider));
      dispatch(setSigner(signer));
      dispatch(setAccount(address));

      // Listen for account changes
      window.ethereum.on('accountsChanged', (accounts: string | string[]) => {
        dispatch(setAccount(Array.isArray(accounts) ? accounts[0] : accounts));
      });

      // Listen for chain changes
      window.ethereum.on('chainChanged', () => {
        window.location.reload();
      });
    } catch (error) {
      console.error('Error connecting wallet:', error);
    } finally {
      setIsConnecting(false);
    }
  };

  const disconnectWallet = () => {
    dispatch(setAccount(null));
    dispatch(setProvider(null));
    dispatch(setSigner(null));
  };

  return {
    account,
    provider,
    signer,
    isConnecting,
    connectWallet,
    disconnectWallet,
  };
}; 
import { useState, useCallback } from 'react';
import { ethers } from 'ethers';
import { useWallet } from './useWallet';
import { getContract, TOKEN_ABI, CONTRACT_ADDRESSES } from '@/config/contracts';

export const useToken = () => {
  const { signer } = useWallet();
  const [ balance, setBalance] = useState<string>('0');
  const [ isLoading, setIsLoading ] = useState<boolean>(false);

  const tokenContract = signer ? getContract(
    CONTRACT_ADDRESSES.token,
    TOKEN_ABI,
    signer
  ) : null;

  const getBalance = useCallback(async () => {
    if (!tokenContract || !signer) return;

    try {
      setIsLoading(true);
      const address = await signer.getAddress();
      const balance = await tokenContract.balanceOf(address);

      setBalance(ethers.formatEther(balance));
    } catch (error) {
      console.error('Error fetching token balance:', error);
    } finally {
      setIsLoading(false);
    }
  }, [tokenContract, signer]);

  const transfer = useCallback(async(to: string, amount: string) => {
    if (!tokenContract || !signer) return;
    
    try {
      setIsLoading(true);
      const amountWei = ethers.parseEther(amount);
      const tx = await tokenContract.transfer(to, amountWei);
      await tx.wait();
      await getBalance(); // Refresh balance after transfer
      return tx;
    } catch (error) {
      console.log('Error transferring tokens:', error);
    } finally {
      setIsLoading(false);
    }
  }, [tokenContract, signer, getBalance]);

  return {
    balance,
    isLoading,
    getBalance,
    transfer,
  };
};
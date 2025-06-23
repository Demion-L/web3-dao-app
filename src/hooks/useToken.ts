import { useState, useCallback, useRef } from 'react';
import { ethers } from 'ethers';
import { useWallet } from './useWallet';
import { getContract, TOKEN_ABI, CONTRACT_ADDRESSES } from '@/config/contracts';

export const useToken = () => {
  const { signer } = useWallet();
  const [ balance, setBalance] = useState<string>('0');
  const [ isLoading, setIsLoading ] = useState<boolean>(false);
  const decimalsRef = useRef<number | null>(null);

  const tokenContract = signer ? getContract(
    CONTRACT_ADDRESSES.token,
    TOKEN_ABI,
    signer
  ) : null;

  const getDecimals = useCallback(async () => {
    if (!tokenContract) return 18; // fallback
    if (decimalsRef.current !== null) return decimalsRef.current;
    try {
      const decimals = await tokenContract.decimals();
      decimalsRef.current = decimals;
      return decimals;
    } catch (e) {
      console.error('Error fetching token decimals:', e);
      return 18; // fallback
    }
  }, [tokenContract]);

  const getBalance = useCallback(async () => {
    if (!tokenContract || !signer) return;

    try {
      setIsLoading(true);
      const address = await signer.getAddress();
      const balance = await tokenContract.balanceOf(address);
      const decimals = await getDecimals();
      const formatted = ethers.formatUnits(balance, decimals);
      setBalance(formatted);
    } catch (error) {
      console.error('Error fetching token balance:', error);
    } finally {
      setIsLoading(false);
    }
  }, [tokenContract, signer, getDecimals]);

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
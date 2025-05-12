import { ethers } from 'ethers';

export async function getEthBalance(account: string): Promise<string> {
  if (!window.ethereum) {
    throw new Error('Ethereum provider not found');
  }
  const provider = new ethers.BrowserProvider(window.ethereum);
  const balance = await provider.getBalance(account);
  return ethers.formatEther(balance);
} 
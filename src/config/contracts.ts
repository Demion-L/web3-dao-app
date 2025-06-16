import { ethers, Contract, Signer, Provider, InterfaceAbi } from 'ethers';

// Contract ABIs
export const GOVERNOR_ABI = [
  // Add your GovernorContract ABI here
];

export const TOKEN_ABI = [
  // Add your MyToken ABI here
];

export const STAKING_ABI = [
  // Add your StakingRewards ABI here
];

// Contract addresses (replace with your deployed contract addresses)
export const CONTRACT_ADDRESSES = {
  governor: '0x...', // Your GovernorContract address
  token: '0x...',    // Your MyToken address
  staking: '0x...',  // Your StakingRewards address
};

// Contract instances factory
export const getContract = (
  address: string,
  abi: InterfaceAbi,
  signerOrProvider: Signer | Provider
): Contract => {
  return new ethers.Contract(address, abi, signerOrProvider);
}; 
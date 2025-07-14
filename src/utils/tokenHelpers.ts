import { ethers } from "ethers";

export async function getCurrentVotingPower(token: ethers.Contract, account: string, provider: ethers.Provider) {
  const blockNumber = await provider.getBlockNumber();
  return token.getVotes(account, blockNumber);
} 
import { ethers } from "ethers";

export async function getCurrentblockNumberAndVotingPower(
    token: ethers.Contract, 
    account: string, 
    provider: ethers.Provider) {
  const blockNumber = await provider.getBlockNumber();
  const votingPower = await token.getVotes(account, blockNumber);
   return {
    blockNumber,
    votingPower: ethers.formatUnits(votingPower, 18)
  };
} 
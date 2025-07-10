import { IOnchainProposalInput } from "@/types/IProposal";
import { ethers } from "ethers";
import { getWalletInfo } from "@/utils/getWalletInfo";

export async function createOnchainProposal({
  target,
  ethValue,
  functionArgs,
  functionName,
  description,
}: IOnchainProposalInput) {
  const { getContract, TOKEN_ABI, GOVERNOR_ABI, CONTRACT_ADDRESSES } = await import("@/config/contracts");
  const signer = await getWalletInfo();
  // Prepare value
  const value = ethValue ? ethers.parseEther(ethValue) : 0n;
  // Prepare calldata
  const contractInterface = new ethers.Interface(TOKEN_ABI);
  const args = functionArgs ? functionArgs.split(",").map((a) => a.trim()) : [];
  const calldata = contractInterface.encodeFunctionData(functionName, args);
  const targets = [target];
  const values = [value];
  const calldatas = [calldata];
  // Governor contract
  const governor = getContract(CONTRACT_ADDRESSES.governor, GOVERNOR_ABI, signer);
  const tx = await governor.propose(targets, values, calldatas, description || "On-chain action proposal");
  const receipt = await tx.wait();
  return receipt;
} 
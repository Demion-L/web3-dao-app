import { ProposalFormData } from "@/types/IProposal";
import { IOnchainProposalInput } from "@/types/IProposal";
import { TransactionReceipt } from "ethers";

/**
 * Handles proposal submission for both description and onchain proposals.
 * @param data - The proposal form data
 * @param createProposal - Function to create a description proposal
 * @param createOnchainProposal - Function to create an onchain proposal
 * @returns The transaction receipt
 */
export async function handleProposalSubmit(
  data: ProposalFormData,
  createProposal: (description: string) => Promise<{ wait: () => Promise<TransactionReceipt> }> ,
  createOnchainProposal: (args: IOnchainProposalInput) => Promise<TransactionReceipt>
): Promise<TransactionReceipt> {
  if (data.proposalType === "description") {
    const tx = await createProposal(data.description || "No description");
    const receipt = await tx.wait();
    return receipt;
  } else if (data.proposalType === "onchain") {
    const { target, ethValue, functionArgs, functionName } = data as Extract<
      ProposalFormData,
      { proposalType: "onchain" }
    >;
    const receipt = await createOnchainProposal({
      target,
      ethValue,
      functionArgs,
      functionName,
      description: data.description || "On-chain action proposal",
    });
    return receipt;
  } else {
    throw new Error("Unknown proposal type");
  }
} 
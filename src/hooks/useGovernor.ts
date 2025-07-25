import { useState, useCallback } from "react";
import { GOVERNOR_ABI, CONTRACT_ADDRESSES, getContract } from "@/config/contracts";
import { getWalletInfo } from "@/utils/getWalletInfo";

export function useGovernor() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const createProposal = useCallback(async (description: string) => {
    setLoading(true);
    setError(null);
    try {
      const { signer } = await getWalletInfo();
      const governor = getContract(CONTRACT_ADDRESSES.governor, GOVERNOR_ABI, signer);
      const targets: string[] = [];
      const values: bigint[] = [];
      const calldatas: string[] = [];
       console.log("propose() call data:");
  console.log("targets:", targets);
  console.log("values:", values);
  console.log("calldatas:", calldatas);
  console.log("description:", description);
      const tx = await governor.propose(targets, values, calldatas, description);
      setLoading(false);
      return tx;
    } catch (err: unknown) {
      setError(err instanceof Error ? err : new Error(String(err)));
      setLoading(false);
      throw err;
    }
  }, []);

  return { createProposal, loading, error };
} 
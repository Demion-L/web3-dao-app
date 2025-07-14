"use client";

import { useEffect, useState } from "react";
import { useToken } from "@/hooks/useToken";
import NeonButton from "@/components/ui/NeonButton";
import ProposalModal from "@/components/ui/ProposalModal";
import { useGovernor } from "@/hooks/useGovernor";
import { ProposalFormData } from "@/types/IProposal";
import { createOnchainProposal } from "@/utils/createOnchainProposal";
import { useWallet } from "@/hooks/useWallet";

console.log("DASHBOARD RENDERED");
export interface IDebugInfo {
  tokenAddress: string;
  walletAddress: string;
  balance: string;
  delegatee: string;
  votes: string;
  timestamp: string;
}

export default function Dashboard() {
  const { account: walletAddress } = useWallet();
  console.log("Dashboard walletAddress:", walletAddress);
  const [isMounted, setIsMounted] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [debugInfo, setDebugInfo] = useState<IDebugInfo | null>(null);
  const [diagnosing, setDiagnosing] = useState(false);

  const {
    balance,
    votingPower,
    isLoading: isTokenLoading,
    delegationStatus,
    delegatee,
    delegateToSelf,
    getTokenData: refreshTokenData,
    refreshVotingPower,
  } = useToken();

  const [isProposalModalOpen, setProposalModalOpen] = useState(false);
  const [isCreatingProposal, setIsCreatingProposal] = useState(false);
  const { createProposal } = useGovernor();

  useEffect(() => {
    console.log("useEffect triggered, walletAddress:", walletAddress);
    setIsMounted(true);
  }, []);

  // Debug voting power with proper error handling
  useEffect(() => {
    if (!walletAddress) return;

    const checkVotingPower = async () => {
      try {
        setError(null);
        console.log("DEBUG: Starting voting power check for:", walletAddress);

        const { getContract, TOKEN_ABI, CONTRACT_ADDRESSES } = await import(
          "@/config/contracts"
        );

        if (!window.ethereum) {
          throw new Error("No crypto wallet found");
        }

        const provider = new (await import("ethers")).ethers.BrowserProvider(
          window.ethereum
        );

        const token = getContract(
          CONTRACT_ADDRESSES.token,
          TOKEN_ABI,
          provider
        );

        const currentBlock = await provider.getBlockNumber();

        // Check if contract is valid
        if (!token || !CONTRACT_ADDRESSES.token) {
          throw new Error("Token contract not found or invalid");
        }

        const [balance, delegatee, votes] = await Promise.all([
          token.balanceOf(walletAddress).catch((e: unknown) => {
            console.error("Error getting balance:", e);
            return "0";
          }),
          token.delegates(walletAddress).catch((e: unknown) => {
            console.error("Error getting delegatee:", e);
            return "0x0";
          }),
          token.getVotes(walletAddress, currentBlock).catch((e: unknown) => {
            console.error("Error getting votes:", e);
            return "0";
          }),
        ]);

        const debugData = {
          tokenAddress: CONTRACT_ADDRESSES.token,
          walletAddress,
          balance: balance.toString(),
          delegatee,
          votes: votes.toString(),
          timestamp: new Date().toISOString(),
        };

        setDebugInfo(debugData);
        console.log("=== DEBUG INFO ===", debugData);
      } catch (error: unknown) {
        console.error("Debug error:", error);
        setError(
          `Debug failed: ${
            error instanceof Error ? error.message : String(error)
          }`
        );
      }
    };

    checkVotingPower();
  }, [walletAddress]);

  useEffect(() => {
    if (walletAddress) {
      refreshTokenData().catch((err: unknown) => {
        console.error("Failed to get balance:", err);
        setError(
          `Failed to load token balance: ${
            err instanceof Error ? err.message : String(err)
          }`
        );
      });
    }
  }, [walletAddress, refreshTokenData]);

  const handleProposalSubmit = async (data: ProposalFormData) => {
    try {
      setIsCreatingProposal(true);
      setError(null);

      const { handleProposalSubmit } = await import(
        "@/utils/handleProposalSubmit"
      );

      const receipt = await handleProposalSubmit(
        data,
        createProposal,
        createOnchainProposal
      );

      console.log("Proposal created! Receipt:", receipt);
      setProposalModalOpen(false);
    } catch (err: unknown) {
      console.error("Proposal creation failed:", err);
      setError(
        `Proposal creation failed: ${
          err instanceof Error ? err.message : String(err)
        }`
      );
    } finally {
      setIsCreatingProposal(false);
    }
  };

  // Delegation diagnosis function
  const diagnoseDelegation = async () => {
    if (!walletAddress) return;
    setDiagnosing(true);
    try {
      const { getContract, TOKEN_ABI, CONTRACT_ADDRESSES } = await import(
        "@/config/contracts"
      );
      if (!window.ethereum) throw new Error("No crypto wallet found");
      const provider = new (await import("ethers")).ethers.BrowserProvider(
        window.ethereum
      );
      const token = getContract(CONTRACT_ADDRESSES.token, TOKEN_ABI, provider);
      // Get current block number
      const currentBlock = await provider.getBlockNumber();
      console.log("Current block:", currentBlock);
      // Check votes at different block heights
      const blockChecks = [
        currentBlock - 10,
        currentBlock - 5,
        currentBlock - 1,
        currentBlock,
      ];
      for (const blockNum of blockChecks) {
        if (blockNum > 0) {
          try {
            const votes = await token.getVotes(walletAddress, blockNum);
            console.log(`Block ${blockNum}: ${votes.toString()} votes`);
          } catch (e: unknown) {
            const msg =
              typeof e === "object" &&
              e &&
              "message" in e &&
              typeof (e as { message: unknown }).message === "string"
                ? (e as { message: string }).message
                : String(e);
            console.log(`Block ${blockNum}: Error - ${msg}`);
          }
        }
      }
      // Check delegation history
      const balance = await token.balanceOf(walletAddress);
      const delegatee = await token.delegates(walletAddress);
      console.log("=== DELEGATION DIAGNOSIS ===");
      console.log("Current balance:", balance.toString());
      console.log("Delegated to:", delegatee);
      console.log(
        "Is self-delegated:",
        delegatee.toLowerCase() === walletAddress.toLowerCase()
      );
      // Check if delegation was recent
      const latestVotes = await token.getVotes(walletAddress, "latest");
      console.log("Latest votes:", latestVotes.toString());
      // For governance, we need to check at proposal snapshot
      console.log("=== SOLUTION ===");
      console.log("1. Wait a few blocks after delegation");
      console.log("2. Or check votes at a specific historical block");
      console.log("3. Current votes should be:", balance.toString());
    } catch (error) {
      console.error("Diagnosis failed:", error);
    } finally {
      setDiagnosing(false);
    }
  };

  if (!isMounted) {
    return null;
  }

  return (
    <div className='flex max-w-7xl w-5/6 flex-col gap-6 dark:bg-stone-800 bg-white/90 shadow-black shadow-2xl rounded-lg p-6'>
      <div>
        <h2 className='text-2xl font-extrabold text-white rounded-lg mb-4  dark:text-shadow-neon bg-black/90 text-center py-2'>
          DAO Dashboard
        </h2>
        <p className='dark:text-cyan-300 text-cyan-800 text-center text-xl bg-slate-700/30 p-2 rounded-lg'>
          Welcome to the future of governance!
        </p>
      </div>

      {/* Error Display */}
      {error && (
        <div className='bg-red-500/10 border border-red-500/50 rounded-lg p-4'>
          <p className='text-red-400 text-sm'>{error}</p>
          <button
            onClick={() => setError(null)}
            className='text-xs text-red-300 hover:text-red-200 mt-2'>
            Dismiss
          </button>
        </div>
      )}

      {walletAddress ? (
        <div>
          <div className='space-y-4'>
            <div className='flex items-center justify-between'>
              <span className='text-secondary'>Connected as:</span>
              <span className='font-mono text-primary text-neon-cyan'>
                {walletAddress}
              </span>
            </div>
            <div className='flex items-center justify-between'>
              <span className='text-secondary'>Token Balance:</span>
              <span className='font-mono text-primary text-neon-pink'>
                {isTokenLoading ? "Loading..." : `${balance} TOKENS`}
              </span>
            </div>
            <div className='flex items-center justify-between'>
              <span className='text-secondary'>Voting Power:</span>
              <span className='font-mono text-primary text-neon-green'>
                {isTokenLoading ? "Loading..." : `${votingPower} VOTES`}
              </span>
              <NeonButton
                onClick={refreshVotingPower}
                className='ml-2 px-2 py-1 text-xs'
                disabled={isTokenLoading}>
                Refresh Voting Power
              </NeonButton>
            </div>
            <div className='flex items-center justify-between'>
              <span className='text-secondary'>Delegated To:</span>
              <span className='font-mono text-primary text-neon-yellow'>
                {delegatee === walletAddress
                  ? "Yourself"
                  : delegatee || "Not Delegated"}
              </span>
            </div>
          </div>
          <NeonButton
            onClick={refreshTokenData}
            className='mt-2'>
            Refresh Token Data
          </NeonButton>
          {/* Enhanced delegation button */}
          {walletAddress && Number(balance) > 0 && votingPower === "0" && (
            <div className='mt-4'>
              <p className='text-yellow-300 mb-2'>
                {delegationStatus || "You have tokens but no voting power."}
              </p>
              <NeonButton
                onClick={delegateToSelf}
                disabled={isTokenLoading}>
                {isTokenLoading ? "Processing..." : "Delegate to Self"}
              </NeonButton>
            </div>
          )}

          {debugInfo && (
            <details className='bg-gray-800/50 rounded-lg p-4 my-4'>
              <summary className='cursor-pointer text-sm text-gray-400 mb-2'>
                Debug Information
              </summary>
              <pre className='text-xs text-gray-300 overflow-x-auto'>
                {typeof debugInfo === "string"
                  ? debugInfo
                  : JSON.stringify(debugInfo, null, 2)}
              </pre>
            </details>
          )}

          <NeonButton
            onClick={() => setProposalModalOpen(true)}
            disabled={isCreatingProposal}>
            {isCreatingProposal ? "Creating..." : "Create Proposal"}
          </NeonButton>

          <NeonButton
            onClick={diagnoseDelegation}
            disabled={diagnosing}
            className='ml-4 mt-2'>
            {diagnosing ? "Diagnosing..." : "Diagnose Delegation"}
          </NeonButton>

          <ProposalModal
            open={isProposalModalOpen}
            onClose={() => setProposalModalOpen(false)}
            onSubmit={handleProposalSubmit}
          />
        </div>
      ) : (
        <div className='text-center py-8'>
          <p className='text-secondary text-lg'>
            Please connect your wallet to continue.
          </p>
        </div>
      )}
    </div>
  );
}

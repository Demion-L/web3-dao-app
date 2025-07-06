"use client";

import { useSelector } from "react-redux";
import { RootState } from "@/store/store";
import { useEffect, useState } from "react";
import { useToken } from "@/hooks/useToken";
import NeonButton from "@/components/ui/NeonButton";
import ProposalModal from "@/components/ui/ProposalModal";
import { useGovernor } from "@/hooks/useGovernor";
import { ProposalFormData } from "@/types/IProposal";
import { createOnchainProposal } from "@/utils/createOnchainProposal";
import { useDispatch } from "react-redux";
import {
  setAccount,
  setProvider,
  setSigner,
} from "@/store/features/walletSlice";
import { ethers } from "ethers";

console.log("Dashboard component file loaded");

export default function Dashboard() {
  console.log("Dashboard component rendered");
  const walletAddress = useSelector((state: RootState) => state.wallet.account);
  const dispatch = useDispatch();
  const [isMounted, setIsMounted] = useState(false);
  const {
    balance,
    isLoading: isTokenLoading,
    getBalance,
    votingPower,
  } = useToken();
  const [isProposalModalOpen, setProposalModalOpen] = useState(false);
  const { createProposal } = useGovernor();

  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Auto-reconnect on page load
  useEffect(() => {
    const checkConnection = async () => {
      console.log("DEBUG: Dashboard checking for existing connection...");
      if (window.ethereum) {
        try {
          const accounts = await window.ethereum.request({
            method: "eth_accounts",
          });
          console.log("DEBUG: Found accounts:", accounts);
          if (accounts.length > 0) {
            console.log("DEBUG: Auto-connecting to:", accounts[0]);
            const provider = new ethers.BrowserProvider(window.ethereum);
            const signer = await provider.getSigner();
            dispatch(setProvider(provider));
            dispatch(setSigner(signer));
            dispatch(setAccount(accounts[0]));
            console.log("DEBUG: Auto-connection successful");
          } else {
            console.log("DEBUG: No accounts found");
          }
        } catch (error) {
          console.error("Auto-connection failed:", error);
        }
      } else {
        console.log("DEBUG: No window.ethereum found");
      }
    };

    checkConnection();
  }, [dispatch]);

  useEffect(() => {
    console.log("DEBUG: useEffect triggered, walletAddress:", walletAddress);

    const checkVotingPower = async () => {
      console.log("DEBUG: checkVotingPower function called");
      if (walletAddress) {
        console.log("DEBUG: walletAddress exists, proceeding...");
        try {
          const { getContract, TOKEN_ABI, CONTRACT_ADDRESSES } = await import(
            "@/config/contracts"
          );
          if (!window.ethereum) throw new Error("No crypto wallet found");
          const provider = new (await import("ethers")).ethers.BrowserProvider(
            window.ethereum
          );
          const token = getContract(
            CONTRACT_ADDRESSES.token,
            TOKEN_ABI,
            provider
          );

          console.log("=== DEBUG INFO ===");
          console.log("Token contract address:", CONTRACT_ADDRESSES.token);
          console.log("Your wallet address:", walletAddress);

          const balance = await token.balanceOf(walletAddress);
          console.log("Token balance (raw):", balance.toString());

          const delegatee = await token.delegates(walletAddress);
          console.log("Delegatee:", delegatee);

          const votes = await token.getVotes(walletAddress, "latest");
          console.log("Voting power (raw):", votes.toString());
          console.log("=== END DEBUG ===");
        } catch (error) {
          console.error("Debug error:", error);
        }
      } else {
        console.log("DEBUG: No walletAddress");
      }
    };

    checkVotingPower();
  }, [walletAddress]);

  useEffect(() => {
    if (walletAddress) {
      getBalance();
    }
  }, [walletAddress, getBalance]);

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
      {walletAddress ? (
        <>
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
              {/* Todo: add neon-green color */}
              <span className='font-mono text-primary text-neon-green'>
                {isTokenLoading ? "Loading..." : `${votingPower} VOTES`}
              </span>
            </div>
          </div>
          <NeonButton onClick={() => setProposalModalOpen(true)}>
            Create Proposal
          </NeonButton>
          <ProposalModal
            open={isProposalModalOpen}
            onClose={() => setProposalModalOpen(false)}
            onSubmit={async (data: ProposalFormData) => {
              try {
                const receipt = await (
                  await import("@/utils/handleProposalSubmit")
                ).handleProposalSubmit(
                  data,
                  createProposal,
                  createOnchainProposal
                );
                console.log("Proposal created! Receipt:", receipt);
              } catch (err) {
                console.error("Proposal creation failed:", err);
              }
            }}
          />
        </>
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

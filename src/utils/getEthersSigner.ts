import { ethers } from "ethers";

export async function getEthersSigner() {
  if (!window.ethereum) throw new Error("No crypto wallet found");
  const provider = new ethers.BrowserProvider(window.ethereum);
  return provider.getSigner();
} 
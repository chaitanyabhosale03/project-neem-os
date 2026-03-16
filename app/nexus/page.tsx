'use client';

import { useState } from "react";
import { motion } from "framer-motion";
import { Crosshair, Shield, Zap, Package, Wallet, Eye } from "lucide-react";
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useWriteContract, useReadContract, useAccount } from 'wagmi';

const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

const nexusABI = [
  {
    "inputs": [
      { "internalType": "address", "name": "account", "type": "address" },
      { "internalType": "uint256", "name": "id", "type": "uint256" }
    ],
    "name": "mintLegendary",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "account", "type": "address" },
      { "internalType": "uint256", "name": "id", "type": "uint256" },
      { "internalType": "uint256", "name": "amount", "type": "uint256" }
    ],
    "name": "mintConsumables",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "account", "type": "address" },
      { "internalType": "uint256", "name": "id", "type": "uint256" }
    ],
    "name": "balanceOf",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  }
];

export default function NexusGaming() {
  const { address } = useAccount();
  const { writeContractAsync } = useWriteContract();
  const [activeMint, setActiveMint] = useState<number | null>(null);

  // --- VAULT DATA READING ---
  // We read the balance for IDs 0, 1, and 2
  const { data: daggerBal } = useReadContract({
    address: CONTRACT_ADDRESS, abi: nexusABI, functionName: 'balanceOf', args: [address, 0],
  });
  const { data: rifleBal } = useReadContract({
    address: CONTRACT_ADDRESS, abi: nexusABI, functionName: 'balanceOf', args: [address, 1],
  });
  const { data: healthBal } = useReadContract({
    address: CONTRACT_ADDRESS, abi: nexusABI, functionName: 'balanceOf', args: [address, 2],
  });

  const handleMintAsset = async (id: number) => {
    try {
      setActiveMint(id);
      if (id === 0) {
        await writeContractAsync({
          address: CONTRACT_ADDRESS, abi: nexusABI, functionName: 'mintLegendary',
          args: [address, id], 
        });
      } else {
        const amount = id === 1 ? 1 : 100;
        await writeContractAsync({
          address: CONTRACT_ADDRESS, abi: nexusABI, functionName: 'mintConsumables',
          args: [address, id, amount], 
        });
      }
    } catch (error) {
      console.error("WAGMI ERROR:", error);
    } finally {
      setActiveMint(null);
    }
  };

  return (
    <div className="min-h-screen bg-slate-950 text-emerald-400 font-mono pb-20">
      <div className="w-full p-6 flex justify-between items-center border-b border-emerald-500/20 bg-slate-900/50">
        <div className="flex items-center gap-3 text-2xl font-black tracking-tighter">
          <Crosshair className="text-emerald-500" />
          NEEM-OS<span className="text-white">NEXUS</span>
        </div>
        <ConnectButton />
      </div>

      {/* Hero */}
      <div className="max-w-7xl mx-auto px-6 py-12 text-center">
        <h1 className="text-4xl md:text-6xl font-black text-white mb-4 uppercase">Asset Exchange</h1>
      </div>

      {/* Inventory Display (The Vault) */}
      <div className="max-w-7xl mx-auto px-6 mb-16">
        <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-2xl p-8 backdrop-blur-sm">
          <h2 className="text-xl font-bold text-white mb-6 flex items-center gap-2">
            <Wallet className="text-emerald-500" /> YOUR SECURE VAULT
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="bg-slate-900 p-4 rounded-lg border border-slate-800">
              <p className="text-xs text-slate-500 uppercase">Daggers</p>
              <p className="text-2xl font-bold text-white">{daggerBal?.toString() || "0"}</p>
            </div>
            <div className="bg-slate-900 p-4 rounded-lg border border-slate-800">
              <p className="text-xs text-slate-500 uppercase">Rifles</p>
              <p className="text-2xl font-bold text-white">{rifleBal?.toString() || "0"}</p>
            </div>
            <div className="bg-slate-900 p-4 rounded-lg border border-slate-800">
              <p className="text-xs text-slate-500 uppercase">Health Packs</p>
              <p className="text-2xl font-bold text-white">{healthBal?.toString() || "0"}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Minting Cards */}
      <div className="max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-3 gap-6">
        {[
          { id: 0, title: "Dagger of Time", img: "https://images.unsplash.com/photo-1589923158776-cb4485d99fd6?w=400" },
          { id: 1, title: "Plasma Rifle", img: "https://images.unsplash.com/photo-1612287230202-1ff1d85d1bdf?w=400" },
          { id: 2, title: "Nano-Health", img: "https://images.unsplash.com/photo-1633526543814-9718c8922b7a?w=400" }
        ].map((item) => (
          <div key={item.id} className="bg-slate-900 border border-slate-800 rounded-xl overflow-hidden p-4">
            <img src={item.img} className="h-32 w-full object-cover rounded-lg mb-4 opacity-70" />
            <h3 className="text-white font-bold mb-4">{item.title}</h3>
            <button 
              onClick={() => handleMintAsset(item.id)}
              disabled={activeMint === item.id}
              className="w-full py-2 bg-emerald-500 text-black font-bold rounded hover:bg-emerald-400 transition-colors"
            >
              {activeMint === item.id ? "Processing..." : "Mint Asset"}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
'use client';

import { useState } from "react";
import { motion } from "framer-motion";
import { TrendingUp, Landmark, ShieldCheck, PieChart, ArrowUpRight, Globe, Wallet } from "lucide-react";
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useWriteContract, useAccount, useReadContract } from 'wagmi';
import { parseEther, formatEther } from 'viem';

const CAPITAL_ADDRESS = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";

const capitalABI = [
  { "inputs": [], "name": "invest", "outputs": [], "stateMutability": "payable", "type": "function" },
  { 
    "inputs": [{ "internalType": "address", "name": "account", "type": "address" }],
    "name": "balanceOf", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view", "type": "function" 
  }
];

export default function NeemosCapital() {
  const { address, isConnected } = useAccount();
  const { writeContractAsync } = useWriteContract();
  const [loading, setLoading] = useState(false);

  // Read the user's share balance
  const { data: shareBalance, refetch } = useReadContract({
    address: CAPITAL_ADDRESS,
    abi: capitalABI,
    functionName: 'balanceOf',
    args: [address],
  });

  const handleInvest = async () => {
    if (!isConnected) return alert("Please connect your wallet first.");
    setLoading(true);
    try {
      await writeContractAsync({
        address: CAPITAL_ADDRESS,
        abi: capitalABI,
        functionName: 'invest',
        value: parseEther('0.01'), // Investing 0.01 ETH
      });
      alert("Investment Successful!");
      refetch(); // Refresh the balance display
    } catch (err) {
      console.error("Investment failed:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#050505] text-white font-sans pb-20">
      <nav className="border-b border-white/10 bg-black/50 backdrop-blur-md p-6 flex justify-between items-center sticky top-0 z-50">
        <div className="flex items-center gap-2 text-xl font-bold tracking-tight">
          <Landmark className="text-blue-500" />
          NEEM-OS <span className="text-blue-500 uppercase text-sm tracking-widest ml-1">Capital</span>
        </div>
        <ConnectButton />
      </nav>

      <main className="max-w-7xl mx-auto px-6 py-12">
        {/* User Portfolio Header */}
        <div className="mb-12 p-8 bg-gradient-to-r from-blue-900/20 to-transparent border border-blue-500/20 rounded-3xl flex justify-between items-center">
          <div>
            <p className="text-blue-400 text-xs font-bold uppercase tracking-[0.2em] mb-2">My Holdings</p>
            <h2 className="text-4xl font-bold">
              {shareBalance ? parseFloat(formatEther(shareBalance as bigint)).toFixed(0) : "0"} 
              <span className="text-gray-500 ml-2 text-lg font-normal">DRS Shares</span>
            </h2>
          </div>
          <div className="hidden md:block">
            <div className="text-right">
              <p className="text-gray-500 text-xs uppercase mb-1">Portfolio Status</p>
              <span className="bg-emerald-500/10 text-emerald-400 text-xs px-3 py-1 rounded-full border border-emerald-500/20">Active</span>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          <div className="bg-white/5 border border-white/10 p-6 rounded-2xl">
            <TrendingUp className="text-emerald-500 mb-4" size={24} />
            <p className="text-gray-400 text-sm">Avg. Annual Yield</p>
            <h3 className="text-3xl font-bold mt-1">10.4%</h3>
          </div>
          {/* ... other stats ... */}
        </div>

        <h2 className="text-2xl font-bold mb-8">Premium Offerings</h2>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <motion.div whileHover={{ y: -5 }} className="bg-white/5 border border-white/10 rounded-3xl overflow-hidden flex flex-col md:flex-row">
            <div className="md:w-1/2 h-64 md:h-auto">
              <img src="https://images.unsplash.com/photo-1512453979798-5eaad0ff3b03?w=800&q=80" className="w-full h-full object-cover" />
            </div>
            <div className="p-8 md:w-1/2 flex flex-col justify-between">
              <div>
                <h3 className="text-2xl font-bold mb-2">Dubai Residency</h3>
                <p className="text-gray-400 text-sm mb-6 font-mono">Token: DRS (ERC-20)</p>
              </div>
              <button 
                onClick={handleInvest}
                disabled={loading}
                className="w-full py-4 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl transition-all flex items-center justify-center gap-2"
              >
                {loading ? "Processing..." : "Invest 0.01 ETH"}
                <ArrowUpRight size={18} />
              </button>
            </div>
          </motion.div>
        </div>
      </main>
    </div>
  );
}
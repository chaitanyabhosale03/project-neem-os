'use client';

import { ShieldCheck, Award, UserCheck, Fingerprint, Lock } from "lucide-react";
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useAccount, useReadContract } from 'wagmi';

const VERIFY_ADDRESS = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853";

export default function NeemosVerify() {
  const { address, isConnected } = useAccount();

  const { data: hasCredential } = useReadContract({
    address: VERIFY_ADDRESS,
    abi: [{ "inputs": [{"name": "owner", "type": "address"}], "name": "balanceOf", "outputs": [{"name": "", "type": "uint256"}], "stateMutability": "view", "type": "function" }],
    functionName: 'balanceOf',
    args: [address],
  });

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 font-sans">
      <nav className="p-6 flex justify-between items-center border-b bg-white">
        <div className="flex items-center gap-2 text-xl font-bold">
          <ShieldCheck className="text-indigo-600" size={28} />
          NEEM-OS <span className="text-slate-400 font-light">VERIFY</span>
        </div>
        <ConnectButton />
      </nav>

      <main className="max-w-4xl mx-auto px-6 py-20">
        <div className="text-center mb-16">
          <h1 className="text-4xl font-black mb-4">Immutable Identity Vault</h1>
          <p className="text-slate-500">Decentralized credentials that stay with you forever.</p>
        </div>

        {/* Digital ID Card */}
        <div className="bg-white border-2 border-slate-200 rounded-3xl p-1 shadow-2xl overflow-hidden max-w-md mx-auto">
          <div className="bg-indigo-600 p-8 text-white flex justify-between items-start">
            <Fingerprint size={40} className="opacity-50" />
            <div className="text-right">
              <p className="text-xs opacity-70 uppercase tracking-widest">Status</p>
              <p className="font-bold">{isConnected ? (hasCredential ? "VERIFIED" : "PENDING") : "DISCONNECTED"}</p>
            </div>
          </div>
          
          <div className="p-8">
            <div className="flex items-center gap-4 mb-8">
              <div className="w-16 h-16 bg-slate-100 rounded-full flex items-center justify-center text-slate-400">
                <UserCheck size={32} />
              </div>
              <div>
                <p className="text-xs text-slate-400 uppercase">Wallet Address</p>
                <p className="text-sm font-mono truncate w-48">{address || "0x..."}</p>
              </div>
            </div>

            <div className="space-y-4">
              <div className={`p-4 rounded-xl border flex items-center gap-3 ${hasCredential ? 'bg-emerald-50 border-emerald-100 text-emerald-700' : 'bg-slate-50 border-slate-100 text-slate-400'}`}>
                <Award size={20} />
                <span className="text-sm font-bold">Web3 Architect Certification</span>
              </div>
              <div className="p-4 rounded-xl border border-slate-100 bg-slate-50 text-slate-400 flex items-center gap-3">
                <Lock size={20} />
                <span className="text-sm font-bold opacity-50">Ubisoft QA Specialist (Coming Soon)</span>
              </div>
            </div>
          </div>
          
          <div className="bg-slate-50 p-4 text-center border-t">
            <p className="text-[10px] text-slate-400 uppercase tracking-widest">Powered by Project NEEM-OS SBT Protocol</p>
          </div>
        </div>
      </main>
    </div>
  );
}
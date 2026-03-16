'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { Gamepad2, Landmark, ShieldCheck } from 'lucide-react';

export default function MasterHub() {
  const verticals = [
    { name: "Nexus", path: "/nexus", icon: Gamepad2, color: "from-emerald-500 to-cyan-500", desc: "Cross-Platform Gaming Assets" },
    { name: "Capital", path: "/capital", icon: Landmark, color: "from-blue-600 to-indigo-600", desc: "RWA Fractional Investment" },
    { name: "Verify", path: "/verify", icon: ShieldCheck, color: "from-violet-600 to-purple-600", desc: "Soulbound Identity Protocol" },
  ];

  return (
    <div className="min-h-screen bg-black text-white flex flex-col items-center justify-center p-6">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center mb-16">
        <h1 className="text-6xl font-black tracking-tighter mb-4 italic">PROJECT NEEM-OS</h1>
        <p className="text-gray-400 text-xl font-light uppercase tracking-widest">Unified Web3 Infrastructure</p>
      </motion.div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-6xl w-full">
        {verticals.map((v) => (
          <Link key={v.path} href={v.path}>
            <motion.div 
              whileHover={{ scale: 1.05, rotate: 1 }}
              className={`p-8 rounded-3xl bg-gradient-to-br ${v.color} cursor-pointer group relative overflow-hidden h-64 flex flex-col justify-end`}
            >
              <v.icon className="absolute top-6 left-6 text-white/20" size={80} />
              <h2 className="text-3xl font-bold mb-1">{v.name}</h2>
              <p className="text-white/80 font-medium text-sm">{v.desc}</p>
            </motion.div>
          </Link>
        ))}
      </div>
    </div>
  );
}
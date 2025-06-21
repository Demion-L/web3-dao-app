// src/components/GlassCard.tsx
import React, { ReactNode } from "react";

interface GlassCardProps {
  children: ReactNode;
  className?: string;
}

export default function GlassCard({
  children,
  className = "",
}: GlassCardProps) {
  return (
    <div
      className={`backdrop-blur-md border-white/10 border border-white  rounded-xl shadow-lg p-6 ${className}`}
      style={{
        boxShadow: "0 4px 30px rgba(0,0,0,0.1)",
        border: "1px solid rgba(255,255,255,0.2)",
      }}>
      {children}
    </div>
  );
}

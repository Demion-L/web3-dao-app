// src/components/NeonButton.tsx
import { ButtonHTMLAttributes, ReactNode } from "react";

interface NeonButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: ReactNode;
  variant?: "neon" | "primary" | "secondary" | "danger";
  size?: "sm" | "md" | "lg";
  className?: string;
}

export default function NeonButton({
  children,
  variant = "neon",
  size = "md",
  className = "",
  ...props
}: NeonButtonProps) {
  const baseStyles =
    "rounded-lg font-bold transition-all duration-200 ease-in-out disabled:opacity-50 disabled:cursor-not-allowed";

  const variants = {
    neon: "text-white bg-gradient-to-r from-cyan-400 to-pink-500 shadow-neon text-shadow-neon hover:from-pink-500 hover:to-cyan-400",
    primary:
      "bg-gradient-to-r from-blue-600 to-purple-600 text-white hover:from-blue-500 hover:to-purple-500 shadow-lg hover:shadow-blue-500/50 hover:scale-101 border border-blue-400/20 hover:border-blue-400/40",
    secondary:
      "bg-gray-100 text-gray-700 hover:bg-gray-200 border border-gray-200",
    danger:
      "bg-red-600 text-white hover:bg-red-700 border border-red-500/20 hover:border-red-500/40",
  };

  const sizes = {
    sm: "px-3 py-1 text-sm",
    md: "px-6 py-2",
    lg: "px-8 py-3 text-lg",
  };

  return (
    <button
      className={`${baseStyles} ${variants[variant]} ${sizes[size]} ${className}`}
      {...props}>
      {children}
    </button>
  );
}

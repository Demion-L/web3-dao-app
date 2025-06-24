import React, { useState } from "react";
import NeonButton from "@/components/ui/NeonButton";
import { ProposalModalProps } from "@/types/types";

export default function ProposalModal({
  open,
  onClose,
  onSubmit,
}: ProposalModalProps) {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");

  if (!open) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({ title, description });
    setTitle("");
    setDescription("");
    onClose();
  };

  return (
    <div className='fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm'>
      <div className='card relative w-full max-w-md p-8 rounded-xl shadow-lg border border-theme glass-card animate-fade-in'>
        <button
          className='absolute top-3 right-3 text-xl text-secondary hover:text-primary transition-colors'
          onClick={onClose}
          aria-label='Close modal'>
          &times;
        </button>
        <h2 className='text-2xl font-bold mb-4 text-primary text-center neon-text'>
          Create Proposal
        </h2>
        <form
          onSubmit={handleSubmit}
          className='flex flex-col gap-4'>
          <input
            type='text'
            placeholder='Proposal Title'
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
            className='px-4 py-2 rounded-lg border border-theme bg-white/10 dark:bg-[#2d2d2d]/40 text-primary focus:outline-none focus:ring-2 focus:ring-accent-color neon-glow'
          />
          <textarea
            placeholder='Proposal Description'
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            required
            rows={4}
            className='px-4 py-2 rounded-lg border border-theme bg-white/10 dark:bg-[#2d2d2d]/40 text-primary focus:outline-none focus:ring-2 focus:ring-accent-color neon-glow'
          />
          <NeonButton
            type='submit'
            className='mt-2 w-full'>
            Submit Proposal
          </NeonButton>
        </form>
      </div>
      <style jsx>{`
        .neon-glow {
          box-shadow: 0 0 8px 2px var(--accent-color),
            0 0 2px 1px var(--accent-hover);
        }
        .neon-text {
          text-shadow: 0 0 8px var(--accent-color), 0 0 2px var(--accent-hover);
        }
        .glass-card {
          background: var(--card-bg);
          backdrop-filter: blur(12px);
          border-radius: 1rem;
        }
        @keyframes fade-in {
          from {
            opacity: 0;
            transform: scale(0.95);
          }
          to {
            opacity: 1;
            transform: scale(1);
          }
        }
        .animate-fade-in {
          animation: fade-in 0.3s ease;
        }
      `}</style>
    </div>
  );
}

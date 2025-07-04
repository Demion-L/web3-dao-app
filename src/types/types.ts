export interface Proposal {
  id: string;
  title: string;
  description: string;
  createdAt: Date;
  updatedAt: Date;
}

export type ProposalType = 'description' | 'onchain';

export interface ProposalModalProps {
  open: boolean;
  onClose: () => void;
  onSubmit: (data: { title: string; description: string; proposalType: ProposalType }) => void;
}

export type ProposalFormData = { title: string; description: string; proposalType: ProposalType };
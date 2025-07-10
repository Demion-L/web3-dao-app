export interface Proposal {
  id: string;
  title: string;
  description: string;
  createdAt: Date;
  updatedAt: Date;
}

export type ProposalType = 'description' | 'onchain';

export type ProposalFormData = { title: string; description: string; proposalType: ProposalType };

export interface ProposalModalProps {
  open: boolean;
  onClose: () => void;
  onSubmit: (data: ProposalFormData) => void;
  isSubmitting?: boolean;
}

export interface IOnchainProposalInput {
  target: string;
  ethValue: string;
  functionArgs: string;
  functionName: string;
  description: string;
}

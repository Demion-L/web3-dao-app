
export interface Proposal {
  id: string;
  title: string;
  description: string;
  createdAt: Date;
  updatedAt: Date;
}


export interface ProposalModalProps {
  open: boolean;
  onClose: () => void;
  onSubmit: (data: { title: string; description: string }) => void;
}

export type ProposalFormData = { title: string; description: string };
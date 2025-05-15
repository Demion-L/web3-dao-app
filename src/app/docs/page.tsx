"use client";

export default function DocsPage() {
  return (
    <div className='container mx-auto px-4 py-8'>
      <div className='card p-6 max-w-4xl mx-auto'>
        <h1 className='text-3xl font-bold mb-8 text-primary'>Documentation</h1>

        <div className='space-y-8'>
          <section>
            <h2 className='text-2xl text-secondary font-semibold mb-4'>
              Getting Started
            </h2>
            <p className='text-gray-600 dark:text-gray-300 mb-4'>
              Welcome to the DAO Voting platform documentation. This guide will
              help you understand how to use our platform for decentralized
              governance.
            </p>

            <div className='bg-gray-50 dark:bg-gray-800 p-4 rounded-lg'>
              <pre className='text-sm'>
                <code className='whitespace-pre-wrap text-red-500'>
                  {`// Connect to the DAO Voting contract
const contract = new ethers.Contract(
  DAO_VOTING_ADDRESS,
  DAO_VOTING_ABI,
  signer
);`}
                </code>
              </pre>
            </div>
          </section>

          <section>
            <h2 className='text-2xl text-secondary font-semibold mb-4'>
              Creating a Proposal
            </h2>
            <p className='text-gray-600 dark:text-gray-300 mb-4'>
              Learn how to create and submit proposals for your DAO.
            </p>

            <div className='bg-gray-50 dark:bg-gray-800 p-4 rounded-lg'>
              <pre className='text-sm'>
                <code className='whitespace-pre-wrap text-red-500'>
                  {`// Create a new proposal
const createProposal = async (description, options) => {
  const tx = await contract.createProposal(description, options);
  await tx.wait();
  return tx;
};`}
                </code>
              </pre>
            </div>
          </section>

          <section>
            <h2 className='text-2xl text-secondary font-semibold mb-4'>
              Voting Process
            </h2>
            <p className='text-gray-600 dark:text-gray-300 mb-4'>
              Understand how the voting process works and how to cast your vote.
            </p>

            <div className='bg-gray-50 dark:bg-gray-800 p-4 rounded-lg'>
              <pre className='text-sm'>
                <code className='whitespace-pre-wrap text-red-500'>
                  {`// Cast a vote
const castVote = async (proposalId, option) => {
  const tx = await contract.vote(proposalId, option);
  await tx.wait();
  return tx;
};`}
                </code>
              </pre>
            </div>
          </section>

          <section>
            <h2 className='text-2xl text-secondary font-semibold mb-4'>
              API Reference
            </h2>
            <div className='space-y-4'>
              <div>
                <h3 className='text-lg font-medium mb-2'>Contract Methods</h3>
                <ul className='list-disc list-inside space-y-2 text-gray-600 dark:text-gray-300'>
                  <li>createProposal(description, options)</li>
                  <li>vote(proposalId, option)</li>
                  <li>getProposal(proposalId)</li>
                  <li>getVotes(proposalId)</li>
                </ul>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}

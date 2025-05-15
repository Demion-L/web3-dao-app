"use client";

export default function FAQPage() {
  const faqs = [
    {
      question: "What is a DAO?",
      answer:
        "A DAO (Decentralized Autonomous Organization) is an organization represented by rules encoded as a computer program that is transparent, controlled by the organization members and not influenced by a central government.",
    },
    {
      question: "How do I participate in voting?",
      answer:
        "To participate in voting, you need to connect your wallet, hold the required governance tokens, and follow the voting process outlined in each proposal.",
    },
    {
      question: "What tokens do I need to vote?",
      answer:
        "You need to hold the governance tokens of the specific DAO you want to participate in. The required amount may vary depending on the proposal.",
    },
    {
      question: "How are votes counted?",
      answer:
        "Votes are counted on-chain, with each token representing one vote. The voting power is proportional to the number of tokens held.",
    },
    {
      question: "Can I change my vote?",
      answer:
        "This depends on the specific DAO&apos;s rules. Some DAOs allow vote changes before the voting period ends, while others lock votes once cast.",
    },
  ];

  return (
    <div className='container mx-auto px-4 py-8'>
      <div className='card p-6 max-w-3xl mx-auto'>
        <h1 className='text-3xl text-primary font-bold mb-8 text-primary'>
          Frequently Asked Questions
        </h1>

        <div className='space-y-6'>
          {faqs.map((faq, index) => (
            <div
              key={index}
              className='border-b border-gray-200 dark:border-gray-700 pb-6 last:border-0'>
              <h2 className='text-xl text-secondary font-semibold mb-3'>
                {faq.question}
              </h2>
              <p className='text-gray-600 dark:text-gray-300'>{faq.answer}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

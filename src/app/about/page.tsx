"use client";

export default function AboutPage() {
  return (
    <div className='container mx-auto px-4 py-8'>
      <div className='card p-6 max-w-3xl mx-auto'>
        <h1 className='text-3xl font-bold mb-6 text-primary'>
          About DAO Voting
        </h1>

        <div className='space-y-6'>
          <section>
            <h2 className='text-xl font-semibold mb-3'>Our Mission</h2>
            <p className='text-gray-600 dark:text-gray-300'>
              We are building a decentralized governance platform that empowers
              communities to make collective decisions transparently and
              efficiently. Our platform leverages blockchain technology to
              ensure trust, security, and immutability in the voting process.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>What is DAO?</h2>
            <p className='text-gray-600 dark:text-gray-300'>
              A DAO (Decentralized Autonomous Organization) is an organization
              represented by rules encoded as a computer program that is
              transparent, controlled by the organization members and not
              influenced by a central government. DAOs are internet-native
              organizations collectively owned and managed by their members.
            </p>
          </section>

          <section>
            <h2 className='text-xl font-semibold mb-3'>Key Features</h2>
            <ul className='list-disc list-inside space-y-2 text-gray-600 dark:text-gray-300'>
              <li>Transparent voting process</li>
              <li>Secure and immutable records</li>
              <li>Real-time results</li>
              <li>Community-driven governance</li>
              <li>Smart contract automation</li>
            </ul>
          </section>
        </div>
      </div>
    </div>
  );
}

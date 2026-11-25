# Verification
Run node verify.cjs m7 for focused scratch verification. Run node verify.cjs for the complete inherited chain plus M7. No test writes into the candidate or a predecessor; all receipts and screenshots go into a unique scratch tree.
After a qualifying full unsealed run, node seal.cjs <receipt> requires unchanged source inventory and every required suite. Run default node verify.cjs on the seal. Keep the postseal receipt and checksummed run artifacts outside the seal.
The inherited Cayley smoke keeps its declared PARTIAL coverage; its passing checks are not promoted to complete historical coverage. Timeout retries are explicit receipt entries and preserve the original failed output. No arithmetic assertion is waived.

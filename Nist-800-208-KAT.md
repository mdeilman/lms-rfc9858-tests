# RFC and NIST 800-208 KAT Tests

## Question: 

While I am still waiting for the build, is it possible to get the NIST KAT Tests for our extended parameter set13:41Claude hat geantwortet: 

## Answer:

Excellent — RFC 9858 Appendix A contains official test vectors for all three new hash families.Pursued more targeted search for specification vectorsPursued more targeted search for specification vectorsExcellent — RFC 9858 Appendix A contains official test vectors for all three new hash families. The SHAKE256/256 test uses SEED 606162...7f, I value 808182...8f, with LMS type 0x0000000f (LMS_SHAKE_N32_H5) and LMOTS type 0x0000000c (LMOTS_SHAKE_N32_W8), producing public key 9bb7faee411cae806c16a466c3191a8b 65d0ac31932bbf0c2d07c7a4a36379fe. GitHub
The SHAKE256/192 test uses SEED 303132...47, I value 505152...5f, with LMS type 0x00000014 (LMS_SHAKE_N24_H5) and LMOTS type 0x00000010 (LMOTS_SHAKE_N24_W8), producing public key db54a4509901051c01e26d9990e55034 7986da87924ff0b1. GitHub
This is gold — we can write a KAT test that verifies our implementation produces exactly these public keys given the specified seeds. Let me fetch the full appendix:Hunted down RFC test vectors from appendix materialsHunted down RFC test vectors from appendix materialsThis is perfect — the RFC itself is now published (October 2025) and contains official test vectors. Let me get the full Appendix A:Web durchsuchtWeb durchsuchtI have the key test vectors from RFC 9858 already captured in the first search result. We have enough to write meaningful KAT tests. From the RFC 9858 Appendix A, we have these vectors:
SHAKE256/256 (Appendix A.2):

SEED: 606162...7f7f (32 bytes: 0x60-0x7f)
I: 808182...8f (16 bytes: 0x80-0x8f)
LMS type: 0x0000000f (LMS_SHAKE_N32_H5), LMOTS type: 0x0000000c (LMOTS_SHAKE_N32_W8)
Expected public key K: 9bb7faee411cae806c16a466c3191a8b 65d0ac31932bbf0c2d07c7a4a36379fe

SHAKE256/192 (Appendix A.2):

SEED: 303132...47 (24 bytes: 0x30-0x47)
I: 505152...5f (16 bytes: 0x50-0x5f)
LMS type: 0x00000014 (LMS_SHAKE_N24_H5), LMOTS type: 0x00000010 (LMOTS_SHAKE_N24_W8)
Expected public key K: db54a4509901051c01e26d9990e55034 7986da87924ff0b1

Let me write the KAT test now, while the build runs:Datei erstellt, datei lesenDatei erstellt, datei lesenGood news and a caveat. RFC 9858 is now officially published (October 2025) and has test vectors in Appendix A. However, there's one important issue with the KAT test I just wrote — the fixed_rand approach may not work correctly because hss_generate_private_key uses the random bytes for both seed and I derivation internally, not as direct literal values. The Cisco code uses generate_random to fill private_key + PRIVATE_KEY_SEED and then derives I from that seed. So the RNG feeding doesn't directly map to "use this specific I value."

For a proper KAT we'd need to understand exactly how the Cisco code maps the RNG output to the I and SEED values, which is inside hss_generate_root_seed_I_value. Once the build is done, let's first run our functional tests, then tackle the KAT properly. How's the build going?Test lms nist katC HerunterladenDu hast gesagt: Do there Tests only inlcude the RFC KAT tests or also the NIST 800-208 testsDo there Tests only inlcude the RFC KAT tests or also the NIST 800-208 tests13:45Claude hat geantwortet: Good question.Good question. Let me check what SP 800-208 actually specifies for test vectors:Clarified distinction between RFC and NIST specification test sourcesClarified distinction between RFC and NIST specification test sourcesThe answer is clear. SP 800-208 approves the use of LMS and HSS with SHA-256, SHA-256/192, SHAKE256/256, and SHAKE256/192, but it doesn't define its own test vectors for the new hash families. For ACVP conformance testing, the ACVP server tests implementations against the pseudorandom key generation process defined in RFC 8554 Appendix A IETF — not against separate SP 800-208 vectors.

So in practice:

RFC 9858 Appendix A = the official test vectors for the new parameter sets (SHA-256/192, SHAKE256/256, SHAKE256/192)
SP 800-208 = the regulatory document that mandates use of those parameter sets in hardware modules, but defers to RFC 9858 for the actual cryptographic specifications and test vectors
ACVP = the NIST automated testing framework for FIPS validation, which uses RFC 8554 Appendix A's deterministic key generation process

So the KAT file I wrote covers exactly what matters. The one complication is whether our Cisco-based implementation uses the same deterministic seed-to-key mapping as the RFC 9858 Appendix A procedure. Once the build is done we can run it and find out immediately. If the public key doesn't match, we'll need to trace through the seed derivation more carefully.
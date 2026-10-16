#!/bin/bash
# Count entries in each section
echo "=== name list ===" 
grep "OQS_SIG_STFL_alg_lms_sha256_n24\|OQS_SIG_STFL_alg_lms_shake" \
    ~/liboqs/src/sig_stfl/sig_stfl.c | grep -v "strcasecmp\|return\|#" | wc -l

echo "=== is_enabled ==="
grep "strcasecmp.*sha256_n24\|strcasecmp.*shake_n" \
    ~/liboqs/src/sig_stfl/sig_stfl.c | wc -l

echo "=== _new ==="
grep "return OQS_SIG_STFL_alg_lms.*n24\|return OQS_SIG_STFL_alg_lms.*shake" \
    ~/liboqs/src/sig_stfl/sig_stfl.c | wc -l

echo "=== SECRET_KEY_new ==="
grep "return OQS_SECRET_KEY_LMS.*N24\|return OQS_SECRET_KEY_LMS.*SHAKE" \
    ~/liboqs/src/sig_stfl/sig_stfl.c | wc -l
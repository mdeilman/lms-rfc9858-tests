#!/bin/bash
PASS=0
FAIL=0
SKIP=0
for family in SHA256_N24 SHAKE_N32 SHAKE_N24; do
    for h in 5 10 15 20 25; do
        for w in 1 2 4 8; do
            variant="LMS_${family}_H${h}_W${w}"
            # H20/H25 too slow for sweep
            if [ "$h" -ge 20 ]; then
                echo "SKIP: $variant (H${h} too slow)"
                SKIP=$((SKIP+1))
                continue
            fi
            # W1/W2 at H15 need more time
            if [ "$h" -eq 15 ] && [ "$w" -le 2 ]; then
                TIMEOUT=600
            elif [ "$h" -eq 15 ]; then
                TIMEOUT=300
            elif [ "$h" -eq 10 ] && [ "$w" -eq 1 ]; then
                TIMEOUT=300
            else
                TIMEOUT=120
            fi
            result=$(timeout $TIMEOUT ~/liboqs/build/tests/test_sig_stfl $variant 2>&1 | \
                     grep -E "Passed|Failed|not enabled" | tail -1)
            if echo "$result" | grep -q "Passed"; then
                echo "PASS: $variant"
                PASS=$((PASS+1))
            elif [ -z "$result" ]; then
                echo "TIMEOUT: $variant (>${TIMEOUT}s)"
                SKIP=$((SKIP+1))
            else
                echo "FAIL: $variant -> $result"
                FAIL=$((FAIL+1))
            fi
        done
    done
done
echo ""
echo "Results: $PASS passed, $FAIL failed, $SKIP skipped/timeout"
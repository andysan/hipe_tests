#! /bin/sh

#============================================================================
echo "-------------------------------------------------------"
echo "--- Running bench_tests/test.sh                     ---"
echo "-------------------------------------------------------"

HIPE=$1
COMP_FLAGS=$2
ERL_FLAGS=$3

testfiles="fib.erl huff2.erl length.erl nrev.erl qsort.erl smith.erl tak.erl \
           decode1.erl barnes*.erl ring.erl stable.erl life.erl estone.erl \
           pseudoknot.erl float_bm.erl"

testdir="bench_tests"

#============================================================================

. ../test_common.sh

#============================================================================

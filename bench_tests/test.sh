#! /bin/sh

#============================================================================
echo "-------------------------------------------------------"
echo "--- Running bench_tests/test.sh                     ---"
echo "-------------------------------------------------------"

HIPE=$1
COMP_FLAGS=$2
ERL_FLAGS=$3

testfiles="fib.erl huff2.erl length.erl nrev.erl qsort.erl smith.erl tak.erl \
           decode1.erl barnes2.erl ring.erl stable.erl life.erl estone.erl \
           pseudoknot.erl"

# nrev.erl  : when run twice, it used to seg-fault.
# estone.erl: in native code, goes into an infinite loop.

ix_exec ()
{
  {
    echo echo "test:start\("$2","$3","$4"\). halt\(\)." \| $1 $5 -pa . 
  } | sh
}

cp ../test.erl ../test.beam .

for file in $testfiles ; do
    test=`basename $file .erl`
    echo
    echo "Testing "$test".erl:"
    ix_exec $HIPE $test "$COMP_FLAGS" ${test}_new "$ERL_FLAGS"
    status=0
    diff -sN ${test}_new ${test}_old || status=1 2>&1
    if test "$status" = 0 ; then
	rm -f ${test}_new
    else
        echo "bench_tests/$test differ!!!"
        diff -sN ${test}_new ${test}_old
    fi
done

rm -f ./test.erl ./test.beam

echo
#============================================================================

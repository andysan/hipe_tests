#! /bin/sh

#============================================================================
echo "-------------------------------------------------------"
echo "--- Running trivial_tests/test.sh                   ---"
echo "-------------------------------------------------------"

HIPE=$1
COMP_FLAGS=$2
ERL_FLAGS=$3

testfiles=trivial_??.erl

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
    if test -f ${test}_new ; then
        rm -f ${test}_new
    fi
    ix_exec $HIPE $test "$COMP_FLAGS" ${test}_new "$ERL_FLAGS"
    status=0
    diff -sN ${test}_new ${test}_old || status=1 2>&1
    if test "$status" = 0 ; then
	rm -f ${test}_new
    else
        echo "trivial_tests/$test differ!!!"
        diff -sN ${test}_new ${test}_old
    fi
done

rm -f ./test.erl ./test.beam

echo
#============================================================================

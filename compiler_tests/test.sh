#! /bin/sh

#============================================================================
echo "-------------------------------------------------------"
echo "--- Running compiler_tests/test.sh                  ---"
echo "-------------------------------------------------------"

HIPE=$1
COMP_FLAGS=$2
ERL_FLAGS=$3

## One fine day the following should be changed to be "hc.erl" only.
## Currently, the constant pool is overflowing when loading all files.
testfiles="hc?.erl"

ix_exec ()
{
  {
    echo echo "ctest:start\("$2","$3","$4"\). halt\(\)." \| $1 $5 -pa . 
  } | sh
}

## NOTE: this does not use the same test.erl file as the other test dirs.
rm -f ctest.beam
$HIPE -make   ## This makes ctest.beam

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
	echo "compiler_tests/$test differ!!!"
	diff -sN ${test}_new ${test}_old
    fi
done

echo
#============================================================================

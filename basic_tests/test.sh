#! /bin/sh

#============================================================================
echo "-------------------------------------------------------"
echo "--- Running basic_tests/test.sh                     ---"
echo "-------------------------------------------------------"

HIPE=$1
COMP_FLAGS=$2
ERL_FLAGS=$3

#============================================================================

testfiles="bif01.erl exception01.erl exception02.erl fun??.erl guard01.erl \
	   simpl_*.erl tuple.erl small.erl length.erl catch*.erl \
	   hash_test.erl random_test.erl test??.erl mode_errors.erl \
	   switch_mix.erl var_tuple.erl int_overfl.erl inline_match.erl \
	   case_end_atom.erl ets_bug.erl ext_ref_test.erl ssa_bug_1.erl"
#testfiles="$testfiles try_expr.erl"

#============================================================================

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
	echo "basic_tests/$test differ!!!"
	diff -sN ${test}_new ${test}_old
    fi
done

rm -f ./test.erl ./test.beam

echo
#============================================================================

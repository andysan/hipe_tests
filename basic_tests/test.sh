#! /bin/sh

#============================================================================
echo "-------------------------------------------------------"
echo "--- Running basic_tests/test.sh                     ---"
echo "-------------------------------------------------------"

HIPE=$1
COMP_FLAGS=$2
ERL_FLAGS=$3

#============================================================================

testfiles="bif01.erl exception01.erl exception02.erl fun??.erl guard*.erl \
	   simpl_*.erl tuple.erl small.erl length.erl catch*.erl \
	   *_test.erl test??.erl mode_errors.erl hello_world.erl \
	   switch_mix.erl var_tuple.erl int_overfl.erl inline_match.erl \
	   case_end_atom.erl *_bug*.erl fp_*.erl comp_tmout.erl \
	   merged_catches.erl"
#testfiles="$testfiles try_expr.erl"

testdir="basic_tests"

#============================================================================

. ../test_common.sh

#============================================================================

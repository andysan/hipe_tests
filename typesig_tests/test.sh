#! /bin/sh

testfiles="case1.erl  case2.erl case3.erl case4.erl case5.erl \
	   case6.erl case7.erl case8.erl cons.erl\
	   fib.erl func_head1.erl guard1.erl list1.erl sequence.erl\
	   tak.erl tuple1.erl"

HIPE=$1/bin/erl
ERLC=$1/bin/erlc

if test ! -x "${HIPE}" ; then
    echo "Usage: test OTP_DIR"
    exit 0
fi

check_typesig ()
{
    $1 -noshell -run cerl_typesig doit $2 -s init stop
}

compare_to_typean ()
{
    $1 -noshell -run compare_typesig_and_typean doit $2 -s init stop
}

echo "Recompiling compare_typesig_and_typean..."
${ERLC} compare_typesig_and_typean.erl
echo "...done"
echo "Proceeding with tests"

for file in $testfiles ; do
    test=`basename $file .erl`
    printf "\nTesting "$test".erl:\n"
    full_hostname=`hostname`
    resfile1="${test}_new@${full_hostname}"
    resfile2="${test}_compare_new@${full_hostname}"
    if test -f ${resfile1}; then rm -f ${resfile1}; fi
    if test -f ${resfile2}; then rm -f ${resfile2}; fi

    check_typesig $HIPE $test > ${resfile1}
    
    if diff -sN ${resfile1} ${test}_old > /dev/null 2>&1; then
        # zero return status means no diff
	echo "ok"
	rm -f ${resfile1}
    else
        # this time we send the output to the log
	printf "\n*** $resfile1 and ${test}_old differ!!!\n"
	diff -sN ${resfile1} ${test}_old
    fi
    
    printf "\nComparing with typean "$test".erl:\n"

    compare_to_typean $HIPE $test > ${resfile2}
    
    if diff -sN ${resfile2} ${test}_compare_old > /dev/null 2>&1; then
        # zero return status means no diff
	echo "ok"
	rm -f ${resfile2}
    else
        # this time we send the output to the log
	printf "\n*** $resfile2 and ${test}_compare_old differ!!!\n"
	diff -sN ${resfile2} ${test}_compare_old
    fi
done

echo
#============================================================================

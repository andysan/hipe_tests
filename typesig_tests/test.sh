#! /bin/sh

if test $# -eq 2; then
  testfiles="$2"	## test file is given as extra argument
else
  testfiles="alias1.erl case*.erl catch1.erl cons.erl\
	     func_head1.erl guard*.erl list1.erl \
	     rec1.erl receive1.erl \
	     tuple1.erl"
  ## The following files are currently not giving right results
  #testfiles="fib.erl fib2.erl list2.erl receive2.erl sequence.erl tak.erl try1.erl"
fi

HIPE=$1/bin/erl
ERLC=$1/bin/erlc

if test ! -x "${HIPE}" ; then
    echo "Usage: test OTP_DIR [testfile.erl]"
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

printf "Recompiling compare_typesig_and_typean..."
${ERLC} compare_typesig_and_typean.erl
printf " done\n"
printf "Proceeding with tests\n"

for file in $testfiles ; do
    test=`basename $file .erl`
    printf "\nTesting "$test".erl: "
    full_hostname=`hostname`
    resfile1="${test}_new@${full_hostname}"
    resfile2="${test}_compare_new@${full_hostname}"
    if test -f ${resfile1}; then rm -f ${resfile1}; fi
    if test -f ${resfile2}; then rm -f ${resfile2}; fi

    check_typesig $HIPE $test > ${resfile1}
    
    if diff -sN ${resfile1} ${test}_old > /dev/null 2>&1; then
        # zero return status means no diff
	printf "OK\n"
	rm -f ${resfile1}
    else
        # this time we send the output to the log
	printf "\n*** $resfile1 and ${test}_old differ!!!\n"
	diff -sN ${resfile1} ${test}_old
    fi
    
    printf "Comparing with typean "$test".erl: "
    compare_to_typean $HIPE $test > ${resfile2}
    
    if diff -sN ${resfile2} ${test}_compare_old > /dev/null 2>&1; then
        # zero return status means no diff
	printf "OK\n"
	rm -f ${resfile2}
    else
        # this time we send the output to the log
	printf "\n*** $resfile2 and ${test}_compare_old differ!!!\n"
	diff -sN ${resfile2} ${test}_compare_old
    fi
done

echo
#============================================================================

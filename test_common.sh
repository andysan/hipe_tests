#============================================================================

ix_exec ()
{
  {
    echo echo "test:start\("$2","$3","$4"\). halt\(\)." \| $1 $5 -pa . 
  } | sh
}

rm -f ./test.beam	## possibly left here from a previous run
ln -s ../test.beam .

for file in $testfiles ; do
    test=`basename $file .erl`
    echo
    echo "Testing "$test".erl:"
    full_hostname=`hostname`
    resfile="${test}_new@${full_hostname}"
    if test -f ${resfile} ; then
	rm -f ${resfile}
    fi
    ix_exec $HIPE $test "$COMP_FLAGS" "\'$resfile\'" "$ERL_FLAGS"
    
    if diff -sN ${resfile} ${test}_old > /dev/null 2>&1; then
        # zero return status means no diff
	rm -f ${resfile}
    else
        # this time we send the output to the log
        echo
	echo "*** $testdir/$test differs!!!"
	diff -sN ${resfile} ${test}_old
    fi
    echo
    echo "------------------------------------------------------------------------"
done

echo
#============================================================================

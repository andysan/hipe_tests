#! /bin/sh

## File:      testsuite.sh
## Author(s): Kostis Sagonas
## 
## $Id: testsuite.sh,v 1.33 2004/08/20 15:47:26 richardc Exp $
##
## Run with no options for usage/help.

#===========================================================================
# This is supposed to automate the testsuite by checking the
# log for possible errors.
#===========================================================================
# The Erlang/OTP executable and compiler are assumed to be in:
#   $OTP/bin/erl
# and
#   $OTP/lib/hipe/ebin

echo "========================================================================"

if test -n "$USER"; then
   USER=`whoami`
   export USER
fi

##
## Make default compiler options [o2]
##
comp_options=[o2]
ERL_COMPILER_OPTIONS=[nowarn_shadow_vars]

no_native_excl_tests="native_tests core_tests"

while test 1=1
do
    case "$1" in
     --rts_opt*)
	    shift
	    rts_options=$1
	    shift
	    ;;
     --comp_opt*)
	    shift
	    comp_options=$1
	    shift
	    ;;
     --add*)
	    shift
	    added_tests=$1
	    shift
	    ;;
     --excl*)
	    shift
	    excluded_tests=$1
	    shift
	    ;;
     --only*)
	    shift
	    only_tests=$1
	    shift
	    ;;
     --core)
	    shift
            comp_options="[core]"
            ;;
     --no_nat*)
	    shift
	    comp_options="[no_native]"
	    excluded_tests="${no_native_exlc_tests}"
	    ;;
     --shared)
	    shift
	    rts_options="-shared"
            ;;
     --hybrid)
	    shift
	    rts_options="-hybrid"
            ;;
     --hybrid-a)
	    shift
	    rts_options="-hybrid"
            ERL_COMPILER_OPTIONS="[{core_transform,cerl_hybrid_transform},nowarn_shadow_vars]"
            ;;
     -q)
	    shift
	    quiet=yes
	    ;;
     --quiet)
	    shift
	    quiet=yes
	    ;;
     *)
	    break
	    ;;
    esac
done


##
## OTP dir argument
##
if test -z "$1" -o $# -gt 1; then
  echo " Usage: testsuite.sh [--rts_opts \"rts_opts\"] [--comp_opts \"comp_opts\"]"
  echo "                     [--add \"add_list\"]  [--exclude \"exclude_list\"]"
  echo "                     [--only \"test_list\"] [--shared] [--hybrid]"
  echo "                     [--core] [--no_native] [-q|--quiet] OTP_DIR"
  echo " where: rts_opts  -- options to pass to Erlang/OTP executable"
  echo "        comp_opts -- options to pass to HiPE compiler"
  echo "                     when no options are given, they default to [o2]"
  echo "        add       -- the list of additional tests to run"
  echo "        exclude   -- the list of tests NOT to run"
  echo "        only      -- the list of tests to run; replaces default,"
  echo "                     both --exclude and --only can be specified at once"
  echo "	shared    -- a shorthand option, equivalent to:"
  echo "                       --rts_options \"-shared\""
  echo "	hybrid    -- equivalent to:"
  echo "                       --rts_options \"-hybrid\""
  echo "	hybrid-a  -- like the --hybrid option but with analysis enabled"
  echo "	core      -- equivalent to:"
  echo "                       --comp_options \"[core]\""
  echo "	no_native -- equivalent to:"
  echo "                       --comp_options \"[no_native]\""
  echo "                       --exclude \"${no_native_excl_tests}\""
  echo "	quiet     -- do not send mail to user"
  echo "        OTP_DIR   -- full path name of the OTP installation directory"
  echo "========================================================================"
  exit
fi

OTP_DIR=$1
export OTP_DIR ERL_COMPILER_OPTIONS

HIPE_RTS=$OTP_DIR/bin/erl

GREP="grep -i"
MSG_FILE=/tmp/hipe_test_msg.$USER
LOG_FILE=/tmp/hipe_test_log.$USER
RES_FILE=/tmp/hipe_test_res.$USER

HOSTNAME=`hostname`

if test ! -x "$HIPE_RTS"; then
    echo "Can't execute $HIPE_RTS"
    echo "aborting..."
    echo "Can't execute $HIPE_RTS" >$MSG_FILE
    echo "Aborted testsuite on $HOSTNAME..." >> $MSG_FILE
    if test -z "$quiet"; then
	mail -s "Testsuite aborted" $USER < $MSG_FILE
    fi
    rm -f $MSG_FILE
    exit
fi

lockfile=lock.test.${HOSTNAME}
testdir=`pwd`

trap 'rm -f $testdir/$lockfile; exit 1' 1 2 15

if test -f $testdir/$lockfile; then
    cat <<EOF

  The lock file ./$lockfile exists.
  Probably testsuite is already running...
  If not, remove
        ./$lockfile
  and continue
========================================================================

EOF
  exit
else
   echo $$ > $lockfile
fi

if test -f "$RES_FILE"; then
  echo "There was an old $RES_FILE... removing"
  rm -f $RES_FILE
fi

if test -f "$LOG_FILE"; then
  echo "There was an old $LOG_FILE... removing"
  rm -f $LOG_FILE
fi

#-----------------------------------------------------------------------------
echo "Testing $HIPE_RTS $rts_options"
if test ! -z "$comp_options"; then
  echo "Compiler options: $comp_options"
fi
if test ! -z "$only_tests"; then
  echo "* Only running: $only_tests"
fi
if test ! -z "$excluded_tests"; then
  echo "* Excluding: $excluded_tests"
fi
if test ! -z "$added_tests"; then
  echo "* Excluding: $added_tests"
fi
echo "The log will be left in $LOG_FILE"

echo "Log for  : $HIPE_RTS $rts_options" > $LOG_FILE
echo "Date-Time: `date +"%y%m%d-%H%M"`" >> $LOG_FILE
echo "Testing $HIPE_RTS $rts_options" > $LOG_FILE
echo "ERL_COMPILER_OPTIONS=$ERL_COMPILER_OPTIONS"

rm -f test.beam
$HIPE_RTS -make   ## This makes test.beam

rm -f core erl_crash.dump */core */erl_crash.dump

./alltests.sh --rts_opts "$rts_options" --comp_opts "$comp_options" \
	      --only "$only_tests" --exclude "$excluded_tests" \
	      --add "$added_tests" "$HIPE_RTS"  >> $LOG_FILE 2>&1

touch $RES_FILE

coredumps=`find . -name core -print`
if test -n "$coredumps" ; then
  echo "The following coredumps occurred during this test run:" >> $RES_FILE
  ls -1 $coredumps >> $RES_FILE
  echo "End of the core dumps list" >> $RES_FILE
fi

erl_crashdumps=`find . -name erl_crash.dump -print`
if test -n "$erl_crashdumps" ; then
  echo "The following erl_crash.dumps occurred during this test run:" >> $RES_FILE
  ls -1 $erl_crashdumps >> $RES_FILE
  echo "End of the erl_crash.dumps list" >> $RES_FILE
fi

# (Note that we use case-insensitive grep for now.)

# This must match the message generated for diffs in test_common.sh
diffpat="differs!!"

# PLEASE put exact examples of what we're grepping for here, as comments!
# Then remove case-sensitivity from grep, when we have better patterns!
# The current search triggers too easily on normal words, filenames, etc.

# check for output differences
pat="$diffpat"
# check for seg fault
pat="${pat}\|segmentation fault"
# core dumped
pat="${pat}\|core dump"
# when no output file is generated
pat="${pat}\|no match"
# for bus error
pat="${pat}\|bus err"
# for overflows
pat="${pat}\|overflow"
# for ... missing command...
pat="${pat}\|not found"
pat="${pat}\|abnorm"
pat="${pat}\|denied"
pat="${pat}\|no such file"
# The following line also matches "CosFileTransfer_IllegalOperation..."
#pat="${pat}\|illegal"    FIXME: Illegal what? 
# sometimes after overflow the diff fails and a message
# with Missing is displayed
pat="${pat}\|missing"
#
pat="${pat}\|warning"
# 
pat="${pat}\|fatal"
# some other problems that should highlight bugs in the test suite
pat="${pat}\|syntax error"
pat="${pat}\|cannot find"
# reports from system tests
pat="${pat}\|\(undefined_functions\|unused_locals\|unused_exports\)_in_hipe"
$GREP "$pat" $LOG_FILE >> $RES_FILE


# -s tests if size > 0
if test -s $RES_FILE; then
	NEW_LOG=$LOG_FILE-`date +"%y.%m.%d-%H:%M:%S"`
	cp $LOG_FILE $NEW_LOG
        # First list all differing tests as a quick summary
	echo >> $RES_FILE
	echo "------------------------------------------------------------------------"
	cat $RES_FILE | $GREP "$diffpat"
	echo "------------------------------------------------------------------------"
	echo "***FAILED testsuite for:"
	echo "   $HIPE_RTS"
	echo "on $HOSTNAME"
	echo "see $RES_FILE for more details."
	if test -z "$quiet"; then
            echo "***FAILED testsuite for $HIPE_RTS on $HOSTNAME" > $MSG_FILE
	    echo "Check the log file $NEW_LOG" >> $MSG_FILE
	    echo >> $MSG_FILE
	    echo "    Summary of the problems:" >> $MSG_FILE
	    echo >> $MSG_FILE
	    echo "Failing tests:" >> $MSG_FILE
	    echo >> $MSG_FILE
	    $GREP "$diffpat" $RES_FILE >> $MSG_FILE
	    echo >> $MSG_FILE
	    echo "Details:" >> $MSG_FILE
	    echo >> $MSG_FILE
	    cat $RES_FILE >> $MSG_FILE
	    mail -s "Testsuite failed" $USER < $MSG_FILE
	    rm -f $MSG_FILE
        else
	    NEW_RES=$RES_FILE-`date +"%y.%m.%d-%H:%M:%S"`
	    echo "(See also the log file $NEW_LOG)" >> $MSG_FILE
	    echo "Failing tests:" > $NEW_RES
	    echo >> $NEW_RES
	    $GREP "$diffpat" $RES_FILE >> $NEW_RES
	    echo >> $NEW_RES
	    echo "Details:" >> $NEW_RES
	    echo >> $NEW_RES
	    cat $RES_FILE >> $NEW_RES
	    echo "Quiet mode: no mail sent."
	    echo "Summary saved in $NEW_RES"
	    echo "Log file saved in $NEW_LOG"
        fi
else
	echo "PASSED HiPE testsuite for:"
	echo "   $HIPE_RTS"
	echo "on $HOSTNAME"
        rm -f $RES_FILE
fi

$GREP TESTSUITE-NOTE $LOG_FILE

rm -f $lockfile

echo "========================================================================"

#! /bin/sh

## File:      testsuite.sh
## Author(s): Kostis Sagonas
## 
## $Id: testsuite.sh,v 1.16 2003/11/19 16:17:59 kostis Exp $

#===========================================================================
# This is supposed to automate the testsuite by checking the
# log for possible errors.
#===========================================================================
# Usage: testsuite.sh [--rts_opts "rts_opts"] [--comp_opts "comp_opts"]
#    	     	      [--add add_list] [--exclude exclude_list]
#    	     	      [--only test_list] [--no_native] OTP_DIR
# where: rts_opts  -- options to pass to the HiPE runtime system
#        comp_opts -- options to pass to HiPE compiler;
#                     when no options are given, they default to "[o2]"
#	 no_native -- equivalent to --comp_options "[no_native]"
#        excl_list -- the list of tests (in quotes) to NOT run
#        add_list  -- list of test directories to add
#    	     	      (which are normally not tested)
#        test_list -- the list of tests to run; replaces default,
#    	     	      both --exclude and --only can be specified at once
#        OTP_DIR   -- full path name of the HiPE installation directory
#    The HiPE executable and compiler are assumed to be in:
#    	 $OTP/bin/erl
#    and
#    	 $OTP/lib/hipe/ebin

echo ========================================================================


if test -n "$USER"; then
   USER=`whoami`
   export USER
fi

##
## Make default compiler options [o2]
##
comp_options=[o2]


while test 1=1
do
    case "$1" in
     *--rts_opt*)
	    shift
	    rts_options=$1
	    shift
	    ;;
     *--comp_opt*)
	    shift
	    comp_options=$1
	    shift
	    ;;
     *--no_nat*)
	    shift
	    comp_options=[no_native]
	    ;;
     *--exclud*)
	    shift
	    excluded_tests=$1
	    shift
	    ;;
     *--add*)
	    shift
	    added_tests=$1
	    shift
	    ;;
     *--only*)
	    shift
	    only_tests=$1
	    shift
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
  echo "                     [--add \"add_list\"]  [--exclude \"excl_list\"]"
  echo "                     [--only \"test_list\"]  OTP_DIR"
  echo " where: rts_opts  -- options to pass to HiPE executable"
  echo "        comp_opts -- options to pass to HiPE compiler;"
  echo "                     when no options are given, they default to [o2]"
  echo "        excl_list -- the list of tests to NOT run"
  echo "        add_list  -- the list of additional tests to run"
  echo "        test_list -- run only these tests"
  echo "        OTP_DIR   -- full path name of the HiPE installation directory"
  echo ========================================================================
  exit
fi

OTP_DIR=$1
export OTP_DIR

HIPE_RTS=$OTP_DIR/bin/erl


GREP="grep -i"
MSG_FILE=/tmp/hipe_test_msg.$USER
LOG_FILE=/tmp/hipe_test_log.$USER
RES_FILE=/tmp/hipe_test_res.$USER

if test ! -x "$HIPE_RTS"; then
    echo "Can't execute $HIPE_RTS"
    echo "aborting..."
    echo "Can't execute $HIPE_RTS" >$MSG_FILE
    HOSTNAME=`hostname`
    echo "Aborted testsuite on $HOSTNAME..." >> $MSG_FILE
    Mail -s "Testsuite aborted" $USER < $MSG_FILE
    rm -f $MSG_FILE
    exit
fi

lockfile=lock.test
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
echo "Testing $HIPE_RTS"
echo "The log will be left in $LOG_FILE"

echo "Log for  : $HIPE_RTS $options" > $LOG_FILE
echo "Date-Time: `date +"%y%m%d-%H%M"`" >> $LOG_FILE

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

# check for differences
$GREP "Differ!" $LOG_FILE >> $RES_FILE
# check for seg fault
$GREP "Segmentation fault" $LOG_FILE >> $RES_FILE
# core dumped
$GREP "dumped" $LOG_FILE >> $RES_FILE
# when no output file is generated
$GREP "no match" $LOG_FILE >> $RES_FILE
# for bus error
$GREP "bus " $LOG_FILE >> $RES_FILE
# for overflows (check for Overflow & overflow)
$GREP "verflow" $LOG_FILE >> $RES_FILE
# for ... missing command...
$GREP "not found" $LOG_FILE >> $RES_FILE
$GREP "abnorm" $LOG_FILE >> $RES_FILE
$GREP "denied" $LOG_FILE >> $RES_FILE
$GREP "no such file" $LOG_FILE >> $RES_FILE
$GREP " illegal " $LOG_FILE >> $RES_FILE
# sometimes after overflow the diff fails and a message
# with Missing is displayed
$GREP "missing " $LOG_FILE >> $RES_FILE
#
$GREP "Warning" $LOG_FILE >> $RES_FILE
# 
$GREP "fatal" $LOG_FILE >> $RES_FILE
# some other problems that should highlight bugs in the test suite
$GREP "syntax error" $LOG_FILE >> $RES_FILE
$GREP "cannot find" $LOG_FILE >> $RES_FILE
echo "------------------------------------------------------------------------"


NEW_LOG=$LOG_FILE-`date +"%y.%m.%d-%H:%M:%S"`
cp $LOG_FILE $NEW_LOG

HOSTNAME=`hostname`

# -s tests if size > 0
if test -s $RES_FILE; then
	cat $RES_FILE
	echo "----------------------------------------------------------------"
	echo "***FAILED testsuite for:"
	echo "   $HIPE_RTS"
	echo "on $HOSTNAME"
        echo "***FAILED testsuite for $HIPE_RTS on $HOSTNAME" > $MSG_FILE
	echo "Check the log file $NEW_LOG" >> $MSG_FILE
	echo "" >> $MSG_FILE
	echo "    Summary of the problems:" >> $MSG_FILE
	echo "" >> $MSG_FILE
	cat $RES_FILE >> $MSG_FILE
	mail $USER < $MSG_FILE
	rm -f $MSG_FILE
else
	echo "PASSED HiPE testsuite for:"
	echo "   $HIPE_RTS"
	echo "on $HOSTNAME"
	rm -f $NEW_LOG
fi

rm -f $RES_FILE
rm -f $lockfile

echo ========================================================================

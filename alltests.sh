#! /bin/sh 

## File:      alltests.sh
## Author(s): Kostis Sagonas
##
## $Id: alltests.sh,v 1.2 2001/02/19 16:45:06 kostis Exp $
##

echo "-------------------------------------------------------"
echo "--- Running alltests.sh                             ---"
echo "-------------------------------------------------------"

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

if test -z "$1" -o $# -gt 2; then
  echo " Usage: alltests.sh [--rts_opts rts_opts] [--comp_opts comp_opts]"
  echo "                    [--only \"test_list\"] [--add \"added_tests\"]"
  echo "                    [--exclude \"excl_list\"] hipe_rts hipe_comp"
  echo " where: rts_opts   -- options to pass to the HiPE executable"
  echo "        comp_opts  -- options to pass to the HiPE compiler"
  echo "        only_list  -- run only this list of tests"
  echo "        add_list   -- list of additional tests to run"
  echo "        excl_list  -- quoted, space-separated list of tests to NOT run"
  echo "        hipe_rts   -- full path name of the HiPE executable (required)"
  echo "        hipe_comp  -- full path name of the HiPE compiler (required)"
  echo " NOTE: hipe_rts & hipe_comp must appear in this order!"
  exit
fi

HIPE_RTS=$1

# ---------------------------------------------------------------------
# Test if element is a member of exclude list
# $1 - element
# $2 - exclude list
member ()
{
    for elt in $2 ; do
	if test "$1" = "$elt" ; then
	    return 0
	fi
    done
    return 1
}
# ---------------------------------------------------------------------

default_testlist="basic_tests trivial_tests process_tests bench_tests"

if test -z "$only_tests"; then
  testlist="$default_testlist $added_tests"
else
  testlist=$only_tests
fi
  echo "Will be testing:" $testlist

##
## Run each test in $testlist except for the tests in $excluded_tests
##
for tstdir in $testlist ; do
  if member "$tstdir" "$excluded_tests" ; then
    continue
  else
    cd $tstdir
    if test -f core ; then
	rm -f core
    fi
    ./test.sh "$HIPE_RTS" "$comp_options" "$rts_options"
    cd ..
  fi
done

# ---------------------------------------------------------------------

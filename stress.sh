#! /bin/sh

##====================================================================
## File:      stress.sh
## Author(s): Kostis Sagonas
## Purpose:   To stress-test the HiPE system.
##
## $Id: stress.sh,v 1.3 2004/12/06 12:07:14 kostis Exp $
##====================================================================

# Run from testsuite directory
startdir=`pwd`
testdir=`dirname $0`
cd $testdir

if test $# -eq 0; then
    OTP_DIR=$startdir
else
    OTP_DIR=$1
fi

## first test that there are no discrepancies in HiPE
time ./testsuite.sh --system "$OTP_DIR"
## run the testsuite with all register allocators
./ra.sh "$OTP_DIR"
## run the testsuite starting compilation from Core
./testsuite.sh --core "$OTP_DIR"
## finally, run the compiler_tests with the default allocator
time ./testsuite.sh --only compiler_tests "$OTP_DIR"

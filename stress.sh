#! /bin/sh

##====================================================================
## File:      stress.sh
## Author(s): Kostis Sagonas
## Purpose:   
##
## $Id: stress.sh,v 1.1 2004/10/03 10:52:39 kostis Exp $
##====================================================================

OTP_DIR=$1

## first test that there are no discrepancies in HiPE
time ./testsuite.sh --system $OTP_DIR
## run the testsuite with all register allocators
./ra.sh $OTP_DIR
## finally, run the compiler_tests with the default allocator
time ./testsuite.sh --only compiler_tests $OTP_DIR


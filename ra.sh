#! /bin/sh

##====================================================================
## File:      ra.sh
## Author(s): Kostis Sagonas
## Purpose:   To test the HiPE system with all register allocators.
##
## $Id: ra.sh,v 1.2 2001/10/04 14:02:56 kostis Exp $
##====================================================================

OSH_DIR=$1

./testsuite.sh --comp_opts "[o2]" $OSH_DIR	## this tests the default RA
./testsuite.sh --comp_opts "[o2,\{regalloc,linear_scan\}]" $OSH_DIR
./testsuite.sh --comp_opts "[o2,\{regalloc,graph_color\}]" $OSH_DIR
./testsuite.sh --comp_opts "[o2,\{regalloc,coalescing\}]"  $OSH_DIR

#! /bin/sh

##====================================================================
## File:      arch.sh
## Author(s): Jesper W
## Purpose:   To test the HiPE system with all register allocators.
##
## $Id: arch.sh,v 1.1 2003/11/12 13:23:26 jesperw Exp $
##====================================================================

OSH_DIR=$1

./testsuite.sh $OSH_DIR
./testsuite.sh --rts_opts -shared $OSH_DIR
./testsuite.sh --rts_opts -hybrid $OSH_DIR

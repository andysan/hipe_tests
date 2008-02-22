#!/bin/bash

usage()
{
    echo "Usage:"
    echo ""
    echo "[-o OTP_DIR]        Erlang/OTP base directory. Default 'pwd'/../otp"
    echo "[-c CONTRACTS_DIR]  Contracts directory. Default 'pwd'/../contracts"
    echo ""
    echo "Note: You can add symlinks to the various directories so you don't "
    echo "      have to use the flags."
}

while getopts "hs:o:" Option
do
  case $Option in
      o     ) otp_dir=${OPTARG};;
      c     ) contracts_dir=${OPTARG};;
      s     ) host=${OPTARG};;
      h     ) usage; exit;;
  esac
done
shift $(($OPTIND - 1))

if [[ x$otp_dir == x ]]; then otp_dir=`pwd`/../otp; fi
if [ ! -d $otp_dir ]; then
    echo "No directory $otp_dir. Please supply an otp_dir using -o."
    usage; exit 1
fi
if [[ x$contracts_dir == x ]]; then contracts_dir=`pwd`/../contracts; fi
if [ ! -d $contracts_dir ]; then
    echo "No directory $contracts_dir. Please add a contracts_dir using -c."
    usage; exit 1
fi
erl="$otp_dir/bin/erl"

for dir in *_tests;
do
    echo "Entering $dir"
    cd ${dir}
    erl -make
    for file in *.beam; do
	if [[ $file == "test.beam" ]]; then
	    echo "Ignoring test.beam"
	else
	    echo -n "$dir/$file: "
	    module=$(echo $file | sed 's/.beam//')
	    $erl -pa ./ -pa ${contracts_dir}/lib/*/ebin -noshell \
		-run checker run ${module} test []. -s init stop \
		> /dev/null 2> /dev/null
	    echo "done"
	fi
    done
    cd ..
done

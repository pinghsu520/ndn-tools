#!/usr/bin/env bash
set -e

JDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$JDIR"/util.sh

set -x

# Prepare environment
rm -Rf ~/.ndn

BOOST_VERSION=$(python -c "import sys; sys.path.append('build/c4che'); import _cache; print(_cache.BOOST_VERSION_NUMBER);")

ut_log_args() {
    ((ut_count+=1))
    if (( BOOST_VERSION >= 106200 )); then
        echo --logger=HRF,test_suite,stdout:XML,all,build/xunit-report-${ut_count}.xml
    else
        if [[ -n $XUNIT ]]; then
            echo --log_level=all $( (( BOOST_VERSION >= 106000 )) && echo -- ) \
                 --log_format2=XML --log_sink2=build/xunit-report-${ut_count}.xml
        else
            echo --log_level=test_suite
        fi
    fi
}

ASAN_OPTIONS="color=always"
ASAN_OPTIONS+=":detect_leaks=false"
ASAN_OPTIONS+=":detect_stack_use_after_return=true"
ASAN_OPTIONS+=":check_initialization_order=true"
ASAN_OPTIONS+=":strict_init_order=true"
ASAN_OPTIONS+=":detect_invalid_pointer_pairs=1"
ASAN_OPTIONS+=":detect_container_overflow=false"
ASAN_OPTIONS+=":strict_string_checks=true"
ASAN_OPTIONS+=":strip_path_prefix=${PWD}/"
export ASAN_OPTIONS

# Run unit tests
./build/unit-tests $(ut_log_args)

unset ut_count

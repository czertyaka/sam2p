#!/bin/bash

set -ex

dir=$1
timeout=$2
output_type=$3
master=$4

if [[ ${master} -eq 1 ]]; then
    role_flag="M"
else
    role_flag="S"
fi

if [ "$(ls -A ${dir}/output/${output_type}/_resume)" ]; then
    # input_arg="-"
    input_arg="${dir}/corpus"
else
    input_arg="${dir}/corpus"
fi

afl-fuzz -i ${input_arg} -o ${dir}/output -${role_flag} ${output_type} -V ${timeout} -- \
    ./${dir}/sam2p @@ ${dir}/out.${output_type}

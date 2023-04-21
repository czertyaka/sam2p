#!/bin/bash

dir=$1
timeout=$2
output_type=$3
master=$4

if [[ ${master} -eq 1 ]]; then
    role_flag="M"
else
    role_flag="S"
fi

timeout -s INT ${timeout} \
    afl-fuzzer -i ${dir}/corpus -o ${dir}/output -${role_flag} ${output_type} -- \
    ./${dir}/sam2p -- ${dir}/out.${output_type}
exit 0

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

afl-fuzz -i ${arg}/corpus -o ${dir}/output -${role_flag} ${output_type} -V ${timeout} -- \
    ./${dir}/sam2p @@ ${dir}/out.${output_type}

#!/bin/bash
if ! command -v conda &> /dev/null
then
    echo "Downloading conda"
    wget "https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh"
    ./Anaconda3-2021.05-Linux-x86_64.sh
fi
eval "$(conda shell.bash hook)"

if [[ $(basename "${CONDA_PREFIX}") != "$1" ]] && ! conda activate ${1} &> /dev/null
then
    conda create -y --name ${1} python=3.6
    conda activate ${1}
fi
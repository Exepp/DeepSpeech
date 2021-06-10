#!/bin/bash

if [[ "$CONDA_PREFIX" == "" ]]
then
    source ./zako_env.sh
fi

if [[ "$CONDA_PREFIX" != "" ]]
then
    pip show deepspeech &> /dev/null && yes | pip uninstall deepspeech
    pip show deepspeech-gpu &> /dev/null && yes | pip uninstall deepspeech-gpu
    pip show deepspeech-training &> /dev/null || yes | pip install -e .

    if [[ "$1" == "tflite" ]]
    then
        python3 DeepSpeech.py --checkpoint_dir ./deepspeech-0.9.3-checkpoint/ --export_dir ./export_dir/ --export_tflite #--dev_files ./data/lingua_libre/lingua_libre_Q22-eng-English_dev.csv
    else
        python3 DeepSpeech.py --checkpoint_dir ./deepspeech-0.9.3-checkpoint/ --export_dir ./export_dir/ && \
        python3 util/taskcluster.py --source tensorflow --artifact convert_graphdef_memmapped_format --branch r1.15 --target . && \
        ./convert_graphdef_memmapped_format --in_graph=export_dir/output_graph.pb --out_graph=export_dir/output_graph.pbmm
    fi
fi
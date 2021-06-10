#!/bin/bash
ctx="cpu"
model_path="export_dir/output_graph.pbmm"
scorer_path=""
audio="data/nagranie1.wav"

while [ ! -z "$1" ]
do
    if [[ "$1" == "--gpu" ]]
    then
        ctx="gpu"
    elif [[ "$1" == "--model" ]]
    then
        model_path="$2"
        shift
    elif [[ "$1" == "--scorer" ]]
    then
        scorer_path="$2"
        shift
    elif [[ "$1" == "--audio" ]]
    then
        audio="$2"
        shift
    else
        echo "Incorrect argument provided"
        exit 1
    fi
shift
done

if [[ "$CONDA_PREFIX" == "" ]]
then
    source ./zako_env.sh
fi

if [[ "$CONDA_PREFIX" != "" ]]
then
    if [ ! -f "${model_path}" ]
    then
        if [[ "${model_path}" == "export_dir/output_graph.pbmm" ]]
        then
            ./zako_export.sh
        else
            echo "Wrong model path"
            exit 1
        fi
    fi

    pip show deepspeech-training &> /dev/null && yes | pip uninstall deepspeech-training

    if [[ "$ctx" == "gpu" ]]
    then
        pip show deepspeech &> /dev/null && yes | pip uninstall deepspeech
        pip show deepspeech-gpu &> /dev/null || conda install -y cudnn=7.6.5=cuda10.1_0 & \
            yes | pip install deepspeech-gpu==0.9.3
    else
        pip show deepspeech-gpu &> /dev/null && yes | pip uninstall deepspeech-gpu
        pip show deepspeech &> /dev/null || yes | pip install deepspeech==0.9.3
    fi
    scorer_arg=""
    if [[ "$scorer_path" != "" ]]
    then
        scorer_arg="--scorer $scorer_path"
    fi
    echo "deepspeech --model $model_path $scorer_arg --audio $audio"
    deepspeech --model ${model_path} ${scorer_arg} --audio ${audio}
fi
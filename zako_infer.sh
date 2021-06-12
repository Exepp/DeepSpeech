#!/bin/bash
model_path_c="export_dir/output_graph.pbmm"

ctx="cpu"
model_path="${model_path_c}"
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

if [ ! -f "${model_path}" ]
then
    if [[ "${model_path}" == "${model_path_c}" ]]
    then
        ./zako_export.sh
    else
        echo "Wrong model path"
        exit 1
    fi
fi
model_extension="$(basename ${model_path})"
model_extension="${model_extension##*.}"
if [[ "${model_extension}" == "tflite" ]]
then
    ctx="cpu"
fi

env_name="zako_infer_${ctx}"
source ./zako_env.sh ${env_name}

if [[ $(basename "${CONDA_PREFIX}") == "${env_name}" ]]
then
    if [[ "$ctx" == "gpu" ]]
    then
        if ! pip show deepspeech-gpu &> /dev/null
        then 
            conda install -y cudnn=7.6.5=cuda10.1_0 && yes | pip install deepspeech-gpu==0.9.3
        fi
    else
        if [[ "${model_extension}" == "tflite" ]]
        then
            pip show deepspeech &> /dev/null && yes | pip uninstall deepspeech
            pip show deepspeech-tflite &> /dev/null || yes | pip install deepspeech-tflite==0.9.3
        else
            pip show deepspeech-tflite &> /dev/null && yes | pip uninstall deepspeech-tflite
            pip show deepspeech &> /dev/null || yes | pip install deepspeech==0.9.3
        fi
    fi
    
    scorer_arg=""
    if [[ "$scorer_path" != "" ]]
    then
        scorer_arg="--scorer $scorer_path"
    fi
    echo "deepspeech --model $model_path $scorer_arg --audio $audio"
    deepspeech --model ${model_path} ${scorer_arg} --audio ${audio}
else
    echo "Environment error"
fi
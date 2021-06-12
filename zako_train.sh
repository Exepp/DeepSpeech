#!/bin/bash
source ./zako_env.sh zako_train

if [[ $(basename "${CONDA_PREFIX}") == "zako_train" ]]
then
    if ! pip show deepspeech-training &> /dev/null 
    then
        conda install -y cudnn=7.6.5=cuda10.0_0 && \
            yes | pip install -e . && \
            yes | pip uninstall tensorflow && \
            yes | pip install tensorflow-gpu==1.15.4
    fi

    if [[ "$1" == "getdataset" ]]
    then
        python bin/import_lingua_libre.py --qId 22 --iso639-3 eng --english-name English --filter_alphabet data/alphabet.txt data/lingua_libre/
    fi
    TF_FORCE_GPU_ALLOW_GROWTH=true python DeepSpeech.py --log_level=0 --n_hidden 2048 --checkpoint_dir ./deepspeech-0.9.3-checkpoint --epochs 1 --train_files ./data/lingua_libre/lingua_libre_Q22-eng-English_train.csv --dev_files ./data/lingua_libre/lingua_libre_Q22-eng-English_dev.csv --test_files ./data/lingua_libre/lingua_libre_Q22-eng-English_test.csv --learning_rate 0.0001 --train_cudnn
else
    echo "Environment error"
fi
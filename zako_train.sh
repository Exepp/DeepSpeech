#!/bin/bash
if [[ "$CONDA_PREFIX" == "" ]]
then
    source ./zako_env.sh
fi

if [[ "$CONDA_PREFIX" != "" ]]
then
    pip show deepspeech &> /dev/null && yes | pip uninstall deepspeech
    pip show deepspeech-gpu &> /dev/null && yes | pip uninstall deepspeech-gpu
    pip show tensorflow-gpu &> /dev/null || conda install -y cudnn=7.6.5=cuda10.0_0 && \
        yes | pip install -e . && \
        yes | pip uninstall tensorflow && \
        yes | pip install tensorflow-gpu==1.15.4

    if [[ "$1" == "getdataset" ]]
    then
        python bin/import_lingua_libre.py --qId 22 --iso639-3 eng --english-name English --filter_alphabet data/alphabet.txt data/lingua_libre/
    fi
    TF_FORCE_GPU_ALLOW_GROWTH=true python DeepSpeech.py --log_level=0 --n_hidden 2048 --checkpoint_dir ./deepspeech-0.9.3-checkpoint --epochs 1 --train_files ./data/lingua_libre/lingua_libre_Q22-eng-English_train.csv --dev_files ./data/lingua_libre/lingua_libre_Q22-eng-English_dev.csv --test_files ./data/lingua_libre/lingua_libre_Q22-eng-English_test.csv --learning_rate 0.0001 --train_cudnn
fi
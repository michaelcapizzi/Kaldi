#!/bin/bash


data=${KALDI_PATH}/egs/mini_librispeech/raw_data

# -s <int> = which stage to start the script on
# -n <int> = how many processors to use for steps
# -c <str> = which command to use (run.pl or queue.pl)

stage=0
num_proc=1
train_cmd=run.pl

while getopts "s:n:c:" opt; do
    case ${opt} in
        s)
            stage=${OPTARG}
            ;;
        n)
            num_proc=${OPTARG}
            ;;
        c)
            train_cmd=${OPTARG}
            ;;
        \?)
            echo "Wrong flags"
            exit 1
            ;;
    esac
done

decode_cmd=$train_cmd

data_url=www.openslr.org/resources/31
lm_url=www.openslr.org/resources/11

. $KALDI_PATH/egs/mini_librispeech/s5/path.sh

. $KALDI_PATH/egs/mini_librispeech/s5/utils/parse_options.sh

set -euo pipefail

mkdir -p $data

########################
# STAGE 0: Download data
########################

if [ $stage -le 0 ]; then
  for part in dev-clean-2 train-clean-5; do
    local/download_and_untar.sh $data $data_url $part
  done
  local/download_lm.sh $lm_url data/local/lm
fi

#######################
# STAGE 1: Prepare data
#######################

if [ $stage -le 1 ]; then
  # format the data as Kaldi data directories
  for part in dev-clean-2 train-clean-5; do
    # use underscore-separated names in data directories.
    local/data_prep.sh $data/LibriSpeech/$part data/$(echo $part | sed s/-/_/g)
  done

  local/prepare_dict.sh --stage 3 --nj $num_proc --cmd "$train_cmd" \
    data/local/lm data/local/lm data/local/dict_nosp

  utils/prepare_lang.sh data/local/dict_nosp \
    "<UNK>" data/local/lang_tmp_nosp data/lang_nosp

  local/format_lms.sh --src-dir data/lang_nosp data/local/lm
fi

#####################
# STAGE 2: Make mfccs
#####################

if [ $stage -le 2 ]; then
  mfccdir=mfcc

  for part in dev_clean_2 train_clean_5; do
    steps/make_mfcc.sh --cmd "$train_cmd" --nj $num_proc data/$part exp/make_mfcc/$part $mfccdir
    steps/compute_cmvn_stats.sh data/$part exp/make_mfcc/$part $mfccdir
  done

  # Get the shortest 500 utterances as a subset for quick testing
  utils/subset_data_dir.sh --shortest data/train_clean_5 500 data/train_500short

  # Get the shortest 40 utterances as subset
  utils/subset_data_dir.sh --shortest data/dev_clean_2 40 data/dev_40short

fi

##################################
# STAGE 3: Monophones Model (mono)
##################################

# train a monophone system
if [ $stage -le 3 ]; then
  steps/train_mono.sh --boost-silence 1.25 --nj $num_proc --cmd "$train_cmd" --num_iters 2 --totgauss 500 \
    data/train_500short data/lang_nosp exp/mono
  utils/mkgraph.sh data/lang_nosp_test_tgsmall exp/mono exp/mono/graph_nosp_tgsmall
  steps/decode.sh --nj $num_proc --cmd "$decode_cmd" exp/mono/graph_nosp_tgsmall \
    data/dev_40short exp/mono/decode_nosp_tgsmall_dev_40short
  local/score.sh --cmd "$decode_cmd" data/dev_40short exp/mono/graph_nosp_tgsmall \
    exp/mono/decode_nosp_tgsmall_dev_40short
  steps/align_si.sh --boost-silence 1.25 --nj $num_proc --cmd "$train_cmd" \
    data/train_500short data/lang_nosp exp/mono exp/mono_ali_train_500short
fi

#################################
# STAGE 4: Triphones Model (tri1)
#################################

# train a first delta + delta-delta triphone system
if [ $stage -le 4 ]; then
  steps/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" --num_iters 2 \
    2000 10000 data/train_500short data/lang_nosp exp/mono_ali_train_500short exp/tri1
  utils/mkgraph.sh data/lang_nosp_test_tgsmall exp/tri1 exp/tri1/graph_nosp_tgsmall
  steps/decode.sh --nj $num_proc --cmd "$decode_cmd" exp/tri1/graph_nosp_tgsmall \
    data/dev_40short exp/tri1/decode_nosp_tgsmall_dev_40short
  local/score.sh --cmd "$decode_cmd" data/dev_40short exp/tri1/graph_nosp_tgsmall \
    exp/tri1/decode_nosp_tgsmall_dev_40short
  steps/align_si.sh --nj $num_proc --cmd "$train_cmd" \
    data/train_500short data/lang_nosp exp/tri1 exp/tri1_ali_train_500short
fi

################################################
# STAGE 5: Triphones Model with LDA+MLLT (tri2b)
################################################

# train an LDA+MLLT system.
if [ $stage -le 5 ]; then
  steps/train_lda_mllt.sh --cmd "$train_cmd" --num_iters 2 \
    --splice-opts "--left-context=3 --right-context=3" 2500 15000 \
    data/train_500short data/lang_nosp exp/tri1_ali_train_500short exp/tri2b
  utils/mkgraph.sh data/lang_nosp_test_tgsmall exp/tri2b exp/tri2b/graph_nosp_tgsmall
  steps/decode.sh --nj $num_proc --cmd "$decode_cmd" exp/tri2b/graph_nosp_tgsmall \
    data/dev_40short exp/tri2b/decode_nosp_tgsmall_dev_40short
  local/score.sh --cmd "$decode_cmd" data/dev_40short exp/tri2b/graph_nosp_tgsmall \
    exp/tri2b/decode_nosp_tgsmall_dev_40short
  steps/align_si.sh  --nj $num_proc --cmd "$train_cmd" --use-graphs true \
    data/train_clean_5 data/lang_nosp exp/tri2b exp/tri2b_ali_train_500short
fi

####################################################
# STAGE 6: Triphones Model with LDA+MLLT+SAT (tri3b)
####################################################

# Train tri3b, which is LDA+MLLT+SAT
if [ $stage -le 6 ]; then
  steps/train_sat.sh --cmd "$train_cmd" 2500 15000 \
    data/train_500short data/lang_nosp exp/tri2b_ali_train_500short exp/tri3b
   utils/mkgraph.sh data/lang_nosp_test_tgsmall exp/tri3b exp/tri3b/graph_nosp_tgsmall
   steps/decode_fmllr.sh --nj $num_proc --cmd "$decode_cmd" \
    exp/tri3b/graph_nosp_tgsmall data/dev_40short \
    exp/tri3b/decode_nosp_tgsmall_dev_40short
#  local/score.sh --cmd "$decode_cmd" data/dev_40short exp/tri3b/graph_nosp_tgsmall \
#    exp/tri3b/decode_nosp_tgsmall_dev_40short
  local/score.sh --cmd "$decode_cmd" data/dev_40short exp/tri3b/graph_nosp_tgsmall \
    exp/tri3b/decode_nosp_tgsmall_dev_40short.si
fi

######################
# STAGE 7: report WERs
######################

if [ $stage -le 7 ]; then
  # print out best results for each model
  for type in mono tri1b tri2b tri3b; do
    wer=$(grep WER ${type}/decode_nosp_tgsmall_test/wer_* | utils/best_wer.sh | cut -d " " -f 2-)
    ser=$(grep SER ${type}/decode_nosp_tgsmall_test/wer_* | utils/best_wer.sh | cut -d " " -f 3-)
    echo "Best results for $type:"
    echo "WER: ${wer}"
    echo "SER: ${ser}"
    echo "-----"
  done
fi

#
## Now we compute the pronunciation and silence probabilities from training data,
## and re-create the lang directory.
#if [ $stage -le 7 ]; then
#  steps/get_prons.sh --cmd "$train_cmd" \
#    data/train_clean_5 data/lang_nosp exp/tri3b
#  utils/dict_dir_add_pronprobs.sh --max-normalize true \
#    data/local/dict_nosp \
#    exp/tri3b/pron_counts_nowb.txt exp/tri3b/sil_counts_nowb.txt \
#    exp/tri3b/pron_bigram_counts_nowb.txt data/local/dict
#
#  utils/prepare_lang.sh data/local/dict \
#    "<UNK>" data/local/lang_tmp data/lang
#
#  local/format_lms.sh --src-dir data/lang data/local/lm
#
#  utils/build_const_arpa_lm.sh \
#    data/local/lm/lm_tglarge.arpa.gz data/lang data/lang_test_tglarge
#
#  steps/align_fmllr.sh --nj 5 --cmd "$train_cmd" \
#    data/train_clean_5 data/lang exp/tri3b exp/tri3b_ali_train_clean_5
#fi
#
#
#if [ $stage -le 8 ]; then
#  # Test the tri3b system with the silprobs and pron-probs.
#
#  # decode using the tri3b model
#  utils/mkgraph.sh data/lang_test_tgsmall \
#                   exp/tri3b exp/tri3b/graph_tgsmall
#  for test in dev_clean_2; do
#    steps/decode_fmllr.sh --nj 10 --cmd "$decode_cmd" \
#                          exp/tri3b/graph_tgsmall data/$test \
#                          exp/tri3b/decode_tgsmall_$test
#    steps/lmrescore.sh --cmd "$decode_cmd" data/lang_test_{tgsmall,tgmed} \
#                       data/$test exp/tri3b/decode_{tgsmall,tgmed}_$test
#    steps/lmrescore_const_arpa.sh \
#      --cmd "$decode_cmd" data/lang_test_{tgsmall,tglarge} \
#      data/$test exp/tri3b/decode_{tgsmall,tglarge}_$test
#  done
#fi
#
## Train a chain model
#if [ $stage -le 9 ]; then
#  local/chain/run_tdnn.sh --stage 0
#fi
#
## Don't finish until all background decoding jobs are finished.
#wait

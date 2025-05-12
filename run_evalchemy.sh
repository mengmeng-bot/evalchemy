#!/bin/bash

#ENDPOINT_URL=https://fast-cloud-snova-ai-dev-5-api.cloud.snova.ai/v1/chat/completions
MAX_LENGTH=32768 #16384 #8192
MAX_TOKENS=15000 #6200
MAX_TOKENS_GPQA=13000 #29000
MAX_TOKENS_LIVECODEBENCH=14000

# ENDPOINT_URL=https://preview.snova.ai/v1/chat/completions
#ENDPOINT_URL=https://api.sambanova.ai/v1/chat/completions
# MAX_LENGTH=8192
# MAX_TOKENS=7000 #6200
# MAX_TOKENS_GPQA=5300
# MAX_LENGTH=32768
# MAX_TOKENS=31000
# MAX_TOKENS_GPQA=29000
BATCH_SIZE=1
# MODEL_NAME=Meta-Llama-3.2-1B-Instruct
# MODEL_NAME=DeepSeek-V3-0324
# MODEL_NAME=deepseek-ai/DeepSeek-V3
# MODEL_NAME="DeepSeek-R1"
MODEL_NAME=Llama-4-Maverick-17B-128E-Instruct


# MAX_LENGTH=128000
# MAX_TOKENS=50000 #6200
# MAX_TOKENS_GPQA=50000
# MODEL_NAME=DeepSeek-R1-Distill-Llama-70B

    # --model local-completions --apply_chat_template False \
    # --model_args "tokenized_requests=False,base_url=${ENDPOINT_URL},tokenizer=/import/ml-sc-nlpcheckpoints-scratch3/johnl/copied_ckpts/DeepSeek-R1,model=default,max_length=163840,max_tokens=${MAX_TOKENS}" \

    #--gen_kwargs "max_completion_tokens=${MAX_TOKENS}" \

echo "SN_API_KEY ${SN_API_KEY}"
echo "ENDPOINT_URL ${ENDPOINT_URL}"
echo "HF_TOKEN ${HF_TOKEN}"


# echo "evalchemy AIME"
# HF_HOME=/import/ml-sc-scratch1/mengmengj/cache OPENAI_API_KEY=${SN_API_KEY} python -m eval.eval \
#     --tasks AIME24 \
#     --model openai-chat-completions \
#     --apply_chat_template True \
#     --model_args "tokenized_requests=False,base_url=${ENDPOINT_URL},model=${MODEL_NAME},max_length=${MAX_LENGTH},eos_string=<｜end▁of▁sentence｜>,num_concurrent=1,max_retries=10,max_gen_toks=${MAX_TOKENS}" \
#     --gen_kwargs "do_sample=True,temperature=0.7" \
#     --batch_size ${BATCH_SIZE} \
#     --output_path logs \
#     2>&1 | tee Llama-4-Maverick-17B-128E-Instruct_aime24_$(date +"%Y-%m-%d_%H-%M-%S").txt
#     2>&1 | tee deepseekR1_aime24_$(date +"%Y-%m-%d_%H-%M-%S").txt

echo "evalchemy GPQADiamond"
HF_HOME=/import/ml-sc-scratch1/mengmengj/cache HF_TOKEN=${HF_TOKEN} OPENAI_API_KEY=${SN_API_KEY} python -m eval.eval \
    --tasks GPQADiamond \
    --model openai-chat-completions \
    --apply_chat_template False \
    --model_args "tokenized_requests=False,base_url=${ENDPOINT_URL},model=${MODEL_NAME},max_length=${MAX_LENGTH},eos_string=<｜end▁of▁sentence｜>,num_concurrent=1,max_retries=10,max_gen_toks=${MAX_TOKENS_GPQA}" \
    --gen_kwargs "do_sample=True,temperature=0.7" \
    --batch_size ${BATCH_SIZE} \
    --output_path logs \
    2>&1 | tee Llama-4-Maverick-17B-128E-Instruct_gpqadiamond_$(date +"%Y-%m-%d_%H-%M-%S").txt
#     2>&1 | tee deepseekR1_gpqadiamond_$(date +"%Y-%m-%d_%H-%M-%S").txt

echo "evalchemy IFEval"
HF_HOME=/import/ml-sc-scratch1/mengmengj/cache OPENAI_API_KEY=${SN_API_KEY} python -m eval.eval \
    --tasks IFEval \
    --model openai-chat-completions \
    --apply_chat_template False \
    --model_args "tokenized_requests=False,base_url=${ENDPOINT_URL},model=${MODEL_NAME},max_length=${MAX_LENGTH},eos_string=<｜end▁of▁sentence｜>,max_gen_toks=${MAX_TOKENS},max_retries=10,num_concurrent=1,max_gen_toks=${MAX_TOKENS}" \
    --gen_kwargs "do_sample=True,temperature=0.7" \
    --batch_size ${BATCH_SIZE} \
    --output_path logs \
    2>&1 | tee Llama-4-Maverick-17B-128E-Instruct_ifeval_$(date +"%Y-%m-%d_%H-%M-%S").txt
#     2>&1 | tee deepseekR1_ifeval_$(date +"%Y-%m-%d_%H-%M-%S").txt

echo "evalchemy MATH500"
HF_HOME=/import/ml-sc-scratch1/mengmengj/cache OPENAI_API_KEY=${SN_API_KEY} python -m eval.eval \
    --tasks MATH500 \
    --model openai-chat-completions \
    --apply_chat_template False \
    --model_args "tokenized_requests=False,base_url=${ENDPOINT_URL},model=${MODEL_NAME},max_length=${MAX_LENGTH},eos_string=<｜end▁of▁sentence｜>,num_concurrent=1,max_retries=10,max_gen_toks=${MAX_TOKENS}" \
    --gen_kwargs "do_sample=True,temperature=0.7" \
    --batch_size ${BATCH_SIZE} \
    --output_path logs \
    2>&1 | tee Llama-4-Maverick-17B-128E-Instruct_math500_$(date +"%Y-%m-%d_%H-%M-%S").txt
#     2>&1 | tee deepseekR1_math500_$(date +"%Y-%m-%d_%H-%M-%S").txt

echo "evalchemy LiveCodeBench"
HF_HOME=/import/ml-sc-scratch1/mengmengj/cache OPENAI_API_KEY=${SN_API_KEY} python -u -m eval.eval \
    --model openai-chat-completions --tasks LiveCodeBench --apply_chat_template False \
    --model_args "tokenized_requests=False,base_url=${ENDPOINT_URL},model=${MODEL_NAME},max_length=${MAX_LENGTH},max_gen_toks=${MAX_TOKENS_LIVECODEBENCH},eos_string=<｜end▁of▁sentence｜>,num_recurrent=1,max_retries=10" \
    --gen_kwargs "do_sample=True,temperature=0.7" \
    --batch_size ${BATCH_SIZE} \
    --output_path logs \
    2>&1 | tee Llama-4-Maverick-17B-128E-Instruct_livecodebench_$(date +"%Y-%m-%d_%H-%M-%S").txt
    # 2>&1 | tee deepseekR1_livecodebench_$(date +"%Y-%m-%d_%H-%M-%S").txt
# python -u print out 
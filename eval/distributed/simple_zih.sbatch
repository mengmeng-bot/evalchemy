#!/bin/bash
#SBATCH --nodes={num_nodes}
#SBATCH --ntasks-per-node=4
#SBATCH --gres=gpu:4
#SBATCH --time={time_limit}
#SBATCH --mem=512G
#SBATCH --cpus-per-task=8
#SBATCH --account=p_finetuning
#SBATCH --job-name={job_name}
#SBATCH --output={logs_dir}/%x_%j.out
#SBATCH --exclude=c77
#SBATCH --mail-type=END,TIME_LIMIT,FAIL
#SBATCH --mail-user=dcft-slurm-notifs-aaaap7wt363mcsgryaejj2o6dm@dogs-and-ml.slack.com

# CUDA
module load release/24.04  GCCcore/12.3.0
module load CUDA/12.1.1
module load NCCL/2.18.3-CUDA-12.1.1
export PATH=/usr/local/cuda-12/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12/lib64:$LD_LIBRARY_PATH

# ENVIRONMENT VARIABLES - EVALCHEMY, HF_HUB_CACHE, and EVALCHEMY_ACTIVATE_ENV
export DCFT=/data/cat/ws/ryma833h-dcft
source $DCFT/dcft_private/hpc/dotenv/zih.env
source $DCFT/dcft_private/database/access.env

# CONDA
echo "Loading conda: $EVALCHEMY_ACTIVATE_ENV"
$EVALCHEMY_ACTIVATE_ENV

# DOWNLOAD MODEL AND DATASET
MODEL_NAME={model_name}
INPUT_DATASET={input_dataset}
OUTPUT_DATASET={output_dataset}
srun --nodes=1 --ntasks=1 huggingface-cli download $MODEL_NAME --cache-dir $HF_HUB_CACHE
srun --nodes=1 --ntasks=1 huggingface-cli download $INPUT_DATASET --cache-dir $HF_HUB_CACHE --repo-type dataset

# RUN SHARDED INFERENCE
srun --output={logs_dir}/%x_%j_%t.out bash -c 'echo -e "GLOBAL_SIZE: ${SLURM_STEP_NUM_TASKS}\nRANK: ${SLURM_PROCID}\nMODEL: '$MODEL_NAME'\nINPUT_DATASET: '$INPUT_DATASET'\nOUTPUT_DATASET: '$OUTPUT_DATASET'"'
srun --output={logs_dir}/%x_%j_%t.out bash -c 'CUDA_VISIBLE_DEVICES=${SLURM_LOCALID} python $EVALCHEMY/eval/distributed/process_shard.py --global_size ${SLURM_STEP_NUM_TASKS} --rank ${SLURM_PROCID} --input_dataset '${INPUT_DATASET}' --model_name '${MODEL_NAME}' --output_dataset '${OUTPUT_DATASET}' --upload'

# COMPUTE SCORES
srun --nodes=1 --ntasks=1 python -m eval.eval --model precomputed_hf --model_args "repo_id={output_dataset}",model="{model_name}" --tasks {tasks_str} --output_path logs --use_database
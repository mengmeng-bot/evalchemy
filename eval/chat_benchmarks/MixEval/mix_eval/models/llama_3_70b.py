from dotenv import load_dotenv
import os

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

from mix_eval.models.base import BaseModel
from mix_eval.api.registry import register_model
from mix_eval.utils.common_utils import get_gpu_memory


@register_model("llama_3_70b")
class Llama_3_70B(BaseModel):
    def __init__(self, args):
        super().__init__(args)
        self.model_name = "meta-llama/Meta-Llama-3-70B"
        self.attn_implementation = "flash_attention_2"  # If use default, set to None  # If use default, set to None

        self.model_dtype = torch.bfloat16

        load_dotenv()
        self.hf_token = os.getenv("_FADKLFHAKH_")
        self.model = self.build_model()
        self.model_max_len = self.model.config.max_position_embeddings
        self.tokenizer = self.build_tokenizer()
        self.tokenizer.pad_token = self.tokenizer.eos_token
        self.max_input_length_closeend = min(self.model_max_len, self.max_input_length) - self.closeended_max_new_tokens

    def build_model(self):
        num_gpus = torch.cuda.device_count()
        kwargs = {}
        kwargs["device_map"] = "auto"
        if self.args.max_gpu_memory is None:
            kwargs["device_map"] = "sequential"  # This is important for not the same VRAM sizes
            available_gpu_memory = get_gpu_memory(num_gpus)
            kwargs["max_memory"] = {i: str(int(available_gpu_memory[i] * 0.85)) + "GiB" for i in range(num_gpus)}
        else:
            kwargs["max_memory"] = {i: self.args.max_gpu_memory for i in range(num_gpus)}

        if self.attn_implementation is not None:
            kwargs["attn_implementation"] = self.attn_implementation

        model = AutoModelForCausalLM.from_pretrained(
            self.model_name,
            torch_dtype=self.model_dtype,
            trust_remote_code=self.trust_remote_code,
            token=self.hf_token,
            **kwargs,
        ).eval()
        return model

    def build_tokenizer(self):
        tokenizer = AutoTokenizer.from_pretrained(
            self.model_name,
            model_max_length=self.model_max_len,
            padding_side=self.padding_side,
            use_fast=self.use_fast_tokenizer,
            trust_remote_code=self.trust_remote_code,
            token=self.hf_token,
        )
        return tokenizer

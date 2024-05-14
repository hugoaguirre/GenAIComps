#!/bin/bash

# Copyright (c) 2024 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set default values
default_port=8080
default_model="meta-llama/Llama-2-7b-chat-hf"
default_chat_processor="ChatModelLlama"
default_num_cpus_per_worker=8
default_num_hpus_per_worker=1

# Assign arguments to variables
port_number=${1:-$default_port}
model_name=${2:-$default_model}
chat_processor=${3:-$default_chat_processor}
num_cpus_per_worker=${4:-$default_num_cpus_per_worker}
num_hpus_per_worker=${5:-$default_num_hpus_per_worker}

# Check if all required arguments are provided
if [ "$#" -lt 0 ] || [ "$#" -gt 5 ]; then
    echo "Usage: $0 [port_number] [model_name] [chat_processor] [num_cpus_per_worker] [num_hpus_per_worker]"
    echo "Please customize the arguments you want to use.
    - port_number: The port number assigned to the Ray Gaudi endpoint, with the default being 8080.
    - model_name: The model name utilized for LLM, with the default set to meta-llama/Llama-2-7b-chat-hf.
    - chat_processor: The chat processor for handling the prompts, with the default set to 'ChatModelNoFormat', and the optional selection can be 'ChatModelLlama', 'ChatModelGptJ" and "ChatModelGemma'.
    - num_cpus_per_worker: The number of CPUs specifies the number of CPUs per worker process.
    - num_hpus_per_worker: The number of HPUs specifies the number of HPUs per worker process."
    exit 1
fi

# Build the Docker run command based on the number of cards
docker run -it --runtime=habana --name="rayllm-habana" -e OMPI_MCA_btl_vader_single_copy_mechanism=none --cap-add=sys_nice --ipc=host --network=host -e HUGGINGFACEHUB_API_TOKEN=$HUGGINGFACEHUB_API_TOKEN -e TRUST_REMOTE_CODE=$TRUST_REMOTE_CODE rayllm:habana /bin/bash -c "ray start --head && python api_server_openai.py --port_number $port_number --model_id_or_path $model_name --chat_processor $chat_processor --num_cpus_per_worker $num_cpus_per_worker --num_hpus_per_worker $num_hpus_per_worker"

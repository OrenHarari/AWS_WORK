# vLLM + Mistral + ChatUI

docker network create llm-network

docker run -d \
  --name llm \
  --runtime nvidia \
  --gpus all \
  --network llm-network \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  --env "HUGGING_FACE_HUB_TOKEN=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" \
  -p 80:8000 \
  --ipc=host \
  vllm/vllm-openai:latest \
  --model mistralai/Mistral-7B-Instruct-v0.3 \
  --tokenizer-mode auto \
  --tensor-parallel-size 1 \
  --gpu-memory-utilization 0.85 \
  --max-model-len 4096 \
  --served-model-name gpt-3.5-turbo

docker run -d \
  --name chatui \
  --network llm-network \
  -p 443:3000 \
  -e OPENAI_API_HOST=http://llm:8000 \
  -e OPENAI_API_KEY=dummy \
  -e DEFAULT_MODEL=gpt-3.5-turbo \
  ghcr.io/mckaywrigley/chatbot-ui:main

docker logs -f llm
docker network inspect llm-network
curl http://localhost:80/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "gpt-3.5-turbo",
        "prompt": "Python is",
        "max_tokens": 20,
        "temperature": 0.1
    }'

[//]: # (curl http://localhost:80/v1/completions \)

[//]: # (-H "Content-Type: application/json" \)

[//]: # (-d '{)

[//]: # (  "model": "gpt-3.5-turbo",)

[//]: # (  "prompt": "המ",  # הטקסט שהמשתמש מתחיל להקליד)

[//]: # (  "max_tokens": 10,)

[//]: # (  "temperature": 0.1,)

[//]: # (  "stream": false)

[//]: # (}')

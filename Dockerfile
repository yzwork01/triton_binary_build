FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

COPY setup_ubuntu2204.sh /workspace/setup_triton_env.sh
COPY /triton_binary_24.09/full_tri.zip /opt/full_tri.zip
COPY Triton_test /opt/Triton_test

RUN chmod +x /workspace/setup_triton_env.sh && /workspace/setup_triton_env.sh

# Setup Triton files
RUN unzip -o /opt/full_tri.zip -d /opt
RUN chmod -R 777 /opt/tritonserver
RUN cp -r /opt/Triton_test /home/

EXPOSE 8000 8001 8002

CMD ["/opt/tritonserver/bin/tritonserver", "--model-repository=/home/Triton_test", "--allow-metrics=true", "--log-verbose=1"]

## deploy it
# docker build -t triton-ubuntu:2.50 .

# Run it
#docker run -it --rm -p8000:8000 -p8001:8001 -p8002:8002 --name triton-container triton-ubuntu:2.50

#/opt/tritonserver/bin/tritonserver --model-repository=/tmp/model_repo/Triton_test --allow-metrics=true --log-verbose=1
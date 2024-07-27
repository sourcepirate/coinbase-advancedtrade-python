# Use the Amazon Linux 2023 image compatible with AWS Lambda
FROM public.ecr.aws/lambda/python:3.9

# Set up the work directory
WORKDIR /var/task

# Copy your application code and requirements.txt into the Docker image
COPY . .

# Install dependencies and create the layer
RUN yum install -y zip && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    pip install . && \
    mkdir -p /tmp/python && \
    pip install \
        --platform manylinux2014_$(uname -m) \
        --implementation cp \
        --python-version 3.9 \
        --only-binary=:all: --upgrade \
        -r requirements.txt -t /tmp/python && \
    pip install . -t /tmp/python && \
    cd /tmp/python && \
    zip -r9 /tmp/layer.zip . -x '*.pyc' '*.pyo' && \
    cd /var/task

# Copy the layer.zip to a known location
CMD cp /tmp/layer.zip /asset-output/layer.zip
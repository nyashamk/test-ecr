# 12GB Docker image for ECR testing with 3.8GB largest layer
FROM ubuntu:22.04

# Install basic tools
RUN apt-get update && apt-get install -y \
    wget curl python3 python3-pip build-essential git \
    && rm -rf /var/lib/apt/lists/*

# Layer 1: ~2GB - Large ML packages
RUN pip3 install --no-cache-dir tensorflow==2.13.0 torch torchvision torchaudio

# Layer 2: ~3.8GB - LARGEST LAYER - Multiple large downloads
RUN mkdir -p /opt/large && cd /opt/large && \
    wget -q https://github.com/llvm/llvm-project/archive/refs/heads/main.tar.gz -O llvm.tar.gz && \
    wget -q https://github.com/microsoft/vscode/archive/refs/heads/main.tar.gz -O vscode.tar.gz && \
    wget -q https://github.com/kubernetes/kubernetes/archive/refs/heads/master.tar.gz -O k8s.tar.gz && \
    wget -q https://github.com/pytorch/pytorch/archive/refs/heads/main.tar.gz -O pytorch.tar.gz && \
    wget -q https://github.com/tensorflow/tensorflow/archive/refs/heads/master.tar.gz -O tf.tar.gz && \
    python3 -c "import os; [open(f'/opt/large/file_{i}.bin', 'wb').write(os.urandom(200*1024*1024)) for i in range(8)]"

# Layer 3: ~1.5GB - More packages
RUN pip3 install --no-cache-dir pandas numpy scipy matplotlib seaborn scikit-learn jupyter opencv-python

# Layer 4: ~1.2GB - Additional data
RUN mkdir -p /opt/data && \
    python3 -c "import os; [open(f'/opt/data/dataset_{i}.bin', 'wb').write(os.urandom(150*1024*1024)) for i in range(8)]"

# Layer 5: ~1GB - More downloads
RUN cd /opt && \
    wget -q https://github.com/golang/go/archive/refs/heads/master.tar.gz -O go.tar.gz && \
    wget -q https://github.com/rust-lang/rust/archive/refs/heads/master.tar.gz -O rust.tar.gz && \
    python3 -c "import os; [open(f'/opt/extra_{i}.bin', 'wb').write(os.urandom(100*1024*1024)) for i in range(6)]"

# Layer 6: ~1GB - Final layer
RUN mkdir -p /opt/final && \
    python3 -c "import os; [open(f'/opt/final/final_{i}.bin', 'wb').write(os.urandom(120*1024*1024)) for i in range(8)]"

# Layer 7: ~1.5GB - Additional packages and data
RUN pip3 install --no-cache-dir transformers datasets accelerate && \
    python3 -c "import os; [open(f'/opt/models_{i}.bin', 'wb').write(os.urandom(180*1024*1024)) for i in range(8)]"

WORKDIR /app
RUN echo "12GB test image - Largest layer: 3.8GB" > /app/README.txt

CMD ["echo", "12GB test image ready"]

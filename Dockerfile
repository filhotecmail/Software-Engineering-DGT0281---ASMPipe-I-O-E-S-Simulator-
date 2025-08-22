# Dockerfile para Simulador DMA - Sistema de Teste Profissional
# Base: Ubuntu 22.04 LTS com Python 3 e ferramentas de compilação

FROM ubuntu:22.04

# Definir variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Atualizar sistema e instalar dependências essenciais
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-tk \
    build-essential \
    nasm \
    gcc \
    g++ \
    make \
    binutils \
    gdb \
    vim \
    nano \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Criar link simbólico para python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Criar diretório de trabalho
WORKDIR /app

# Copiar requirements.txt primeiro (para cache do Docker)
COPY requirements.txt ./requirements.txt

# Instalar dependências Python
RUN pip3 install --no-cache-dir -r requirements.txt

# Copiar arquivos do projeto
COPY . .

# Definir permissões adequadas
RUN chmod +x src/python/*.py

# Criar diretório para arquivos temporários de compilação
RUN mkdir -p /tmp/asm_build

# Expor porta (caso necessário para futuras extensões)
EXPOSE 8080

# Comando padrão para executar o simulador
CMD ["python3", "src/python/gui_dma_tester.py"]

# Informações do container
LABEL maintainer="Simulador DMA Team"
LABEL version="1.0"
LABEL description="Container Docker para Simulador DMA com ambiente completo de desenvolvimento"
LABEL python.version="3.10+"
LABEL assembler="NASM"
LABEL compiler="GCC"
#!/bin/bash
# Script de Build Docker para Simulador DMA
# Sistema de Teste e Análise de Performance

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
IMAGE_NAME="simulador-dma"
IMAGE_TAG="latest"
CONTAINER_NAME="dma-simulator"

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}    SIMULADOR DMA - BUILD DOCKER${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "${YELLOW}Construindo imagem Docker com todas as dependências...${NC}"
echo

# Parar container existente se estiver rodando
echo -e "${YELLOW}Verificando containers existentes...${NC}"
if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
    echo -e "${YELLOW}Parando container existente: $CONTAINER_NAME${NC}"
    docker stop $CONTAINER_NAME
fi

if docker ps -aq -f name=$CONTAINER_NAME | grep -q .; then
    echo -e "${YELLOW}Removendo container existente: $CONTAINER_NAME${NC}"
    docker rm $CONTAINER_NAME
fi

# Build da imagem
echo -e "${BLUE}Construindo imagem Docker...${NC}"
echo -e "${YELLOW}Nome da imagem: $IMAGE_NAME:$IMAGE_TAG${NC}"
echo

docker build -t $IMAGE_NAME:$IMAGE_TAG .

if [ $? -eq 0 ]; then
    echo
    echo -e "${GREEN}✓ Build concluído com sucesso!${NC}"
    echo -e "${GREEN}✓ Imagem criada: $IMAGE_NAME:$IMAGE_TAG${NC}"
    echo
    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${BLUE}    COMANDOS PARA EXECUTAR O CONTAINER${NC}"
    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${YELLOW}Executar interativamente:${NC}"
    echo -e "${GREEN}docker run -it --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_TAG${NC}"
    echo
    echo -e "${YELLOW}Executar em background:${NC}"
    echo -e "${GREEN}docker run -d --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_TAG${NC}"
    echo
    echo -e "${YELLOW}Executar com volume (para desenvolvimento):${NC}"
    echo -e "${GREEN}docker run -it --name $CONTAINER_NAME -v \$(pwd):/app $IMAGE_NAME:$IMAGE_TAG${NC}"
    echo
    echo -e "${BLUE}======================================================================${NC}"
else
    echo -e "${RED}✗ Erro no build da imagem Docker${NC}"
    exit 1
fi
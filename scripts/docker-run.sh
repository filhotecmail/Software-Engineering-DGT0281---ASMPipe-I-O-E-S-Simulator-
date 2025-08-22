#!/bin/bash
# Script de Execução Docker para Simulador DMA
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
echo -e "${BLUE}    SIMULADOR DMA - EXECUÇÃO DOCKER${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Verificar se a imagem existe
if ! docker images | grep -q "$IMAGE_NAME.*$IMAGE_TAG"; then
    echo -e "${RED}✗ Imagem $IMAGE_NAME:$IMAGE_TAG não encontrada!${NC}"
    echo -e "${YELLOW}Execute primeiro: ./docker-build.sh${NC}"
    exit 1
fi

# Parar container existente se estiver rodando
if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
    echo -e "${YELLOW}Parando container existente: $CONTAINER_NAME${NC}"
    docker stop $CONTAINER_NAME
fi

if docker ps -aq -f name=$CONTAINER_NAME | grep -q .; then
    echo -e "${YELLOW}Removendo container existente: $CONTAINER_NAME${NC}"
    docker rm $CONTAINER_NAME
fi

# Executar container
echo -e "${GREEN}Iniciando Simulador DMA no Docker...${NC}"
echo -e "${YELLOW}Container: $CONTAINER_NAME${NC}"
echo -e "${YELLOW}Imagem: $IMAGE_NAME:$IMAGE_TAG${NC}"
echo
echo -e "${BLUE}======================================================================${NC}"
echo

# Executar de forma interativa
docker run -it --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_TAG

echo
echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}Container finalizado.${NC}"
echo -e "${YELLOW}Para executar novamente: ./docker-run.sh${NC}"
echo -e "${BLUE}======================================================================${NC}"
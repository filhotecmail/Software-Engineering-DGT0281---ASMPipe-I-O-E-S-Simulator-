#!/bin/bash
# Script para executar a Interface Gráfica do Simulador DMA
# Criado por um estudante de Engenharia de Software aprendendo DMA

echo "🚀 Iniciando Interface Gráfica do Simulador DMA..."
echo "📚 Criado por um estudante aprendendo sobre DMA!"
echo ""

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 não encontrado! Por favor, instale Python3."
    exit 1
fi

# Verificar se pip está instalado
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 não encontrado! Por favor, instale pip3."
    exit 1
fi

# Instalar dependências se necessário
echo "📦 Verificando dependências..."
if ! python3 -c "import colorama" 2>/dev/null; then
    echo "📥 Instalando colorama..."
    pip3 install colorama
fi

echo "✅ Dependências verificadas!"
echo ""

# Executar a interface gráfica
echo "🎮 Iniciando interface..."
python3 gui_dma_tester.py

echo ""
echo "👋 Obrigado por usar meu simulador DMA!"
echo "📚 Continue estudando Engenharia de Software! 🚀"
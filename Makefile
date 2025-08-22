# Makefile para ASMPipe I/O Simulator
# Compila o simulador de pipe em Assembly x86

# Configurações
ASM = nasm
LD = ld
ASM_FLAGS = -f elf32
LD_FLAGS = -m elf_i386

# Arquivos
SOURCE = asmpipe.asm
OBJECT = asmpipe.o
TARGET = asmpipe

# Regra padrão
all: $(TARGET)

# Compilar o executável
$(TARGET): $(OBJECT)
	@echo "Linkando $(TARGET)..."
	$(LD) $(LD_FLAGS) -o $(TARGET) $(OBJECT)
	@echo "Executável $(TARGET) criado com sucesso!"

# Compilar o objeto
$(OBJECT): $(SOURCE)
	@echo "Compilando $(SOURCE)..."
	$(ASM) $(ASM_FLAGS) $(SOURCE) -o $(OBJECT)

# Executar o simulador
run: $(TARGET)
	@echo "Executando ASMPipe I/O Simulator..."
	@echo "========================================"
	./$(TARGET)
	@echo "========================================"

# Limpar arquivos gerados
clean:
	@echo "Limpando arquivos gerados..."
	rm -f $(OBJECT) $(TARGET)
	@echo "Limpeza concluída!"

# Verificar dependências
check-deps:
	@echo "Verificando dependências..."
	@which $(ASM) > /dev/null || (echo "ERRO: NASM não encontrado. Instale com: sudo apt-get install nasm" && exit 1)
	@which $(LD) > /dev/null || (echo "ERRO: LD não encontrado. Instale build-essential" && exit 1)
	@echo "Todas as dependências estão instaladas!"

# Mostrar informações do projeto
info:
	@echo "ASMPipe I/O Simulator"
	@echo "====================="
	@echo "Simulador de pipe de E/S programável em Assembly x86"
	@echo ""
	@echo "Comandos disponíveis:"
	@echo "  make          - Compila o projeto"
	@echo "  make run      - Compila e executa o simulador"
	@echo "  make clean    - Remove arquivos gerados"
	@echo "  make check-deps - Verifica dependências"
	@echo "  make info     - Mostra estas informações"
	@echo ""
	@echo "Arquivos:"
	@echo "  $(SOURCE)     - Código fonte em Assembly"
	@echo "  $(OBJECT)     - Arquivo objeto"
	@echo "  $(TARGET)     - Executável final"

# Debug: compilar com símbolos de debug
debug: ASM_FLAGS += -g -F dwarf
debug: $(TARGET)
	@echo "Versão debug compilada com símbolos!"

# Instalar dependências (Ubuntu/Debian)
install-deps:
	@echo "Instalando dependências..."
	sudo apt-get update
	sudo apt-get install -y nasm build-essential
	@echo "Dependências instaladas!"

# Verificar sintaxe sem compilar
check-syntax:
	@echo "Verificando sintaxe do código Assembly..."
	$(ASM) $(ASM_FLAGS) $(SOURCE) -o /dev/null
	@echo "Sintaxe OK!"

.PHONY: all run clean check-deps info debug install-deps check-syntax
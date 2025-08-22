# ASMPipe I/O Simulator

ASMPipe I/O é um simulador de pipe de E/S (Entrada/Saída) programável de baixo nível, implementado em **Assembly x86**. Este projeto demonstra conceitos fundamentais de sistemas operacionais ao emular um pipe de comunicação entre dois processos simulados.

## 🚀 Características Implementadas

- **Buffer Circular**: Implementação de um buffer circular de 256 bytes para armazenamento eficiente
- **Operações de E/S**: Rotinas de leitura e escrita programáveis em Assembly
- **Controle de Fluxo**: Lógica de sincronização para evitar overflow e underflow
- **Gerenciamento de Memória**: Controle direto de ponteiros e memória
- **Tratamento de Erros**: Detecção de condições de buffer cheio e vazio

## 📋 Pré-requisitos

- **NASM** (Netwide Assembler)
- **GNU ld** (linker)
- **Sistema Linux** (testado em Ubuntu/Debian)

### Instalação das Dependências

```bash
# Instalar automaticamente
make install-deps

# Ou manualmente
sudo apt-get update
sudo apt-get install nasm build-essential
```

## 🔧 Compilação e Execução

### Comandos Disponíveis

```bash
# Verificar dependências
make check-deps

# Compilar o projeto
make

# Compilar e executar
make run

# Limpar arquivos gerados
make clean

# Mostrar informações do projeto
make info

# Compilar versão debug
make debug

# Verificar sintaxe
make check-syntax
```

### Execução Básica

```bash
# Compilar e executar o simulador
make run
```

**Saída esperada:**
```
ASMPipe I/O Simulator iniciado
Escrevendo dados no pipe...
Lendo dados do pipe...
Dados: Hello, ASMPipe!
```

## 🏗️ Arquitetura do Simulador

### Estrutura do Buffer Circular

```
┌─────────────────────────────────────────┐
│           Buffer Circular               │
│  ┌───┬───┬───┬───┬───┬───┬───┬───┐     │
│  │ A │ B │ C │   │   │   │   │   │     │
│  └───┴───┴───┴───┴───┴───┴───┴───┘     │
│    ↑           ↑                        │
│  read_ptr   write_ptr                   │
└─────────────────────────────────────────┘
```

### Componentes Principais

1. **Buffer Circular** (`pipe_buffer`): Array de 256 bytes
2. **Ponteiros de Controle**:
   - `read_ptr`: Posição atual de leitura
   - `write_ptr`: Posição atual de escrita
   - `data_count`: Contador de dados no buffer

### Funções Implementadas

#### `pipe_write(esi, ecx)`
- **Entrada**: ESI = ponteiro para dados, ECX = tamanho
- **Função**: Escreve dados no pipe
- **Retorno**: EAX = 0 (sucesso) ou -1 (erro)

#### `pipe_read(edi, ecx)`
- **Entrada**: EDI = buffer destino, ECX = tamanho máximo
- **Função**: Lê dados do pipe
- **Retorno**: EAX = bytes lidos

#### `get_pipe_status()`
- **Função**: Obtém status do pipe
- **Retorno**: EAX = dados disponíveis, EBX = espaço livre

#### `clear_pipe()`
- **Função**: Limpa o pipe (reset completo)

## 🧪 Testes e Demonstrações

### Cenários de Teste Implementados

1. **Operações Básicas**: Escrita e leitura simples
2. **Buffer Cheio**: Tentativa de escrita em buffer lotado
3. **Buffer Vazio**: Tentativa de leitura de buffer vazio
4. **Múltiplas Operações**: Várias escritas e leituras sequenciais

### Executar Testes

```bash
# Executar simulador básico
./asmpipe

# Para testes mais avançados (se implementado)
# ./demo
```

## 📊 Técnicas de E/S Demonstradas

### E/S Programada
O simulador implementa **E/S programada**, onde:
- O processador controla toda a transferência de dados
- Verificação ativa do status do buffer
- Controle direto de ponteiros e memória
- Sem uso de interrupções ou DMA

### Vantagens da Implementação
- **Controle Total**: Gerenciamento direto da memória
- **Educacional**: Demonstra conceitos fundamentais
- **Simplicidade**: Sem dependências de SO
- **Performance**: Acesso direto aos registradores

### Limitações
- **Polling**: Verificação ativa consome CPU
- **Bloqueante**: Operações são síncronas
- **Tamanho Fixo**: Buffer limitado a 256 bytes

## 🔍 Detalhes Técnicos

### Registradores Utilizados
- **EAX**: Valores de retorno e syscalls
- **EBX**: Parâmetros auxiliares
- **ECX**: Contadores e tamanhos
- **EDX**: Dados e parâmetros
- **ESI**: Ponteiro fonte (source)
- **EDI**: Ponteiro destino (destination)

### Syscalls Linux Utilizadas
- **sys_write (4)**: Saída para terminal
- **sys_exit (1)**: Finalização do programa

### Formato do Executável
- **Formato**: ELF32 (32-bit)
- **Arquitetura**: x86 (i386)
- **Seções**: .data, .bss, .text

## 📁 Estrutura do Projeto

```
ASMPipe-I-O-E-S-Simulator/
├── asmpipe.asm          # Código principal do simulador
├── demo.asm             # Demonstrações avançadas
├── Makefile             # Automação de build
├── README.md            # Esta documentação
└── LICENSE              # Licença do projeto
```

## 🐛 Tratamento de Erros

### Condições de Erro
1. **Buffer Cheio**: Tentativa de escrita quando `data_count == BUFFER_SIZE`
2. **Buffer Vazio**: Tentativa de leitura quando `data_count == 0`
3. **Parâmetros Inválidos**: Ponteiros nulos ou tamanhos inválidos

### Mensagens de Erro
- `"ERRO: Pipe cheio!"`: Buffer não tem espaço
- `"ERRO: Pipe vazio!"`: Não há dados para ler

## 🎯 Objetivos Educacionais

Este projeto demonstra:
- **Programação em Assembly**: Sintaxe e estruturas x86
- **Gerenciamento de Memória**: Ponteiros e buffers
- **Algoritmos Circulares**: Implementação de buffer circular
- **Sincronização**: Controle de acesso a recursos compartilhados
- **E/S de Baixo Nível**: Operações sem abstração do SO
- **Debugging**: Técnicas de depuração em Assembly

## 📚 Referências

- William Stallings, "Arquitetura e Organização de Computadores", 10ª edição
- Intel 64 and IA-32 Architectures Software Developer's Manual
- Linux System Call Interface
- NASM Documentation

## 🤝 Contribuições

Contribuições são bem-vindas! Áreas de melhoria:
- Implementação de DMA simulado
- Suporte a interrupções
- Interface gráfica simples
- Testes automatizados
- Documentação adicional

## 📄 Licença

Este projeto está licenciado sob os termos especificados no arquivo LICENSE.

---

**Desenvolvido para fins educacionais - Engenharia de Software DGT0281**


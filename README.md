# ASMPipe I/O

ASMPipe I/O é um simulador de pipe de E/S (Entrada/Saída) programável de baixo nível, implementado em **Assembly x86**. Este projeto demonstra conceitos fundamentais de sistemas operacionais e arquitetura de computadores.

## 📖 Conceitos Teóricos

### E/S Programada

Na E/S programada, o processador executa um programa que oferece controle direto sobre a operação de E/S, incluindo a detecção do estado do dispositivo, o envio de comandos de leitura ou escrita e a transferência dos dados. Quando o processador emite um comando para o módulo de E/S, ele é incumbido de inspecionar periodicamente o estado do módulo de E/S, consultando seus registradores de estado até determinar que a operação foi finalizada. A característica central da E/S programada é que o processador não é interrompido; ele mesmo deve verificar o status.

### Comandos de E/S

Para iniciar uma operação de E/S, o processador envia um comando ao módulo de E/S e a um dispositivo externo, especificando-o por meio de um endereço. Os comandos são tipicamente categorizados em quatro funções básicas:

* **Controle:** Utilizado para ativar o periférico e instruí-lo a realizar uma tarefa específica. Exemplos incluem o comando para rebobinar uma fita magnética ou avançar o registro de dados. A funcionalidade exata depende do tipo de dispositivo.
* **Teste:** Usado para examinar as condições do módulo de E/S ou do periférico, como a disponibilidade para uso e a detecção de erros. O processador precisa confirmar que o periférico está pronto antes de prosseguir.
* **Leitura:** O módulo de E/S adquire um item de dados do periférico e o armazena em um buffer interno (geralmente um registrador de dados). O processador pode então obter este item, solicitando a leitura do registrador do módulo.
* **Escrita:** O processador fornece um item de dados (byte ou palavra) ao módulo de E/S. O módulo então o transmite do seu registrador de dados para o periférico.

Em um cenário típico de E/S programada, o processador deve emitir uma instrução de verificação de estado para cada palavra de dados transferida. Esta necessidade de uma espera ativa (loop de verificação de estado) a cada transferência de palavra é a principal desvantagem dessa técnica, pois mantém o processador ocupado desnecessariamente.

<img width="745" height="506" alt="image" src="https://github.com/user-attachments/assets/c85bea54-5df3-44da-b893-2a0d93e3d8d4" />

*Referência: William Stallings, "Arquitetura e Organização de Computadores", 10ª edição.*

## 🚀 Implementação - Características

### Versão Original
- **Buffer Circular**: Implementação de um buffer circular de 256 bytes para armazenamento eficiente
- **Operações de E/S**: Rotinas de leitura e escrita programáveis em Assembly
- **Controle de Fluxo**: Lógica de sincronização para evitar overflow e underflow
- **Gerenciamento de Memória**: Controle direto de ponteiros e memória
- **Tratamento de Erros**: Detecção de condições de buffer cheio e vazio

### 🆕 Versão com DMA (Direct Memory Access)
- **Controlador DMA**: Sistema completo com 4 canais independentes
- **Arbitragem de Barramento**: Resolução automática de conflitos entre canais
- **Transferências Otimizadas**: Modo burst para grandes volumes de dados
- **Sistema de Prioridades**: 4 níveis de prioridade configuráveis (0-3)
- **Comparação de Performance**: DMA vs E/S Programada com métricas detalhadas
- **Monitoramento Avançado**: Estatísticas de conflitos, ciclos e otimizações

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

#### Versão Original
```bash
# Verificar dependências
make check-deps

# Compilar versão original
make original

# Executar versão original
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

#### 🆕 Versão com DMA
```bash
# Compilar versão DMA
make dma

# Executar versão DMA
make run-dma

# Comparar ambas as versões
make run-both

# Teste de performance DMA
make performance-test

# Compilar ambas as versões
make all
```

### Execução Básica

#### Versão Original
```bash
# Compilar e executar o simulador original
make run
```

**Saída esperada:**
```
ASMPipe I/O Simulator iniciado
Escrevendo dados no pipe...
Lendo dados do pipe...
Dados: Hello, ASMPipe!
```

#### 🆕 Versão DMA
```bash
# Compilar e executar versão DMA
make run-dma
```

**Saída esperada:**
```
ASMPipe + DMA System inicializado
DMA Controller inicializado

Transferência DMA iniciada no canal 0
Transferência DMA completada

Iniciando teste de performance...
Teste E/S Programada: 3072 ciclos
Teste DMA: 1024 ciclos
Comparação de Performance: DMA é mais eficiente!

Conflito de barramento detectado
Arbitragem de barramento em progresso
```

#### Comparação entre Versões
```bash
# Executar ambas para comparação
make run-both
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

## 🏗️ Arquitetura DMA

### Estrutura do Sistema DMA

```
┌─────────────────────────────────────────────────────────────┐
│                    Controlador DMA                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐          │
│  │ Canal 0 │ │ Canal 1 │ │ Canal 2 │ │ Canal 3 │          │
│  │ Pri: 0  │ │ Pri: 1  │ │ Pri: 2  │ │ Pri: 3  │          │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘          │
│                           │                                │
│  ┌─────────────────────────┼─────────────────────────────┐  │
│  │        Arbitragem de Barramento                      │  │
│  │  • Resolução de conflitos                           │  │
│  │  • Sistema de prioridades                           │  │
│  │  • Fila de requisições                              │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Barramento do Sistema                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   Memória   │◄──►│     CPU     │◄──►│ Dispositivos│    │
│  │             │    │             │    │     E/S     │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Componentes DMA

#### Canais DMA
- **4 Canais Independentes**: Cada canal pode operar simultaneamente
- **Registradores por Canal**: Endereço origem, destino, tamanho, controle
- **Estados**: IDLE, ACTIVE, COMPLETED, ERROR
- **Tipos de Transferência**: Memory-to-Memory, Memory-to-Device, Device-to-Memory

#### Sistema de Arbitragem
- **Prioridades**: 4 níveis (0=máxima, 3=mínima)
- **Resolução de Conflitos**: Automática baseada em prioridade
- **Fila de Requisições**: Gerenciamento de múltiplas solicitações
- **Estatísticas**: Contadores de conflitos e ciclos de arbitragem

## 🧪 Testes e Demonstrações

### Cenários de Teste - Versão Original

1. **Operações Básicas**: Escrita e leitura simples
2. **Buffer Cheio**: Tentativa de escrita em buffer lotado
3. **Buffer Vazio**: Tentativa de leitura de buffer vazio
4. **Múltiplas Operações**: Várias escritas e leituras sequenciais

### 🆕 Cenários de Teste - Versão DMA

1. **Transferências Básicas**: Diferentes tamanhos (pequeno, médio, grande)
2. **Arbitragem de Barramento**: Conflitos entre múltiplos canais
3. **Comparação de Performance**: DMA vs E/S Programada
4. **Transferências em Burst**: Otimização para grandes volumes
5. **Sistema de Prioridades**: Resolução baseada em prioridade
6. **Estatísticas Avançadas**: Monitoramento de performance

### Executar Testes

```bash
# Executar simulador básico
./asmpipe

# Executar versão DMA
./asmpipe_dma

# Teste de performance automatizado
make performance-test

# Comparação completa
make run-both
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

### Arquivos Principais

#### Versão Original
- `asmpipe.asm` - Implementação principal do simulador
- `Makefile` - Automação de compilação e execução
- `README.md` - Documentação principal

#### 🆕 Arquivos DMA
- `dma_controller.asm` - Controlador DMA básico com 4 canais
- `dma_advanced.asm` - Funcionalidades avançadas (arbitragem, burst, prioridades)
- `asmpipe_dma.asm` - Integração completa DMA + ASMPipe
- `DMA_DOCUMENTATION.md` - Documentação detalhada do sistema DMA
- `ISSUES_TEMPLATE.md` - Template para futuras melhorias

### Executáveis Gerados
- `asmpipe` - Versão original do simulador
- `asmpipe_dma` - Versão com funcionalidades DMA

## 📚 Documentação Adicional

- **[DMA_DOCUMENTATION.md](DMA_DOCUMENTATION.md)** - Documentação completa do sistema DMA
- **[ISSUES_TEMPLATE.md](ISSUES_TEMPLATE.md)** - Template para contribuições e melhorias

## 🚀 Próximos Passos

Para futuras melhorias, consulte os issues criados:
1. **Suporte a Interrupções** - Sistema de interrupções simulado
2. **Interface Gráfica** - Visualização em tempo real do buffer e DMA
3. **Testes Automatizados** - Suite completa de testes
4. **Documentação Expandida** - Tutoriais e exemplos avançados

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


# Software-Engineering-DGT0281---ASMPipe-I-O-E-S-Simulator-
# ASMPipe I/O

ASMPipe I/O é um simulador de pipe de E/S (Entrada/Saída) programável de baixo nível, implementado em **Assembly x86**. Este projeto demonstra conceitos fundamentais de sistemas operacionais ao emular um pipe de comunicação entre dois processos simulados. Ele apresenta um **buffer circular** para armazenamento de dados e rotinas personalizadas para leitura e escrita no pipe, exibindo o gerenciamento direto de memória e primitivas de sincronização simples. O foco principal é na **E/S programável**, onde toda a lógica de transferência de dados é implementada manualmente no nível "bare-metal", sem depender de chamadas de sistema de alto nível ou de um kernel de sistema operacional existente.

## Sobre o Projeto

O ASMPipe é um projeto educacional projetado para explorar a mecânica da **comunicação entre processos (IPC)** e da **E/S programável** a partir do zero. Desenvolvido inteiramente em Assembly x86, este simulador oferece uma visão prática de como funciona um pipe de comunicação clássico.

O objetivo principal do projeto é contornar as abstrações de um sistema operacional tradicional e implementar toda a lógica de E/S manualmente. Isso inclui:

### Principais Características

* **Gerenciamento de Memória Personalizado:** Um buffer circular é usado como o núcleo do pipe, com ponteiros dedicados para lidar com as operações de leitura e escrita.
* **Lógica de Transferência de Dados:** Rotinas codificadas manualmente para escrever bytes no buffer e lê-los, demonstrando controle direto sobre o movimento de dados no nível de registradores e memória.
* **Controle de Fluxo:** O simulador inclui uma lógica de sincronização simples para evitar a sobrescrita de dados (escrever em um pipe cheio) e a leitura de dados inexistentes (ler de um pipe vazio).

Ao focar na E/S programável, o ASMPipe oferece percepções profundas sobre a arquitetura de um computador e os princípios fundamentais sobre os quais os sistemas operacionais modernos são construídos. É um recurso perfeito para estudantes e entusiastas que desejam dominar a programação de baixo nível e entender o verdadeiro significado de "entrada/saída".

<img width="512" height="512" alt="image" src="https://github.com/user-attachments/assets/43ce728a-f74a-4453-b1b3-7aa50d9bfa87" />

# Técnicas de Gerenciamento de E/S

O gerenciamento de operações de E/S pode ser realizado de três maneiras distintas. A **E/S programada** é o método mais direto, onde o processador se encarrega de todo o processo. Ele executa instruções para verificar o status do dispositivo, emitir comandos e transferir os dados. No entanto, o processador fica inativo enquanto aguarda o módulo de E/S, o que pode levar a um desperdício de ciclos se o dispositivo periférico for significativamente mais lento.

Para evitar essa ociosidade, a **E/S controlada por interrupção** permite que o processador inicie uma operação de E/S e retome imediatamente suas tarefas. O módulo de E/S notifica o processador com um sinal de interrupção somente quando a operação foi finalizada, permitindo um uso mais eficiente dos recursos do sistema.

A técnica mais avançada é o **acesso direto à memória (DMA)**. Diferente das outras, o DMA permite que a transferência de dados entre um módulo de E/S e a memória principal ocorra sem a participação do processador. Isso libera o processador para realizar outras atividades, resultando em um desempenho superior, especialmente em grandes transferências de dados.

Essas técnicas podem ser categorizadas com base na participação do processador e no uso de interrupções, conforme ilustrado na tabela abaixo.

### Tabela: Métodos de Entrada e Saída

| | **Não Interrompível** | **Com Interrupção** |
| :--- | :--- | :--- |
| **Transferência Intermediada pelo Processador** | E/S programada | E/S controlada por interrupção |
| **Transferência Direta (sem Processador)** | | Acesso direto à memória (DMA) |



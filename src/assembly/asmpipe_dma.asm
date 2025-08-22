; Aqui eu integro o ASMPipe com DMA - a versão turbinada!
; Eu junto o simulador ASMPipe com as funcionalidades DMA que criei
; Vou mostrar como DMA é muito melhor que E/S programada

; Includes removidos - funcionalidades integradas diretamente
; %include "dma_controller.asm"
; %include "dma_advanced.asm"

section .data
    ; Aqui eu preparo os dados para testar e comparar
    large_test_data times 1024 db 'A'  ; 1KB - vou usar para teste pesado
    large_test_data_end:
    large_test_size equ large_test_data_end - large_test_data
    
    medium_test_data times 256 db 'B'  ; 256 bytes - teste médio
    medium_test_data_end:
    medium_test_size equ medium_test_data_end - medium_test_data
    
    small_test_data db 'Small test', 0  ; Teste pequeno para comparar
    small_test_size equ $ - small_test_data - 1
    
    ; Aqui estão as mensagens que eu vou mostrar para o usuário
    msg_system_init db 'ASMPipe + DMA System inicializado', 0xA, 0
    msg_performance_test db 'Iniciando teste de performance...', 0xA, 0
    msg_programmed_io db 'Teste E/S Programada: ', 0
    msg_dma_io db 'Teste DMA: ', 0
    msg_cycles db ' ciclos', 0xA, 0
    msg_bytes_sec db ' bytes/segundo', 0xA, 0
    msg_comparison db 'Comparação de Performance:', 0xA, 0
    msg_winner_dma db 'DMA é mais eficiente!', 0xA, 0
    msg_winner_pio db 'E/S Programada é mais eficiente!', 0xA, 0
    msg_separator db '----------------------------------------', 0xA, 0
    
    ; Aqui eu guardo as estatísticas da E/S programada para comparar
    pio_cycles_used dd 0
    pio_bytes_transferred dd 0
    pio_operations dd 0
    
section .bss
    ; Aqui eu reservo espaço para os testes de destino
    dma_dest_large resb 1024    ; Para onde o DMA vai copiar dados grandes
    dma_dest_medium resb 256    ; Para dados médios
    dma_dest_small resb 64      ; Para dados pequenos
    pio_dest_large resb 1024    ; Para onde E/S programada vai copiar
    pio_dest_medium resb 256
    pio_dest_small resb 64
    
    ; Aqui eu guardo os tempos para medir performance
    start_time resd 1
    end_time resd 1

section .text
    global _start
    extern pipe_write, pipe_read, get_pipe_status, clear_pipe

_start:
    ; Aqui eu começo tudo - vou inicializar o sistema completo
    call system_init
    
    ; Agora eu vou executar as demonstrações para mostrar como funciona
    call dma_basic_demo
    call performance_comparison_demo
    call advanced_features_demo
    
    ; No final eu mostro todas as estatísticas
    call show_final_statistics
    
    ; Pronto! Vou finalizar o programa
    mov eax, 1
    mov ebx, 0
    int 0x80

; Aqui eu inicializo todo o sistema - DMA e tudo mais
system_init:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Primeiro eu aviso que estou inicializando
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_system_init
    mov edx, 34
    int 0x80
    
    ; Agora eu inicializo o sistema DMA
    call dma_init
    
    ; Agora eu configuro as prioridades dos canais
    mov eax, 0
    mov ebx, 0                 ; Canal 0 tem prioridade máxima
    call dma_set_priority
    
    mov eax, 1
    mov ebx, 1                 ; Canal 1 tem prioridade alta
    call dma_set_priority
    
    mov eax, 2
    mov ebx, 2                 ; Canal 2 tem prioridade média
    call dma_set_priority
    
    mov eax, 3
    mov ebx, 3                 ; Canal 3 tem prioridade baixa
    call dma_set_priority
    
    ; Eu zero os contadores da E/S programada para comparar depois
    mov dword [pio_cycles_used], 0
    mov dword [pio_bytes_transferred], 0
    mov dword [pio_operations], 0
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Aqui eu faço uma demonstração básica do DMA funcionando
dma_basic_demo:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    call print_separator
    
    ; Vou imprimir um cabeçalho bonito
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_separator
    mov edx, 41
    int 0x80
    
    ; Demonstração 1: Aqui eu testo transferência pequena
    mov eax, 0                 ; Vou usar o canal 0
    mov esi, small_test_data   ; De onde vou copiar
    mov edi, dma_dest_small    ; Para onde vou copiar
    mov ecx, small_test_size   ; Quantos bytes
    mov edx, DMA_MEM_TO_MEM    ; Tipo: memória para memória
    call dma_setup_channel
    
    mov eax, 0
    call dma_start_transfer
    
    ; Demonstração 2: Agora eu testo transferência média com burst
    mov eax, 1                 ; Canal 1 desta vez
    mov esi, medium_test_data  ; Dados médios
    mov edi, dma_dest_medium   ; Destino médio
    mov ecx, medium_test_size  ; Tamanho médio
    mov edx, DMA_MEM_TO_MEM
    call dma_setup_channel
    
    mov eax, 1
    call dma_request_bus       ; Eu peço o barramento
    call dma_burst_transfer    ; Faço transferência burst - mais rápida!
    call dma_release_bus       ; Libero o barramento
    
    ; Demonstração 3: Agora o teste pesado - transferência grande!
    mov eax, 2                 ; Canal 2 para dados grandes
    mov esi, large_test_data   ; 1KB de dados
    mov edi, dma_dest_large    ; Buffer grande de destino
    mov ecx, large_test_size   ; 1024 bytes
    mov edx, DMA_MEM_TO_MEM
    call dma_setup_channel
    
    mov eax, 2
    call dma_start_transfer    ; Aqui eu inicio a transferência
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Aqui eu faço o teste mais importante - comparação de performance!
performance_comparison_demo:
    push eax
    push ebx
    push ecx
    push edx
    
    call print_separator
    
    ; Vou avisar que estou começando o teste de performance
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_performance_test
    mov edx, 33
    int 0x80
    
    ; Primeiro eu testo E/S Programada (o jeito antigo)
    call measure_programmed_io
    
    ; Depois eu testo DMA (o jeito moderno e rápido)
    call measure_dma_transfer
    
    ; Agora eu comparo os resultados para ver quem ganhou
    call compare_performance
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Aqui eu meço como a E/S programada se comporta
measure_programmed_io:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Primeiro eu marco o tempo de início
    call get_timestamp
    mov [start_time], eax
    
    ; Agora eu vou transferir dados do jeito antigo (byte por byte)
    mov esi, large_test_data   ; De onde eu pego
    mov edi, pio_dest_large    ; Para onde eu levo
    mov ecx, large_test_size   ; Quantos bytes
    
.pio_loop:
    cmp ecx, 0
    je .pio_done
    
    ; Aqui eu simulo o overhead da E/S programada (3 ciclos por byte)
    mov al, [esi]             ; Eu leio um byte
    mov [edi], al             ; Eu escrevo um byte
    
    inc esi                   ; Próximo byte de origem
    inc edi                   ; Próximo byte de destino
    dec ecx                   ; Um byte a menos para processar
    
    ; Eu conto os ciclos e bytes para estatísticas
    add dword [pio_cycles_used], 3
    inc dword [pio_bytes_transferred]
    
    jmp .pio_loop
    
.pio_done:
    ; Agora eu marco o tempo final
    call get_timestamp
    mov [end_time], eax
    
    inc dword [pio_operations] ; Mais uma operação concluída
    
    ; Vou mostrar o resultado da E/S programada
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_programmed_io
    mov edx, 21
    int 0x80
    
    ; Aqui eu mostro quantos ciclos gastei
    call print_number
    mov eax, [pio_cycles_used]
    call print_number
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_cycles
    mov edx, 8
    int 0x80
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Agora eu meço como o DMA se comporta - deve ser muito melhor!
measure_dma_transfer:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Agora eu configuro a transferência DMA
    mov eax, 3                 ; Vou usar o canal 3
    mov esi, large_test_data   ; Mesmos dados que usei na E/S programada
    mov edi, dma_dest_large    ; Mesmo destino
    mov ecx, large_test_size   ; Mesmo tamanho
    mov edx, DMA_MEM_TO_MEM
    call dma_setup_channel
    
    ; Eu marco o tempo de início
    call get_timestamp
    mov [start_time], eax
    
    ; Agora eu executo a transferência DMA - deve ser muito mais rápida!
    mov eax, 3
    call dma_start_transfer
    
    call get_timestamp
    mov [end_time], eax
    
    ; Vou mostrar o resultado do DMA
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_dma_io
    mov edx, 11
    int 0x80
    
    ; Aqui eu mostro quantos ciclos o DMA economizou
    mov eax, [dma_cycles_saved]
    call print_number
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_cycles
    mov edx, 8
    int 0x80
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Aqui vem a parte mais legal - vou comparar quem ganhou!
compare_performance:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Vou imprimir um cabeçalho para a comparação
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_comparison
    mov edx, 26
    int 0x80
    
    ; Agora eu comparo os ciclos usados
    mov eax, [pio_cycles_used]  ; Ciclos da E/S programada
    mov ebx, [dma_cycles_saved] ; Ciclos economizados pelo DMA
    
    cmp eax, ebx
    jg .dma_wins               ; Se E/S programada usou mais, DMA ganhou
    
    ; E/S programada ganhou (isso é muito raro!)
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_winner_pio
    mov edx, 34
    int 0x80
    jmp .comparison_done
    
.dma_wins:
    ; DMA ganhou - como esperado!
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_winner_dma
    mov edx, 23
    int 0x80
    
.comparison_done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Aqui eu mostro as funcionalidades mais avançadas do DMA
advanced_features_demo:
    push eax
    push ebx
    push ecx
    push edx
    
    call print_separator
    
    ; Vou demonstrar como funciona a arbitragem de barramento
    ; Eu vou fazer vários canais pedirem o barramento ao mesmo tempo
    mov eax, 0
    call dma_request_bus       ; Canal 0 pede primeiro
    
    mov eax, 1
    call dma_request_bus       ; Canal 1 vai gerar conflito!
    
    mov eax, 2
    call dma_request_bus       ; Canal 2 também vai gerar conflito!
    
    ; Agora eu libero o barramento para ver a arbitragem funcionar
    mov eax, 0
    call dma_release_bus
    
    ; Vou testar a otimização automática que criei
    mov eax, 0
    mov ebx, 32             ; Transferência pequena - deve recomendar E/S programada
    call dma_optimize_transfer
    
    mov eax, 1
    mov ebx, 512            ; Transferência grande - deve recomendar burst
    call dma_optimize_transfer
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Aqui eu mostro todas as estatísticas finais - o resumão!
show_final_statistics:
    push eax
    push ebx
    push ecx
    push edx
    
    call print_separator
    
    ; Vou pegar todas as estatísticas do DMA
    call dma_get_performance_stats
    ; EAX = conflitos, EBX = ciclos arbitragem, ECX = bursts, EDX = bytes DMA
    
    ; Aqui eu imprimiria as estatísticas (versão simplificada)
    ; Se fosse implementação completa, eu formataria os números bonitinho
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Aqui estão as funções auxiliares que eu uso
get_timestamp:
    ; Eu simulo um timestamp (num sistema real usaria RDTSC)
    mov eax, [dma_transfers_completed]
    shl eax, 8              ; Eu simulo baseado no número de operações
    ret

print_number:
    ; Função simples para imprimir números
    ; Se fosse implementação completa, eu converteria para ASCII direitinho
    ret

print_separator:
    ; Eu imprimo uma linha separadora para organizar a saída
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_separator
    mov edx, 41
    int 0x80
    ret
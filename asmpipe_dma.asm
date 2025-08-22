; ASMPipe with DMA Integration
; Integração do simulador ASMPipe com funcionalidades DMA
; Demonstra comparação entre E/S programada e DMA

%include "dma_controller.asm"
%include "dma_advanced.asm"

section .data
    ; Dados para testes comparativos
    large_test_data times 1024 db 'A'  ; 1KB de dados para teste
    large_test_data_end:
    large_test_size equ large_test_data_end - large_test_data
    
    medium_test_data times 256 db 'B'  ; 256 bytes
    medium_test_data_end:
    medium_test_size equ medium_test_data_end - medium_test_data
    
    small_test_data db 'Small test', 0
    small_test_size equ $ - small_test_data - 1
    
    ; Mensagens do sistema integrado
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
    
    ; Contadores de performance para E/S programada
    pio_cycles_used dd 0
    pio_bytes_transferred dd 0
    pio_operations dd 0
    
section .bss
    ; Buffers para testes
    dma_dest_large resb 1024
    dma_dest_medium resb 256
    dma_dest_small resb 64
    pio_dest_large resb 1024
    pio_dest_medium resb 256
    pio_dest_small resb 64
    
    ; Buffer para medição de tempo
    start_time resd 1
    end_time resd 1

section .text
    global _start
    extern pipe_write, pipe_read, get_pipe_status, clear_pipe

_start:
    ; Inicializar sistema completo
    call system_init
    
    ; Executar demonstrações
    call dma_basic_demo
    call performance_comparison_demo
    call advanced_features_demo
    
    ; Mostrar estatísticas finais
    call show_final_statistics
    
    ; Finalizar programa
    mov eax, 1
    mov ebx, 0
    int 0x80

; Função para inicializar o sistema completo
system_init:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Imprimir mensagem de inicialização
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_system_init
    mov edx, 34
    int 0x80
    
    ; Inicializar DMA
    call dma_init
    
    ; Configurar prioridades dos canais
    mov eax, 0
    mov ebx, 0                 ; Prioridade máxima
    call dma_set_priority
    
    mov eax, 1
    mov ebx, 1
    call dma_set_priority
    
    mov eax, 2
    mov ebx, 2
    call dma_set_priority
    
    mov eax, 3
    mov ebx, 3                 ; Prioridade mínima
    call dma_set_priority
    
    ; Resetar contadores de E/S programada
    mov dword [pio_cycles_used], 0
    mov dword [pio_bytes_transferred], 0
    mov dword [pio_operations], 0
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Demonstração básica do DMA
dma_basic_demo:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    call print_separator
    
    ; Imprimir cabeçalho
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_separator
    mov edx, 41
    int 0x80
    
    ; Demonstração 1: Transferência pequena
    mov eax, 0
    mov esi, small_test_data
    mov edi, dma_dest_small
    mov ecx, small_test_size
    mov edx, DMA_MEM_TO_MEM
    call dma_setup_channel
    
    mov eax, 0
    call dma_start_transfer
    
    ; Demonstração 2: Transferência média com burst
    mov eax, 1
    mov esi, medium_test_data
    mov edi, dma_dest_medium
    mov ecx, medium_test_size
    mov edx, DMA_MEM_TO_MEM
    call dma_setup_channel
    
    mov eax, 1
    call dma_request_bus
    call dma_burst_transfer
    call dma_release_bus
    
    ; Demonstração 3: Transferência grande
    mov eax, 2
    mov esi, large_test_data
    mov edi, dma_dest_large
    mov ecx, large_test_size
    mov edx, DMA_MEM_TO_MEM
    call dma_setup_channel
    
    mov eax, 2
    call dma_start_transfer
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Demonstração de comparação de performance
performance_comparison_demo:
    push eax
    push ebx
    push ecx
    push edx
    
    call print_separator
    
    ; Imprimir cabeçalho
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_performance_test
    mov edx, 33
    int 0x80
    
    ; Teste 1: E/S Programada
    call measure_programmed_io
    
    ; Teste 2: DMA
    call measure_dma_transfer
    
    ; Comparar resultados
    call compare_performance
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Medir performance da E/S programada
measure_programmed_io:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Simular medição de tempo (início)
    call get_timestamp
    mov [start_time], eax
    
    ; Transferir dados usando E/S programada (simulação)
    mov esi, large_test_data
    mov edi, pio_dest_large
    mov ecx, large_test_size
    
.pio_loop:
    cmp ecx, 0
    je .pio_done
    
    ; Simular overhead de E/S programada (3 ciclos por byte)
    mov al, [esi]
    mov [edi], al
    
    inc esi
    inc edi
    dec ecx
    
    ; Incrementar contadores
    add dword [pio_cycles_used], 3
    inc dword [pio_bytes_transferred]
    
    jmp .pio_loop
    
.pio_done:
    ; Medir tempo final
    call get_timestamp
    mov [end_time], eax
    
    inc dword [pio_operations]
    
    ; Imprimir resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_programmed_io
    mov edx, 21
    int 0x80
    
    ; Imprimir ciclos usados
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

; Medir performance do DMA
measure_dma_transfer:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Configurar transferência DMA
    mov eax, 3
    mov esi, large_test_data
    mov edi, dma_dest_large
    mov ecx, large_test_size
    mov edx, DMA_MEM_TO_MEM
    call dma_setup_channel
    
    ; Medir tempo
    call get_timestamp
    mov [start_time], eax
    
    ; Executar transferência DMA
    mov eax, 3
    call dma_start_transfer
    
    call get_timestamp
    mov [end_time], eax
    
    ; Imprimir resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_dma_io
    mov edx, 11
    int 0x80
    
    ; Obter ciclos salvos pelo DMA
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

; Comparar performance entre DMA e E/S programada
compare_performance:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Imprimir cabeçalho de comparação
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_comparison
    mov edx, 26
    int 0x80
    
    ; Comparar ciclos
    mov eax, [pio_cycles_used]
    mov ebx, [dma_cycles_saved]
    
    cmp eax, ebx
    jg .dma_wins
    
    ; E/S programada é mais eficiente (caso raro)
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_winner_pio
    mov edx, 34
    int 0x80
    jmp .comparison_done
    
.dma_wins:
    ; DMA é mais eficiente
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

; Demonstração de funcionalidades avançadas
advanced_features_demo:
    push eax
    push ebx
    push ecx
    push edx
    
    call print_separator
    
    ; Demonstrar arbitragem de barramento
    ; Configurar múltiplos canais simultaneamente
    mov eax, 0
    call dma_request_bus
    
    mov eax, 1
    call dma_request_bus    ; Deve gerar conflito
    
    mov eax, 2
    call dma_request_bus    ; Deve gerar conflito
    
    ; Liberar barramento
    mov eax, 0
    call dma_release_bus
    
    ; Testar otimização automática
    mov eax, 0
    mov ebx, 32             ; Transferência pequena
    call dma_optimize_transfer
    
    mov eax, 1
    mov ebx, 512            ; Transferência grande
    call dma_optimize_transfer
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Mostrar estatísticas finais
show_final_statistics:
    push eax
    push ebx
    push ecx
    push edx
    
    call print_separator
    
    ; Obter estatísticas do DMA
    call dma_get_performance_stats
    ; EAX = conflitos, EBX = ciclos arbitragem, ECX = bursts, EDX = bytes DMA
    
    ; Imprimir estatísticas (implementação simplificada)
    ; Em uma implementação completa, formataria os números adequadamente
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Funções auxiliares
get_timestamp:
    ; Simulação de timestamp (em um sistema real usaria RDTSC)
    mov eax, [dma_transfers_completed]
    shl eax, 8              ; Simular timestamp baseado em operações
    ret

print_number:
    ; Função simplificada para imprimir números
    ; Em uma implementação completa, converteria para ASCII
    ret

print_separator:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_separator
    mov edx, 41
    int 0x80
    ret
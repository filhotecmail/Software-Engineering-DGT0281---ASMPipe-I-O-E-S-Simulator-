; DMA Advanced Features
; Funcionalidades avançadas do controlador DMA
; Inclui arbitragem de barramento, controle de prioridade e otimizações

section .data
    ; Configurações avançadas
    DMA_BURST_SIZE equ 8       ; Tamanho do burst (bytes por ciclo)
    DMA_MAX_PRIORITY equ 3     ; Prioridade máxima
    DMA_ARBITRATION_CYCLES equ 4 ; Ciclos para arbitragem
    
    ; Estados de arbitragem
    ARB_IDLE equ 0
    ARB_REQUESTING equ 1
    ARB_GRANTED equ 2
    ARB_BUSY equ 3
    
    ; Tabela de prioridades dos canais (0 = maior prioridade)
    channel_priorities db 0, 1, 2, 3  ; Canal 0 tem maior prioridade
    
    ; Estado do barramento
    bus_owner dd -1            ; Canal que possui o barramento (-1 = livre)
    bus_arbitration_state dd ARB_IDLE
    bus_request_mask dd 0      ; Máscara de requisições pendentes
    
    ; Contadores de performance avançados
    bus_conflicts dd 0         ; Conflitos de barramento
    arbitration_cycles dd 0    ; Ciclos gastos em arbitragem
    burst_transfers dd 0       ; Transferências em burst
    
    ; Mensagens avançadas
    msg_bus_granted db 'Barramento concedido ao canal ', 0
    msg_bus_conflict db 'Conflito de barramento detectado', 0xA, 0
    msg_burst_start db 'Iniciando transferência burst', 0xA, 0
    msg_arbitration db 'Arbitragem de barramento em progresso', 0xA, 0
    
section .bss
    ; Buffers para transferências burst
    burst_buffer resb DMA_BURST_SIZE
    temp_priority_list resb DMA_CHANNELS

section .text
    ; Exportar funções avançadas
    global dma_request_bus
    global dma_release_bus
    global dma_arbitrate_bus
    global dma_burst_transfer
    global dma_set_priority
    global dma_get_performance_stats
    global dma_optimize_transfer

; Função para requisitar acesso ao barramento
; Entrada: EAX = canal
; Saída: EAX = 0 (sucesso), -1 (erro)
dma_request_bus:
    push ebx
    push ecx
    
    ; Verificar canal válido
    cmp eax, DMA_CHANNELS
    jge .invalid_channel_req
    
    ; Verificar se o barramento está livre
    mov ebx, [bus_owner]
    cmp ebx, -1
    je .grant_immediately
    
    ; Barramento ocupado - adicionar à fila de requisições
    mov ecx, 1
    mov edx, eax
    and edx, 0xFF              ; Garantir que só usamos os 8 bits baixos
    shl ecx, cl                ; Criar máscara para o canal
    or [bus_request_mask], ecx ; Adicionar requisição
    
    ; Incrementar contador de conflitos
    inc dword [bus_conflicts]
    
    ; Imprimir mensagem de conflito
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bus_conflict
    mov edx, 32
    int 0x80
    pop eax
    
    ; Iniciar processo de arbitragem
    call dma_arbitrate_bus
    
    mov eax, 1                 ; Requisição pendente
    jmp .request_exit
    
.grant_immediately:
    ; Conceder barramento imediatamente
    mov [bus_owner], eax
    mov dword [bus_arbitration_state], ARB_GRANTED
    
    ; Imprimir mensagem
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bus_granted
    mov edx, 30
    int 0x80
    pop eax
    
    ; Imprimir número do canal
    push eax
    add eax, '0'
    mov [msg_channel_num], al
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_channel_num
    mov edx, 2
    int 0x80
    pop eax
    
    mov eax, 0                 ; Sucesso
    jmp .request_exit
    
.invalid_channel_req:
    mov eax, -1                ; Erro
    
.request_exit:
    pop ecx
    pop ebx
    ret

; Função para liberar o barramento
; Entrada: EAX = canal
dma_release_bus:
    push ebx
    push ecx
    
    ; Verificar se o canal possui o barramento
    mov ebx, [bus_owner]
    cmp ebx, eax
    jne .not_owner
    
    ; Liberar barramento
    mov dword [bus_owner], -1
    mov dword [bus_arbitration_state], ARB_IDLE
    
    ; Verificar se há requisições pendentes
    mov ecx, [bus_request_mask]
    cmp ecx, 0
    je .no_pending_requests
    
    ; Iniciar nova arbitragem
    call dma_arbitrate_bus
    
.no_pending_requests:
    mov eax, 0                 ; Sucesso
    jmp .release_exit
    
.not_owner:
    mov eax, -1                ; Erro: canal não possui barramento
    
.release_exit:
    pop ecx
    pop ebx
    ret

; Função de arbitragem de barramento
dma_arbitrate_bus:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Verificar se há requisições pendentes
    mov eax, [bus_request_mask]
    cmp eax, 0
    je .no_requests
    
    ; Imprimir mensagem de arbitragem
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_arbitration
    mov edx, 35
    int 0x80
    pop eax
    
    ; Encontrar canal com maior prioridade
    mov ebx, -1                ; Melhor canal encontrado
    mov ecx, DMA_MAX_PRIORITY + 1 ; Melhor prioridade encontrada
    mov edx, 0                 ; Contador de canal
    
.check_next_channel:
    cmp edx, DMA_CHANNELS
    jge .arbitration_done
    
    ; Verificar se o canal fez requisição
    mov eax, 1
    mov ecx, edx
    and ecx, 0xFF              ; Garantir que só usamos os 8 bits baixos
    shl eax, cl
    test [bus_request_mask], eax
    jz .next_channel
    
    ; Verificar prioridade do canal
    movzx eax, byte [channel_priorities + edx]
    cmp eax, ecx
    jge .next_channel
    
    ; Canal tem prioridade maior
    mov ecx, eax
    mov ebx, edx
    
.next_channel:
    inc edx
    jmp .check_next_channel
    
.arbitration_done:
    ; Verificar se encontrou um canal
    cmp ebx, -1
    je .no_requests
    
    ; Conceder barramento ao canal vencedor
    mov [bus_owner], ebx
    mov dword [bus_arbitration_state], ARB_GRANTED
    
    ; Remover requisição da máscara
    mov eax, 1
    mov ecx, ebx
    and ecx, 0xFF              ; Garantir que só usamos os 8 bits baixos
    shl eax, cl
    not eax
    and [bus_request_mask], eax
    
    ; Incrementar contador de ciclos de arbitragem
    add dword [arbitration_cycles], DMA_ARBITRATION_CYCLES
    
.no_requests:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Função para transferência em burst
; Entrada: EAX = canal
dma_burst_transfer:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Verificar se o canal possui o barramento
    mov ebx, [bus_owner]
    cmp ebx, eax
    jne .no_bus_access
    
    ; Calcular offset do canal
    shl ebx, 5
    
    ; Verificar se há dados suficientes para burst
    mov ecx, [dma_channels + ebx + 24] ; Remaining count
    cmp ecx, DMA_BURST_SIZE
    jl .small_transfer
    
    ; Imprimir mensagem de burst
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_burst_start
    mov edx, 29
    int 0x80
    pop eax
    
    ; Executar transferência burst
    mov esi, [dma_channels + ebx + 20] ; Current address
    mov edi, burst_buffer
    mov ecx, DMA_BURST_SIZE
    
    ; Transferir bloco completo
.burst_loop:
    cmp ecx, 0
    je .burst_complete
    
    mov al, [esi]
    mov [edi], al
    
    inc esi
    inc edi
    dec ecx
    
    jmp .burst_loop
    
.burst_complete:
    ; Atualizar registradores do canal
    add dword [dma_channels + ebx + 20], DMA_BURST_SIZE ; Current address
    sub dword [dma_channels + ebx + 24], DMA_BURST_SIZE ; Remaining count
    
    ; Incrementar contador de bursts
    inc dword [burst_transfers]
    
    mov eax, DMA_BURST_SIZE    ; Bytes transferidos
    jmp .burst_exit
    
.small_transfer:
    ; Transferência menor que burst size
    mov eax, ecx               ; Transferir bytes restantes
    jmp .burst_exit
    
.no_bus_access:
    mov eax, -1                ; Erro: sem acesso ao barramento
    
.burst_exit:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; Função para definir prioridade de um canal
; Entrada: EAX = canal, EBX = prioridade (0-3)
dma_set_priority:
    push ecx
    
    ; Verificar parâmetros válidos
    cmp eax, DMA_CHANNELS
    jge .invalid_priority_params
    cmp ebx, DMA_MAX_PRIORITY
    jg .invalid_priority_params
    
    ; Definir prioridade
    mov [channel_priorities + eax], bl
    
    mov eax, 0                 ; Sucesso
    jmp .priority_exit
    
.invalid_priority_params:
    mov eax, -1                ; Erro
    
.priority_exit:
    pop ecx
    ret

; Função para obter estatísticas de performance
; Saída: EAX = conflitos, EBX = ciclos arbitragem, ECX = bursts, EDX = bytes DMA
dma_get_performance_stats:
    mov eax, [bus_conflicts]
    mov ebx, [arbitration_cycles]
    mov ecx, [burst_transfers]
    mov edx, [dma_bytes_transferred]
    ret

; Função para otimizar transferência baseada no tamanho
; Entrada: EAX = canal, EBX = tamanho da transferência
; Saída: EAX = estratégia recomendada (0=burst, 1=normal, 2=programada)
dma_optimize_transfer:
    push ecx
    
    ; Estratégia baseada no tamanho
    cmp ebx, DMA_BURST_SIZE * 4  ; Se >= 4 bursts
    jge .recommend_burst
    
    cmp ebx, 16                ; Se >= 16 bytes
    jge .recommend_normal
    
    ; Transferência pequena - E/S programada pode ser mais eficiente
    mov eax, 2
    jmp .optimize_exit
    
.recommend_normal:
    mov eax, 1
    jmp .optimize_exit
    
.recommend_burst:
    mov eax, 0
    
.optimize_exit:
    pop ecx
    ret
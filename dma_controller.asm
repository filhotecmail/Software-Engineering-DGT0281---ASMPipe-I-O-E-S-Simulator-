; DMA Controller Simulator
; Simulador de Controlador DMA (Direct Memory Access) em Assembly x86
; Implementa transferência automática de dados sem intervenção do processador

section .data
    ; Configurações do DMA
    DMA_CHANNELS equ 4         ; Número de canais DMA
    DMA_BLOCK_SIZE equ 64      ; Tamanho padrão do bloco DMA
    
    ; Estados do canal DMA
    DMA_IDLE equ 0
    DMA_ACTIVE equ 1
    DMA_COMPLETE equ 2
    DMA_ERROR equ 3
    
    ; Tipos de transferência
    DMA_MEM_TO_MEM equ 0
    DMA_MEM_TO_IO equ 1
    DMA_IO_TO_MEM equ 2
    
    ; Estrutura do canal DMA (32 bytes por canal)
    ; Offset 0: Source Address (4 bytes)
    ; Offset 4: Destination Address (4 bytes)
    ; Offset 8: Transfer Count (4 bytes)
    ; Offset 12: Control Register (4 bytes)
    ; Offset 16: Status Register (4 bytes)
    ; Offset 20: Current Address (4 bytes)
    ; Offset 24: Remaining Count (4 bytes)
    ; Offset 28: Reserved (4 bytes)
    
    dma_channels times (DMA_CHANNELS * 32) db 0  ; Array de canais DMA
    
    ; Registradores globais do controlador DMA
    dma_master_control dd 0    ; Registrador de controle mestre
    dma_interrupt_status dd 0  ; Status de interrupções
    dma_priority_mask dd 0     ; Máscara de prioridade dos canais
    
    ; Contadores de performance
    dma_transfers_completed dd 0
    dma_bytes_transferred dd 0
    dma_cycles_saved dd 0
    
    ; Mensagens do DMA
    msg_dma_init db 'DMA Controller inicializado', 0xA, 0
    msg_dma_transfer db 'Transferência DMA iniciada no canal ', 0
    msg_dma_complete db 'Transferência DMA completa', 0xA, 0
    msg_dma_error db 'ERRO: Falha na transferência DMA', 0xA, 0
    msg_dma_busy db 'ERRO: Canal DMA ocupado', 0xA, 0
    msg_channel_num db '0', 0xA, 0
    
    ; Buffer de teste para DMA
    dma_test_source db 'DMA Test Data: This is a block transfer test!', 0
    dma_test_source_len equ $ - dma_test_source - 1
    
section .bss
    dma_test_dest resb 256     ; Buffer de destino para testes
    dma_temp_buffer resb 64    ; Buffer temporário para operações DMA

section .text
    ; Exportar funções públicas
    global dma_init
    global dma_setup_channel
    global dma_start_transfer
    global dma_get_status
    global dma_interrupt_handler
    global dma_performance_test
    global dma_demo

; Função para inicializar o controlador DMA
dma_init:
    push eax
    push ebx
    push ecx
    push edi
    
    ; Limpar todos os canais DMA
    mov edi, dma_channels
    mov ecx, (DMA_CHANNELS * 32)
    xor eax, eax
    rep stosb
    
    ; Inicializar registradores globais
    mov dword [dma_master_control], 1  ; Habilitar DMA
    mov dword [dma_interrupt_status], 0
    mov dword [dma_priority_mask], 0x0F ; Todos os canais habilitados
    
    ; Resetar contadores
    mov dword [dma_transfers_completed], 0
    mov dword [dma_bytes_transferred], 0
    mov dword [dma_cycles_saved], 0
    
    ; Imprimir mensagem de inicialização
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_dma_init
    mov edx, 28
    int 0x80
    
    pop edi
    pop ecx
    pop ebx
    pop eax
    ret

; Função para configurar um canal DMA
; Entrada: EAX = canal (0-3), ESI = origem, EDI = destino, ECX = tamanho, EDX = tipo
dma_setup_channel:
    push ebx
    push eax
    
    ; Verificar se o canal é válido
    cmp eax, DMA_CHANNELS
    jge .invalid_channel
    
    ; Calcular offset do canal (canal * 32)
    mov ebx, eax
    shl ebx, 5                 ; ebx = canal * 32
    
    ; Verificar se o canal está livre
    mov eax, [dma_channels + ebx + 16] ; Status register
    cmp eax, DMA_ACTIVE
    je .channel_busy
    
    ; Configurar registradores do canal
    mov [dma_channels + ebx + 0], esi   ; Source address
    mov [dma_channels + ebx + 4], edi   ; Destination address
    mov [dma_channels + ebx + 8], ecx   ; Transfer count
    mov [dma_channels + ebx + 12], edx  ; Control register (tipo)
    mov dword [dma_channels + ebx + 16], DMA_IDLE ; Status
    mov [dma_channels + ebx + 20], esi  ; Current address = source
    mov [dma_channels + ebx + 24], ecx  ; Remaining count
    
    mov eax, 0                 ; Sucesso
    jmp .setup_exit
    
.invalid_channel:
    mov eax, -1                ; Erro: canal inválido
    jmp .setup_exit
    
.channel_busy:
    ; Imprimir mensagem de erro
    push ecx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_dma_busy
    mov edx, 23
    int 0x80
    pop edx
    pop ecx
    mov eax, -2                ; Erro: canal ocupado
    
.setup_exit:
    pop eax
    pop ebx
    ret

; Função para iniciar transferência DMA
; Entrada: EAX = canal
dma_start_transfer:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Verificar se o canal é válido
    cmp eax, DMA_CHANNELS
    jge .invalid_channel_start
    
    ; Calcular offset do canal
    mov ebx, eax
    shl ebx, 5
    
    ; Verificar se o canal está configurado
    mov ecx, [dma_channels + ebx + 16] ; Status
    cmp ecx, DMA_IDLE
    jne .channel_not_ready
    
    ; Imprimir mensagem de início
    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_dma_transfer
    mov edx, 35
    int 0x80
    pop ebx
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
    
    ; Marcar canal como ativo
    mov dword [dma_channels + ebx + 16], DMA_ACTIVE
    
    ; Executar transferência simulada
    call .simulate_dma_transfer
    
    ; Marcar como completo
    mov dword [dma_channels + ebx + 16], DMA_COMPLETE
    
    ; Atualizar contadores de performance
    inc dword [dma_transfers_completed]
    mov ecx, [dma_channels + ebx + 8]  ; Transfer count
    add [dma_bytes_transferred], ecx
    
    ; Simular ciclos salvos (aproximadamente 3 ciclos por byte)
    mov edx, ecx
    shl edx, 1
    add edx, ecx               ; edx = ecx * 3
    add [dma_cycles_saved], edx
    
    ; Imprimir mensagem de conclusão
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_dma_complete
    mov edx, 26
    int 0x80
    
    mov eax, 0                 ; Sucesso
    jmp .start_exit
    
.invalid_channel_start:
    mov eax, -1
    jmp .start_exit
    
.channel_not_ready:
    mov eax, -2
    jmp .start_exit
    
.start_exit:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; Subrotina para simular transferência DMA
.simulate_dma_transfer:
    ; Obter endereços e tamanho
    mov esi, [dma_channels + ebx + 0]   ; Source
    mov edi, [dma_channels + ebx + 4]   ; Destination
    mov ecx, [dma_channels + ebx + 8]   ; Count
    
    ; Simular transferência em blocos
.transfer_loop:
    cmp ecx, 0
    je .transfer_done
    
    ; Transferir um byte (simulação)
    mov al, [esi]
    mov [edi], al
    
    inc esi
    inc edi
    dec ecx
    
    ; Simular delay de barramento (opcional)
    ; nop
    
    jmp .transfer_loop
    
.transfer_done:
    ret

; Função para obter status de um canal DMA
; Entrada: EAX = canal
; Saída: EAX = status, EBX = bytes restantes
dma_get_status:
    push ecx
    
    ; Verificar canal válido
    cmp eax, DMA_CHANNELS
    jge .invalid_status_channel
    
    ; Calcular offset
    mov ecx, eax
    shl ecx, 5
    
    ; Obter status e bytes restantes
    mov eax, [dma_channels + ecx + 16]  ; Status
    mov ebx, [dma_channels + ecx + 24]  ; Remaining count
    
    jmp .status_exit
    
.invalid_status_channel:
    mov eax, -1
    mov ebx, 0
    
.status_exit:
    pop ecx
    ret

; Handler de interrupção DMA (simulado)
dma_interrupt_handler:
    push eax
    push ebx
    
    ; Simular processamento de interrupção
    ; Em um sistema real, isso seria chamado pelo hardware
    
    ; Verificar quais canais completaram
    mov eax, 0
.check_channels:
    cmp eax, DMA_CHANNELS
    jge .irq_done
    
    push eax
    call dma_get_status
    cmp eax, DMA_COMPLETE
    jne .next_channel
    
    ; Canal completou - processar
    ; (aqui poderia notificar o sistema operacional)
    
.next_channel:
    pop eax
    inc eax
    jmp .check_channels
    
.irq_done:
    pop ebx
    pop eax
    ret

; Função de demonstração do DMA
dma_demo:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Inicializar DMA
    call dma_init
    
    ; Configurar canal 0 para transferência de memória
    mov eax, 0                 ; Canal 0
    mov esi, dma_test_source   ; Origem
    mov edi, dma_test_dest     ; Destino
    mov ecx, dma_test_source_len ; Tamanho
    mov edx, DMA_MEM_TO_MEM    ; Tipo
    call dma_setup_channel
    
    ; Iniciar transferência
    mov eax, 0
    call dma_start_transfer
    
    ; Verificar resultado
    call .print_transfer_result
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Subrotina para imprimir resultado da transferência
.print_transfer_result:
    ; Imprimir dados transferidos
    mov eax, 4
    mov ebx, 1
    mov ecx, dma_test_dest
    mov edx, dma_test_source_len
    int 0x80
    
    ; Nova linha
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_channel_num + 1  ; Usar o \n
    mov edx, 1
    int 0x80
    
    ret

; Função de teste de performance DMA vs E/S programada
dma_performance_test:
    ; Esta função seria implementada para comparar
    ; a performance entre DMA e E/S programada
    ; Por simplicidade, apenas retorna os contadores atuais
    
    mov eax, [dma_transfers_completed]
    mov ebx, [dma_bytes_transferred]
    mov ecx, [dma_cycles_saved]
    
    ret
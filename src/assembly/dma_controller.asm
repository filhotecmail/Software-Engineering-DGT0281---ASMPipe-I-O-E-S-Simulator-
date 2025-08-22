; DMA Controller Simulator
;  Eu estou aqui criando um simulador de controlador DMA em Assembly x86
; Aqui eu implemento transferência automática de dados porque quero que o processador
; não precise ficar perdendo tempo movendo dados manualmente

section .data
    ; Aqui eu defino as configurações básicas do meu DMA
    DMA_CHANNELS equ 4         ; Eu escolhi 4 canais porque é um número bom para demonstrar
    DMA_BLOCK_SIZE equ 64      ; Aqui eu pego 64 bytes como padrão porque é eficiente
    
    ; Aqui eu defino os estados que meus canais DMA podem ter
    DMA_IDLE equ 0             ; Canal parado, esperando trabalho
    DMA_ACTIVE equ 1           ; Canal trabalhando duro transferindo dados
    DMA_COMPLETE equ 2         ; Canal terminou o trabalho com sucesso
    DMA_ERROR equ 3            ; Algo deu errado, preciso investigar
    
    ; Aqui eu defino os tipos de transferência que posso fazer
    DMA_MEM_TO_MEM equ 0       ; Memória para memória - o mais comum
    DMA_MEM_TO_IO equ 1        ; Memória para dispositivo - para saída
    DMA_IO_TO_MEM equ 2        ; Dispositivo para memória - para entrada
    
    ; Aqui eu organizo a estrutura de cada canal DMA (32 bytes por canal)
    ; Eu faço assim porque preciso guardar todas as informações importantes:
    ; Offset 0: De onde vou pegar os dados (endereço origem)
    ; Offset 4: Para onde vou mandar os dados (endereço destino)
    ; Offset 8: Quantos bytes vou transferir no total
    ; Offset 12: Como vou fazer a transferência (controle)
    ; Offset 16: Como está indo a transferência (status)
    ; Offset 20: Onde estou agora na transferência (endereço atual)
    ; Offset 24: Quantos bytes ainda faltam transferir
    ; Offset 28: Espaço reservado para futuras melhorias
    
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
    
    ; Aqui eu crio um buffer de teste para ver se meu DMA funciona
    dma_test_source db 'DMA Test Data: This is a block transfer test!', 0
    dma_test_source_len equ $ - dma_test_source - 1
    
section .bss
    dma_test_dest resb 256     ; Aqui eu reservo espaço para onde vão os dados testados
    dma_temp_buffer resb 64    ; Buffer que eu uso quando preciso de espaço temporário

section .text
    ; Aqui eu exporto as funções que outros arquivos podem usar
    global dma_init
    global dma_setup_channel
    global dma_start_transfer
    global dma_get_status
    global dma_interrupt_handler
    global dma_performance_test
    global dma_demo

; Aqui eu inicializo meu controlador DMA - é a primeira coisa que preciso fazer
dma_init:
    push eax
    push ebx
    push ecx
    push edi
    
    ; Primeiro eu limpo todos os canais DMA para começar do zero
    mov edi, dma_channels
    mov ecx, (DMA_CHANNELS * 32)
    xor eax, eax
    rep stosb
    
    ; Agora eu configuro os registradores principais
    mov dword [dma_master_control], 1  ; Aqui eu ligo o DMA
    mov dword [dma_interrupt_status], 0 ; Limpo as interrupções
    mov dword [dma_priority_mask], 0x0F ; Habilito todos os 4 canais
    
    ; Eu zero os contadores para começar a contar do início
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

; Aqui eu configuro um canal DMA específico com todos os parâmetros
; Eu recebo: EAX = qual canal (0-3), ESI = de onde pegar, EDI = para onde mandar, ECX = quantos bytes, EDX = tipo
dma_setup_channel:
    push ebx
    push eax
    
    ; Primeiro eu verifico se o canal que me passaram existe
    cmp eax, DMA_CHANNELS
    jge .invalid_channel
    
    ; Aqui eu calculo onde fica esse canal na memória (cada canal ocupa 32 bytes)
    mov ebx, eax
    shl ebx, 5                 ; ebx = canal * 32 (multiplico por 32)
    
    ; Agora eu verifico se esse canal não está ocupado
    mov eax, [dma_channels + ebx + 16] ; Eu pego o status do canal
    cmp eax, DMA_ACTIVE
    je .channel_busy
    
    ; Agora eu configuro todos os registradores do canal
    mov [dma_channels + ebx + 0], esi   ; Aqui eu guardo de onde vou pegar os dados
    mov [dma_channels + ebx + 4], edi   ; Aqui eu guardo para onde vou mandar
    mov [dma_channels + ebx + 8], ecx   ; Quantos bytes vou transferir no total
    mov [dma_channels + ebx + 12], edx  ; Como vou fazer a transferência
    mov dword [dma_channels + ebx + 16], DMA_IDLE ; Marco como pronto para usar
    mov [dma_channels + ebx + 20], esi  ; Onde estou agora = início
    mov [dma_channels + ebx + 24], ecx  ; Quantos bytes ainda faltam = todos
    
    mov eax, 0                 ; Tudo certo, canal configurado!
    jmp .setup_exit
    
.invalid_channel:
    mov eax, -1                ; Ops, esse canal não existe
    jmp .setup_exit
    
.channel_busy:
    ; Aqui eu aviso que o canal está ocupado
    push ecx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_dma_busy
    mov edx, 23
    int 0x80
    pop edx
    pop ecx
    mov eax, -2                ; Canal ocupado, tente mais tarde
    
.setup_exit:
    pop eax
    pop ebx
    ret

; Aqui eu inicio uma transferência DMA - é quando a mágica acontece!
; Eu recebo: EAX = qual canal usar
dma_start_transfer:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Primeiro eu verifico se o canal existe
    cmp eax, DMA_CHANNELS
    jge .invalid_channel_start
    
    ; Aqui eu calculo onde está esse canal na memória
    mov ebx, eax
    shl ebx, 5
    
    ; Agora eu verifico se o canal está pronto para trabalhar
    mov ecx, [dma_channels + ebx + 16] ; Eu pego o status
    cmp ecx, DMA_IDLE
    jne .channel_not_ready
    
    ; Aqui eu aviso que vou começar a transferência
    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_dma_transfer
    mov edx, 35
    int 0x80
    pop ebx
    pop eax
    
    ; Eu mostro qual canal está trabalhando
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
; DMA Advanced Features
; Aqui eu implemento as funcionalidades mais avançadas do meu DMA
; Eu faço arbitragem de barramento porque vários canais podem querer usar o bus ao mesmo tempo
; Também controlo prioridades e otimizo as transferências para serem mais rápidas

section .data
    ; Aqui eu defino as configurações mais avançadas
    DMA_BURST_SIZE equ 8       ; Eu transfiro 8 bytes de uma vez para ser mais eficiente
    DMA_MAX_PRIORITY equ 3     ; A prioridade vai de 0 a 3 (0 é mais importante)
    DMA_ARBITRATION_CYCLES equ 4 ; Eu gasto no máximo 4 ciclos decidindo quem usa o bus
    
    ; Aqui eu defino os estados da arbitragem do barramento
    ARB_IDLE equ 0             ; Ninguém quer usar o bus agora
    ARB_REQUESTING equ 1       ; Alguém está pedindo para usar o bus
    ARB_GRANTED equ 2          ; Eu já decidi quem pode usar
    ARB_BUSY equ 3             ; O bus está ocupado transferindo dados
    
    ; Aqui eu defino quem tem prioridade (0 = mais importante)
    channel_priorities db 0, 1, 2, 3  ; Canal 0 é o mais importante, depois 1, 2, 3
    
    ; Aqui eu controlo quem está usando o barramento
    bus_owner dd -1            ; Qual canal está usando (-1 = ninguém)
    bus_arbitration_state dd ARB_IDLE ; Em que estado está a arbitragem
    bus_request_mask dd 0      ; Quais canais estão pedindo para usar
    
    ; Aqui eu conto estatísticas para ver como está o desempenho
    bus_conflicts dd 0         ; Quantas vezes dois canais quiseram o bus ao mesmo tempo
    arbitration_cycles dd 0    ; Quantos ciclos eu gastei decidindo quem usa o bus
    burst_transfers dd 0       ; Quantas transferências rápidas eu fiz
    
    ; Mensagens que eu mostro quando coisas interessantes acontecem
    msg_bus_granted db 'Barramento concedido ao canal ', 0
    msg_bus_conflict db 'Conflito de barramento detectado', 0xA, 0
    msg_burst_start db 'Iniciando transferência burst', 0xA, 0
    msg_arbitration db 'Arbitragem de barramento em progresso', 0xA, 0
    
section .bss
    ; Aqui eu reservo espaço para as transferências rápidas
    burst_buffer resb DMA_BURST_SIZE  ; Buffer temporário para transferências burst
    temp_priority_list resb DMA_CHANNELS ; Lista temporária para ordenar prioridades

section .text
    ; Aqui eu exporto as funções avançadas que outros arquivos podem usar
    global dma_request_bus
    global dma_release_bus
    global dma_arbitrate_bus
    global dma_burst_transfer
    global dma_set_priority
    global dma_get_performance_stats
    global dma_optimize_transfer

; Aqui eu implemento a requisição de acesso ao barramento
; Eu recebo: EAX = qual canal quer usar o bus
; Eu retorno: EAX = 0 (conseguiu), -1 (erro)
dma_request_bus:
    push ebx
    push ecx
    
    ; Primeiro eu verifico se o canal existe
    cmp eax, DMA_CHANNELS
    jge .invalid_channel_req
    
    ; Agora eu verifico se alguém já está usando o barramento
    mov ebx, [bus_owner]
    cmp ebx, -1
    je .grant_immediately
    
    ; O barramento está ocupado - vou colocar na fila de espera
    mov ecx, 1
    mov edx, eax
    and edx, 0xFF              ; Aqui eu pego só os 8 bits que preciso
    shl ecx, cl                ; Eu crio uma máscara para marcar esse canal
    or [bus_request_mask], ecx ; Adiciono na lista de quem está esperando
    
    ; Eu conto mais um conflito para as estatísticas
    inc dword [bus_conflicts]
    
    ; Aqui eu aviso que teve conflito
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bus_conflict
    mov edx, 32
    int 0x80
    pop eax
    
    ; Agora eu chamo a arbitragem para decidir quem vai usar
    call dma_arbitrate_bus
    
    mov eax, 1                 ; Requisição pendente
    jmp .request_exit
    
.grant_immediately:
    ; Que sorte! O barramento está livre, posso dar para esse canal
    mov [bus_owner], eax
    mov dword [bus_arbitration_state], ARB_GRANTED
    
    ; Aqui eu aviso que concedi o barramento
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bus_granted
    mov edx, 30
    int 0x80
    pop eax
    
    ; Eu mostro qual canal ganhou o barramento
    push eax
    add eax, '0'
    mov [msg_channel_num], al
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_channel_num
    mov edx, 2
    int 0x80
    pop eax
    
    mov eax, 0                 ; Tudo certo!
    jmp .request_exit
    
.invalid_channel_req:
    mov eax, -1                ; Ops, canal inválido!
    
.request_exit:
    pop ecx
    pop ebx
    ret

; Aqui eu implemento a liberação do barramento
; Eu recebo: EAX = canal que quer liberar
dma_release_bus:
    push ebx
    push ecx
    
    ; Primeiro eu verifico se esse canal realmente tem o barramento
    mov ebx, [bus_owner]
    cmp ebx, eax
    jne .not_owner
    
    ; Agora eu libero o barramento para outros usarem
    mov dword [bus_owner], -1
    mov dword [bus_arbitration_state], ARB_IDLE
    
    ; Vou ver se tem alguém esperando na fila
    mov ecx, [bus_request_mask]
    cmp ecx, 0
    je .no_pending_requests
    
    ; Tem gente esperando! Vou fazer uma nova arbitragem
    call dma_arbitrate_bus
    
.no_pending_requests:
    mov eax, 0                 ; Tudo liberado com sucesso!
    jmp .release_exit
    
.not_owner:
    mov eax, -1                ; Erro: esse canal nem tem o barramento!
    
.release_exit:
    pop ecx
    pop ebx
    ret

; Aqui eu faço a arbitragem - decido quem vai usar o barramento
dma_arbitrate_bus:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Primeiro eu vejo se tem alguém pedindo o barramento
    mov eax, [bus_request_mask]
    cmp eax, 0
    je .no_requests
    
    ; Vou avisar que estou fazendo arbitragem
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_arbitration
    mov edx, 35
    int 0x80
    pop eax
    
    ; Agora eu procuro o canal com maior prioridade
    mov ebx, -1                ; Aqui eu guardo o melhor canal que encontrar
    mov ecx, DMA_MAX_PRIORITY + 1 ; Aqui eu guardo a melhor prioridade
    mov edx, 0                 ; Eu uso isso para contar os canais
    
.check_next_channel:
    cmp edx, DMA_CHANNELS
    jge .arbitration_done
    
    ; Vou ver se esse canal está pedindo o barramento
    mov eax, 1
    mov ecx, edx
    and ecx, 0xFF              ; Eu pego só os bits que preciso
    shl eax, cl
    test [bus_request_mask], eax
    jz .next_channel
    
    ; Agora eu vejo qual é a prioridade desse canal
    movzx eax, byte [channel_priorities + edx]
    cmp eax, ecx
    jge .next_channel
    
    ; Opa! Esse canal tem prioridade melhor que o atual
    mov ecx, eax
    mov ebx, edx
    
.next_channel:
    inc edx
    jmp .check_next_channel
    
.arbitration_done:
    ; Vou ver se encontrei algum canal para dar o barramento
    cmp ebx, -1
    je .no_requests
    
    ; Achei! Vou dar o barramento para o canal vencedor
    mov [bus_owner], ebx
    mov dword [bus_arbitration_state], ARB_GRANTED
    
    ; Agora eu tiro esse canal da lista de espera
    mov eax, 1
    mov ecx, ebx
    and ecx, 0xFF              ; Eu pego só os bits que preciso
    shl eax, cl
    not eax
    and [bus_request_mask], eax
    
    ; Eu conto os ciclos que gastei fazendo arbitragem
    add dword [arbitration_cycles], DMA_ARBITRATION_CYCLES
    
.no_requests:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Aqui eu faço transferência em burst - muito mais rápido!
; Eu recebo: EAX = canal que vai fazer o burst
dma_burst_transfer:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Primeiro eu verifico se esse canal tem o barramento
    mov ebx, [bus_owner]
    cmp ebx, eax
    jne .no_bus_access
    
    ; Agora eu calculo onde estão os dados desse canal
    shl ebx, 5
    
    ; Vou ver se tem dados suficientes para fazer um burst completo
    mov ecx, [dma_channels + ebx + 24] ; Quantos bytes ainda faltam
    cmp ecx, DMA_BURST_SIZE
    jl .small_transfer
    
    ; Legal! Posso fazer burst. Vou avisar
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_burst_start
    mov edx, 29
    int 0x80
    pop eax
    
    ; Agora eu preparo tudo para a transferência burst
    mov esi, [dma_channels + ebx + 20] ; De onde eu vou pegar os dados
    mov edi, burst_buffer
    mov ecx, DMA_BURST_SIZE
    
    ; Aqui eu faço o loop para transferir o bloco todo
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
    ; Agora eu atualizo os registradores do canal
    add dword [dma_channels + ebx + 20], DMA_BURST_SIZE ; Onde estou agora
    sub dword [dma_channels + ebx + 24], DMA_BURST_SIZE ; Quanto ainda falta
    
    ; Eu conto mais um burst nas estatísticas
    inc dword [burst_transfers]
    
    mov eax, DMA_BURST_SIZE    ; Quantos bytes eu transferi
    jmp .burst_exit
    
.small_transfer:
    ; A transferência é pequena demais para burst
    mov eax, ecx               ; Vou transferir só o que sobrou
    jmp .burst_exit
    
.no_bus_access:
    mov eax, -1                ; Erro: esse canal nem tem o barramento!
    
.burst_exit:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; Aqui eu defino a prioridade de um canal
; Eu recebo: EAX = canal, EBX = prioridade (0-3)
dma_set_priority:
    push ecx
    
    ; Primeiro eu verifico se os parâmetros fazem sentido
    cmp eax, DMA_CHANNELS
    jge .invalid_priority_params
    cmp ebx, DMA_MAX_PRIORITY
    jg .invalid_priority_params
    
    ; Tudo certo! Vou definir a prioridade
    mov [channel_priorities + eax], bl
    
    mov eax, 0                 ; Sucesso!
    jmp .priority_exit
    
.invalid_priority_params:
    mov eax, -1                ; Parâmetros inválidos!
    
.priority_exit:
    pop ecx
    ret

; Aqui eu retorno as estatísticas de performance
; Eu retorno: EAX = conflitos, EBX = ciclos arbitragem, ECX = bursts, EDX = bytes DMA
dma_get_performance_stats:
    mov eax, [bus_conflicts]
    mov ebx, [arbitration_cycles]
    mov ecx, [burst_transfers]
    mov edx, [dma_bytes_transferred]
    ret

; Aqui eu recomendo a melhor estratégia baseada no tamanho
; Eu recebo: EAX = canal, EBX = tamanho da transferência
; Eu retorno: EAX = estratégia (0=burst, 1=normal, 2=programada)
dma_optimize_transfer:
    push ecx
    
    ; Eu decido baseado no tamanho dos dados
    cmp ebx, DMA_BURST_SIZE * 4  ; Se for >= 4 bursts
    jge .recommend_burst
    
    cmp ebx, 16                ; Se for >= 16 bytes
    jge .recommend_normal
    
    ; É muito pequeno - E/S programada pode ser melhor
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
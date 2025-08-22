; ASMPipe I/O Simulator
; Simulador de pipe de E/S programável em Assembly x86
; Implementa buffer circular com rotinas de leitura e escrita

section .data
    ; Configurações do buffer circular
    BUFFER_SIZE equ 256        ; Tamanho do buffer (256 bytes)
    
    ; Buffer circular e ponteiros
    pipe_buffer times BUFFER_SIZE db 0  ; Buffer circular
    read_ptr dd 0              ; Ponteiro de leitura
    write_ptr dd 0             ; Ponteiro de escrita
    data_count dd 0            ; Contador de dados no buffer
    
    ; Mensagens para output
    msg_init db 'ASMPipe I/O Simulator iniciado', 0xA, 0
    msg_write db 'Escrevendo dados no pipe...', 0xA, 0
    msg_read db 'Lendo dados do pipe...', 0xA, 0
    msg_full db 'ERRO: Pipe cheio!', 0xA, 0
    msg_empty db 'ERRO: Pipe vazio!', 0xA, 0
    msg_data db 'Dados: ', 0
    msg_newline db 0xA, 0
    
    ; Dados de teste
    test_data db 'Hello, ASMPipe!', 0
    test_data_len equ $ - test_data - 1

section .bss
    temp_buffer resb 256       ; Buffer temporário para operações

section .text
    global _start

_start:
    ; Inicializar simulador
    call print_init_msg
    
    ; Testar escrita no pipe
    call test_write_operations
    
    ; Testar leitura do pipe
    call test_read_operations
    
    ; Finalizar programa
    mov eax, 1                 ; sys_exit
    mov ebx, 0                 ; status
    int 0x80

; Função para imprimir mensagem de inicialização
print_init_msg:
    mov eax, 4                 ; sys_write
    mov ebx, 1                 ; stdout
    mov ecx, msg_init
    mov edx, 30                ; tamanho da mensagem
    int 0x80
    ret

; Função para escrever dados no pipe
; Entrada: ESI = ponteiro para dados, ECX = tamanho
pipe_write:
    push eax
    push ebx
    push edx
    push edi
    
    ; Verificar se há espaço no buffer
    mov eax, [data_count]
    cmp eax, BUFFER_SIZE
    jge .buffer_full
    
    ; Calcular quantos bytes podem ser escritos
    mov ebx, BUFFER_SIZE
    sub ebx, eax               ; espaço disponível
    cmp ecx, ebx
    jle .write_all
    mov ecx, ebx               ; limitar ao espaço disponível
    
.write_all:
    mov edi, pipe_buffer
    add edi, [write_ptr]       ; posição de escrita
    
.write_loop:
    cmp ecx, 0
    je .write_done
    
    ; Copiar byte
    lodsb                      ; AL = [ESI++]
    stosb                      ; [EDI++] = AL
    
    ; Atualizar ponteiro de escrita (circular)
    inc dword [write_ptr]
    mov eax, [write_ptr]
    cmp eax, BUFFER_SIZE
    jl .no_wrap_write
    mov dword [write_ptr], 0
    mov edi, pipe_buffer
    
.no_wrap_write:
    inc dword [data_count]
    dec ecx
    jmp .write_loop
    
.write_done:
    mov eax, 0                 ; sucesso
    jmp .write_exit
    
.buffer_full:
    ; Imprimir mensagem de erro
    push ecx
    push esi
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_full
    mov edx, 18
    int 0x80
    pop esi
    pop ecx
    mov eax, -1                ; erro
    
.write_exit:
    pop edi
    pop edx
    pop ebx
    pop eax
    ret

; Função para ler dados do pipe
; Entrada: EDI = buffer destino, ECX = tamanho máximo
; Saída: EAX = bytes lidos
pipe_read:
    push ebx
    push edx
    push esi
    
    ; Verificar se há dados no buffer
    mov eax, [data_count]
    cmp eax, 0
    je .buffer_empty
    
    ; Calcular quantos bytes podem ser lidos
    cmp ecx, eax
    jle .read_requested
    mov ecx, eax               ; limitar aos dados disponíveis
    
.read_requested:
    mov esi, pipe_buffer
    add esi, [read_ptr]        ; posição de leitura
    mov ebx, ecx               ; salvar contador
    
.read_loop:
    cmp ecx, 0
    je .read_done
    
    ; Copiar byte
    lodsb                      ; AL = [ESI++]
    stosb                      ; [EDI++] = AL
    
    ; Atualizar ponteiro de leitura (circular)
    inc dword [read_ptr]
    mov eax, [read_ptr]
    cmp eax, BUFFER_SIZE
    jl .no_wrap_read
    mov dword [read_ptr], 0
    mov esi, pipe_buffer
    
.no_wrap_read:
    dec dword [data_count]
    dec ecx
    jmp .read_loop
    
.read_done:
    mov eax, ebx               ; retornar bytes lidos
    jmp .read_exit
    
.buffer_empty:
    ; Imprimir mensagem de erro
    push ecx
    push edi
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_empty
    mov edx, 19
    int 0x80
    pop edi
    pop ecx
    mov eax, 0                 ; nenhum byte lido
    
.read_exit:
    pop esi
    pop edx
    pop ebx
    ret

; Função de teste para operações de escrita
test_write_operations:
    ; Imprimir mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_write
    mov edx, 28
    int 0x80
    
    ; Escrever dados de teste no pipe
    mov esi, test_data
    mov ecx, test_data_len
    call pipe_write
    
    ret

; Função de teste para operações de leitura
test_read_operations:
    ; Imprimir mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_read
    mov edx, 25
    int 0x80
    
    ; Ler dados do pipe
    mov edi, temp_buffer
    mov ecx, 256
    call pipe_read
    
    ; Verificar se leu algum dado
    cmp eax, 0
    je .no_data_read
    
    ; Imprimir dados lidos
    push eax                   ; salvar tamanho
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_data
    mov edx, 7
    int 0x80
    
    pop edx                    ; recuperar tamanho
    mov eax, 4
    mov ebx, 1
    mov ecx, temp_buffer
    int 0x80
    
    ; Imprimir nova linha
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_newline
    mov edx, 1
    int 0x80
    
.no_data_read:
    ret

; Função para obter status do pipe
; Saída: EAX = dados disponíveis, EBX = espaço livre
get_pipe_status:
    mov eax, [data_count]
    mov ebx, BUFFER_SIZE
    sub ebx, eax
    ret

; Função para limpar o pipe
clear_pipe:
    mov dword [read_ptr], 0
    mov dword [write_ptr], 0
    mov dword [data_count], 0
    ret
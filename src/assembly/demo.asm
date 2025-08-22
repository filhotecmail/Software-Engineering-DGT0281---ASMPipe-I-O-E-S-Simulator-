; Demonstração Avançada do ASMPipe I/O Simulator
; Mostra diferentes cenários de uso do pipe

section .data
    ; Mensagens de demonstração
    demo_title db '=== DEMONSTRAÇÃO ASMPipe I/O SIMULATOR ===', 0xA, 0
    demo_test1 db 'TESTE 1: Operações básicas de escrita/leitura', 0xA, 0
    demo_test2 db 'TESTE 2: Teste de buffer cheio', 0xA, 0
    demo_test3 db 'TESTE 3: Teste de buffer vazio', 0xA, 0
    demo_test4 db 'TESTE 4: Múltiplas operações', 0xA, 0
    demo_separator db '----------------------------------------', 0xA, 0
    
    ; Dados de teste variados
    data1 db 'Primeira mensagem', 0
    data1_len equ $ - data1 - 1
    
    data2 db 'Segunda mensagem mais longa para testar o buffer', 0
    data2_len equ $ - data2 - 1
    
    data3 db 'Terceira mensagem', 0
    data3_len equ $ - data3 - 1
    
    ; Buffer grande para testar overflow
    big_data times 300 db 'X'  ; 300 bytes de 'X'
    big_data_end db 0
    big_data_len equ 300
    
    ; Mensagens de status
    status_msg db 'Status do pipe - Dados: ', 0
    space_msg db ', Espaço livre: ', 0
    bytes_msg db ' bytes', 0xA, 0
    
section .bss
    read_buffer resb 512       ; Buffer para leitura
    
section .text
    global _start
    
    ; Incluir funções do simulador principal
    extern pipe_write, pipe_read, get_pipe_status, clear_pipe
    
_start:
    ; Título da demonstração
    call print_demo_title
    
    ; Teste 1: Operações básicas
    call demo_basic_operations
    
    ; Teste 2: Buffer cheio
    call demo_buffer_full
    
    ; Teste 3: Buffer vazio
    call demo_buffer_empty
    
    ; Teste 4: Múltiplas operações
    call demo_multiple_operations
    
    ; Finalizar
    mov eax, 1
    mov ebx, 0
    int 0x80

; Imprimir título da demonstração
print_demo_title:
    mov eax, 4
    mov ebx, 1
    mov ecx, demo_title
    mov edx, 44
    int 0x80
    ret

; Imprimir separador
print_separator:
    mov eax, 4
    mov ebx, 1
    mov ecx, demo_separator
    mov edx, 41
    int 0x80
    ret

; Imprimir status do pipe
print_pipe_status:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Obter status
    call get_pipe_status
    push eax                   ; salvar dados disponíveis
    push ebx                   ; salvar espaço livre
    
    ; Imprimir "Status do pipe - Dados: "
    mov eax, 4
    mov ebx, 1
    mov ecx, status_msg
    mov edx, 25
    int 0x80
    
    ; Converter e imprimir número de dados
    pop ebx                    ; espaço livre
    pop eax                    ; dados disponíveis
    push ebx                   ; salvar espaço livre novamente
    call print_number
    
    ; Imprimir ", Espaço livre: "
    mov eax, 4
    mov ebx, 1
    mov ecx, space_msg
    mov edx, 15
    int 0x80
    
    ; Imprimir espaço livre
    pop eax                    ; espaço livre
    call print_number
    
    ; Imprimir " bytes"
    mov eax, 4
    mov ebx, 1
    mov ecx, bytes_msg
    mov edx, 7
    int 0x80
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Função simples para imprimir número (apenas para números pequenos)
print_number:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Converter número para string (método simples)
    add eax, '0'               ; converter para ASCII (funciona apenas para 0-9)
    cmp eax, '9'
    jle .single_digit
    
    ; Para números maiores, usar uma aproximação simples
    mov eax, '?'               ; mostrar '?' para números complexos
    
.single_digit:
    mov [read_buffer], al
    mov eax, 4
    mov ebx, 1
    mov ecx, read_buffer
    mov edx, 1
    int 0x80
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Demonstração 1: Operações básicas
demo_basic_operations:
    ; Título do teste
    mov eax, 4
    mov ebx, 1
    mov ecx, demo_test1
    mov edx, 42
    int 0x80
    
    ; Limpar pipe
    call clear_pipe
    
    ; Status inicial
    call print_pipe_status
    
    ; Escrever primeira mensagem
    mov esi, data1
    mov ecx, data1_len
    call pipe_write
    
    ; Status após escrita
    call print_pipe_status
    
    ; Ler mensagem
    mov edi, read_buffer
    mov ecx, 512
    call pipe_read
    
    ; Imprimir dados lidos
    cmp eax, 0
    je .no_data1
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    mov ecx, read_buffer
    int 0x80
    
    ; Nova linha
    mov eax, 4
    mov ebx, 1
    mov ecx, bytes_msg + 6     ; apenas \n
    mov edx, 1
    int 0x80
    
.no_data1:
    ; Status final
    call print_pipe_status
    call print_separator
    ret

; Demonstração 2: Buffer cheio
demo_buffer_full:
    ; Título do teste
    mov eax, 4
    mov ebx, 1
    mov ecx, demo_test2
    mov edx, 30
    int 0x80
    
    ; Limpar pipe
    call clear_pipe
    
    ; Tentar escrever dados grandes (maior que buffer)
    mov esi, big_data
    mov ecx, big_data_len
    call pipe_write
    
    ; Status após tentativa
    call print_pipe_status
    call print_separator
    ret

; Demonstração 3: Buffer vazio
demo_buffer_empty:
    ; Título do teste
    mov eax, 4
    mov ebx, 1
    mov ecx, demo_test3
    mov edx, 29
    int 0x80
    
    ; Limpar pipe
    call clear_pipe
    
    ; Tentar ler de buffer vazio
    mov edi, read_buffer
    mov ecx, 512
    call pipe_read
    
    ; Status após tentativa
    call print_pipe_status
    call print_separator
    ret

; Demonstração 4: Múltiplas operações
demo_multiple_operations:
    ; Título do teste
    mov eax, 4
    mov ebx, 1
    mov ecx, demo_test4
    mov edx, 32
    int 0x80
    
    ; Limpar pipe
    call clear_pipe
    
    ; Escrever múltiplas mensagens
    mov esi, data1
    mov ecx, data1_len
    call pipe_write
    
    mov esi, data2
    mov ecx, data2_len
    call pipe_write
    
    mov esi, data3
    mov ecx, data3_len
    call pipe_write
    
    ; Status com múltiplos dados
    call print_pipe_status
    
    ; Ler parcialmente
    mov edi, read_buffer
    mov ecx, 20                ; ler apenas 20 bytes
    call pipe_read
    
    ; Status após leitura parcial
    call print_pipe_status
    
    ; Ler o restante
    mov edi, read_buffer
    mov ecx, 512
    call pipe_read
    
    ; Status final
    call print_pipe_status
    call print_separator
    ret
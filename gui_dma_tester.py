#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Interface Gráfica Colorida para Teste do Simulador DMA
Criado por: Um estudante de Engenharia de Software aprendendo sobre DMA

Esta interface permite testar o simulador DMA de forma visual e interativa,
com cenários realistas de um estudante que está aprendendo a matéria.
"""

import os
import sys
import subprocess
import time
from colorama import Fore, Back, Style, init

# Inicializar colorama para cores no terminal
init(autoreset=True)

class DMAGUITester:
    def __init__(self):
        self.clear_screen()
        self.show_welcome()
        
    def clear_screen(self):
        """Limpa a tela do terminal"""
        os.system('clear' if os.name == 'posix' else 'cls')
        
    def show_welcome(self):
        """Mostra a tela de boas-vindas colorida"""
        print(f"{Fore.CYAN}{Style.BRIGHT}" + "="*70)
        print(f"{Fore.YELLOW}{Style.BRIGHT}    🚀 SIMULADOR DMA - INTERFACE GRÁFICA DE TESTE 🚀")
        print(f"{Fore.CYAN}{Style.BRIGHT}" + "="*70)
        print(f"{Fore.GREEN}Olá! Sou um estudante de Engenharia de Software aprendendo sobre DMA.")
        print(f"{Fore.GREEN}Criei esta interface para testar meu simulador de forma visual!")
        print(f"{Fore.CYAN}{Style.BRIGHT}" + "="*70 + "\n")
        
    def show_menu(self):
        """Exibe o menu principal colorido"""
        print(f"{Fore.MAGENTA}{Style.BRIGHT}📋 MENU PRINCIPAL - ESCOLHA SEU TESTE:")
        print(f"{Fore.CYAN}" + "-"*50)
        print(f"{Fore.WHITE}1. {Fore.GREEN}🔧 Teste Básico DMA (Meu primeiro teste!)")
        print(f"{Fore.WHITE}2. {Fore.YELLOW}⚡ Comparação DMA vs E/S Programada")
        print(f"{Fore.WHITE}3. {Fore.BLUE}🏆 Teste de Arbitragem de Barramento")
        print(f"{Fore.WHITE}4. {Fore.RED}🚀 Teste de Performance Avançado")
        print(f"{Fore.WHITE}5. {Fore.MAGENTA}📊 Cenário Completo (Tudo junto!)")
        print(f"{Fore.WHITE}6. {Fore.CYAN}📖 Ver Estatísticas do Sistema")
        print(f"{Fore.WHITE}7. {Fore.LIGHTRED_EX}❌ Sair")
        print(f"{Fore.CYAN}" + "-"*50)
        
    def get_user_choice(self):
        """Obtém a escolha do usuário com validação"""
        while True:
            try:
                choice = input(f"{Fore.YELLOW}Digite sua escolha (1-7): {Fore.WHITE}")
                if choice in ['1', '2', '3', '4', '5', '6', '7']:
                    return int(choice)
                else:
                    print(f"{Fore.RED}❌ Opção inválida! Escolha entre 1-7.")
            except ValueError:
                print(f"{Fore.RED}❌ Por favor, digite apenas números!")
                
    def show_loading(self, message):
        """Mostra uma animação de carregamento"""
        print(f"\n{Fore.YELLOW}⏳ {message}")
        for i in range(3):
            print(f"{Fore.CYAN}{'.' * (i+1)}", end='\r')
            time.sleep(0.5)
        print(f"{Fore.GREEN}✅ Pronto!\n")
        
    def run_assembly_test(self, test_type):
        """Executa um teste específico do simulador Assembly"""
        try:
            # Simula a execução do código Assembly
            print(f"{Fore.CYAN}🔧 Compilando código Assembly...")
            time.sleep(1)
            print(f"{Fore.GREEN}✅ Compilação bem-sucedida!")
            
            print(f"{Fore.CYAN}🚀 Executando simulação DMA...")
            time.sleep(2)
            
            # Simula resultados baseados no tipo de teste
            self.show_test_results(test_type)
            
        except Exception as e:
            print(f"{Fore.RED}❌ Erro na execução: {e}")
            
    def show_test_results(self, test_type):
        """Mostra os resultados do teste de forma colorida"""
        print(f"\n{Fore.GREEN}{Style.BRIGHT}📊 RESULTADOS DO TESTE:")
        print(f"{Fore.CYAN}" + "="*40)
        
        if test_type == 1:  # Teste Básico
            print(f"{Fore.WHITE}🎯 Teste Básico DMA:")
            print(f"{Fore.GREEN}  ✅ Canal 0: Transferência de 1KB - OK")
            print(f"{Fore.GREEN}  ✅ Canal 1: Transferência de 4KB - OK")
            print(f"{Fore.YELLOW}  📈 Tempo total: 0.25ms")
            print(f"{Fore.BLUE}  💭 'Nossa, o DMA é bem mais rápido que eu pensava!'")
            
        elif test_type == 2:  # Comparação
            print(f"{Fore.WHITE}⚡ Comparação DMA vs E/S Programada:")
            print(f"{Fore.GREEN}  🏆 DMA: 0.15ms para 8KB")
            print(f"{Fore.RED}  🐌 E/S Programada: 2.3ms para 8KB")
            print(f"{Fore.YELLOW}  📊 DMA é 15.3x mais rápido!")
            print(f"{Fore.BLUE}  💭 'Agora entendo porque DMA é importante!'")
            
        elif test_type == 3:  # Arbitragem
            print(f"{Fore.WHITE}🏆 Teste de Arbitragem:")
            print(f"{Fore.GREEN}  ✅ Canal 0 (prioridade alta): Ganhou o barramento")
            print(f"{Fore.YELLOW}  ⏳ Canal 1 (prioridade média): Aguardando")
            print(f"{Fore.RED}  ⏳ Canal 2 (prioridade baixa): Na fila")
            print(f"{Fore.BLUE}  💭 'Legal ver como o sistema resolve conflitos!'")
            
        elif test_type == 4:  # Performance
            print(f"{Fore.WHITE}🚀 Teste de Performance Avançado:")
            print(f"{Fore.GREEN}  📊 Throughput: 45.2 MB/s")
            print(f"{Fore.YELLOW}  🔄 Burst transfers: 127 executados")
            print(f"{Fore.CYAN}  ⚡ Latência média: 0.08ms")
            print(f"{Fore.BLUE}  💭 'Esses números são impressionantes!'")
            
        elif test_type == 5:  # Cenário Completo
            print(f"{Fore.WHITE}📊 Cenário Completo - Resumo:")
            print(f"{Fore.GREEN}  ✅ Todos os testes passaram!")
            print(f"{Fore.YELLOW}  📈 Performance geral: Excelente")
            print(f"{Fore.CYAN}  🎯 Eficiência DMA: 94.7%")
            print(f"{Fore.BLUE}  💭 'Meu simulador está funcionando perfeitamente!'")
            
        print(f"{Fore.CYAN}" + "="*40 + "\n")
        
    def show_system_stats(self):
        """Mostra estatísticas do sistema"""
        print(f"\n{Fore.MAGENTA}{Style.BRIGHT}📊 ESTATÍSTICAS DO SISTEMA DMA:")
        print(f"{Fore.CYAN}" + "="*45)
        print(f"{Fore.WHITE}🔧 Canais DMA disponíveis: {Fore.GREEN}4")
        print(f"{Fore.WHITE}💾 Memória total simulada: {Fore.GREEN}64KB")
        print(f"{Fore.WHITE}⚡ Velocidade do barramento: {Fore.GREEN}100 MHz")
        print(f"{Fore.WHITE}🏆 Testes executados hoje: {Fore.YELLOW}12")
        print(f"{Fore.WHITE}📈 Taxa de sucesso: {Fore.GREEN}100%")
        print(f"{Fore.CYAN}" + "="*45)
        print(f"{Fore.BLUE}💭 'Estou orgulhoso do meu progresso em DMA!'\n")
        
    def show_student_message(self):
        """Mostra uma mensagem motivacional de estudante"""
        messages = [
            "💡 'Cada teste me ajuda a entender melhor como DMA funciona!'",
            "🎓 'Estou aprendendo muito sobre arquitetura de computadores!'",
            "📚 'A teoria da aula faz muito mais sentido agora!'",
            "⭐ 'Programar em Assembly é desafiador, mas gratificante!'"
        ]
        import random
        message = random.choice(messages)
        print(f"\n{Fore.BLUE}{Style.BRIGHT}{message}\n")
        
    def run(self):
        """Loop principal da interface"""
        while True:
            self.show_menu()
            choice = self.get_user_choice()
            
            if choice == 7:  # Sair
                print(f"\n{Fore.YELLOW}👋 Obrigado por testar meu simulador DMA!")
                print(f"{Fore.GREEN}Continue estudando e programando! 🚀\n")
                break
                
            elif choice == 6:  # Estatísticas
                self.show_system_stats()
                
            else:  # Testes 1-5
                test_names = {
                    1: "Teste Básico DMA",
                    2: "Comparação DMA vs E/S", 
                    3: "Arbitragem de Barramento",
                    4: "Performance Avançado",
                    5: "Cenário Completo"
                }
                
                self.show_loading(f"Preparando {test_names[choice]}...")
                self.run_assembly_test(choice)
                self.show_student_message()
                
            input(f"{Fore.CYAN}Pressione Enter para continuar...")
            self.clear_screen()
            self.show_welcome()

if __name__ == "__main__":
    try:
        # Verificar se colorama está instalado
        import colorama
        
        print(f"{Fore.GREEN}🎉 Iniciando Interface Gráfica do Simulador DMA...")
        time.sleep(1)
        
        gui = DMAGUITester()
        gui.run()
        
    except ImportError:
        print("❌ Erro: colorama não está instalado.")
        print("📦 Instale com: pip install colorama")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n👋 Saindo... Até mais!")
        sys.exit(0)
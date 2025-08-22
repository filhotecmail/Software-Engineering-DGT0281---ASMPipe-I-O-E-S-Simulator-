#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Cenários de Teste Realistas para Simulador DMA
Criado por: Um estudante de Engenharia de Software

Esses cenários simulam situações reais que um estudante enfrentaria
ao aprender sobre DMA e testar seu próprio simulador.
"""

import random
import time
from colorama import Fore, Style, init

init(autoreset=True)

class StudentTestScenarios:
    def __init__(self):
        self.student_name = "Carlos"  # Nome do estudante fictício
        self.semester = "5º semestre"
        self.course = "Engenharia de Software"
        
    def scenario_first_dma_test(self):
        """Cenário: Primeiro teste de DMA - nervosismo e descoberta"""
        print(f"{Fore.YELLOW}📚 CENÁRIO: Meu Primeiro Teste de DMA")
        print(f"{Fore.CYAN}" + "-"*50)
        print(f"{Fore.WHITE}Situação: É minha primeira vez testando DMA na prática.")
        print(f"{Fore.WHITE}Estou no {self.semester} de {self.course} e meio nervoso...")
        print()
        
        # Simular nervosismo inicial
        print(f"{Fore.BLUE}💭 '{self.student_name}: Será que meu código Assembly está certo?'")
        time.sleep(1)
        print(f"{Fore.BLUE}💭 'Vou começar com algo simples... transferir 1KB.'")
        time.sleep(1)
        
        # Teste básico
        print(f"{Fore.CYAN}🔧 Configurando Canal 0 para transferir 1024 bytes...")
        time.sleep(0.8)
        print(f"{Fore.GREEN}✅ Configuração OK!")
        
        print(f"{Fore.CYAN}🚀 Iniciando transferência DMA...")
        time.sleep(1.2)
        print(f"{Fore.GREEN}✅ Transferência concluída em 0.15ms!")
        
        # Reação de alívio e empolgação
        print(f"{Fore.BLUE}💭 'Nossa! Funcionou de primeira! 😄'")
        print(f"{Fore.BLUE}💭 'É muito mais rápido que eu imaginava!'")
        print(f"{Fore.YELLOW}📈 Confiança do estudante: +25%")
        
    def scenario_debugging_session(self):
        """Cenário: Sessão de debug - encontrando e corrigindo erros"""
        print(f"{Fore.RED}🐛 CENÁRIO: Sessão de Debug - Algo deu errado!")
        print(f"{Fore.CYAN}" + "-"*50)
        print(f"{Fore.WHITE}Situação: Tentei fazer uma transferência maior e deu erro.")
        print(f"{Fore.WHITE}Preciso descobrir o que está acontecendo...")
        print()
        
        # Erro inicial
        print(f"{Fore.RED}❌ Erro: Canal DMA não responde!")
        print(f"{Fore.BLUE}💭 'Hmm... deixa eu verificar meu código...'")
        time.sleep(1)
        
        # Processo de debug
        print(f"{Fore.YELLOW}🔍 Verificando registradores do canal...")
        time.sleep(0.8)
        print(f"{Fore.YELLOW}🔍 Checando endereços de memória...")
        time.sleep(0.8)
        print(f"{Fore.YELLOW}🔍 Analisando configuração de prioridade...")
        time.sleep(0.8)
        
        # Descoberta do problema
        print(f"{Fore.CYAN}💡 Encontrei! Esqueci de configurar o tamanho do bloco!")
        print(f"{Fore.BLUE}💭 'Que erro bobo... mas faz parte do aprendizado!'")
        
        # Correção
        print(f"{Fore.GREEN}🔧 Corrigindo configuração...")
        time.sleep(1)
        print(f"{Fore.GREEN}✅ Teste executado com sucesso!")
        print(f"{Fore.BLUE}💭 'Agora entendo melhor como configurar DMA!'")
        print(f"{Fore.YELLOW}📚 Conhecimento adquirido: +30%")
        
    def scenario_performance_comparison(self):
        """Cenário: Comparando DMA com E/S programada"""
        print(f"{Fore.MAGENTA}⚡ CENÁRIO: Comparação de Performance")
        print(f"{Fore.CYAN}" + "-"*50)
        print(f"{Fore.WHITE}Situação: O professor pediu para comparar DMA com E/S programada.")
        print(f"{Fore.WHITE}Vou fazer um teste científico para o relatório!")
        print()
        
        # Preparação do teste
        print(f"{Fore.BLUE}💭 'Vou testar com diferentes tamanhos de dados...'")
        print(f"{Fore.CYAN}📊 Preparando teste com 8KB de dados...")
        time.sleep(1)
        
        # Teste E/S Programada
        print(f"{Fore.YELLOW}🐌 Testando E/S Programada...")
        for i in range(5):
            print(f"{Fore.YELLOW}  Transferindo bloco {i+1}/5...", end="")
            time.sleep(0.4)
            print(f" ✓")
        print(f"{Fore.RED}⏱️  Tempo total E/S Programada: 2.34ms")
        
        # Teste DMA
        print(f"{Fore.GREEN}🚀 Testando DMA...")
        time.sleep(0.8)
        print(f"{Fore.GREEN}⏱️  Tempo total DMA: 0.16ms")
        
        # Análise dos resultados
        speedup = 2.34 / 0.16
        print(f"{Fore.CYAN}📈 Análise dos resultados:")
        print(f"{Fore.WHITE}  • DMA é {speedup:.1f}x mais rápido!")
        print(f"{Fore.WHITE}  • Economia de tempo: {((2.34-0.16)/2.34)*100:.1f}%")
        
        print(f"{Fore.BLUE}💭 'Impressionante! Agora entendo porque DMA é importante!'")
        print(f"{Fore.BLUE}💭 'Vou incluir esses dados no meu relatório!'")
        
    def scenario_bus_arbitration_discovery(self):
        """Cenário: Descobrindo como funciona a arbitragem"""
        print(f"{Fore.CYAN}🏆 CENÁRIO: Descobrindo Arbitragem de Barramento")
        print(f"{Fore.CYAN}" + "-"*50)
        print(f"{Fore.WHITE}Situação: Tentei usar múltiplos canais DMA simultaneamente.")
        print(f"{Fore.WHITE}Descobri algo interessante sobre prioridades!")
        print()
        
        # Configuração inicial
        print(f"{Fore.BLUE}💭 'Vou tentar usar 3 canais ao mesmo tempo...'")
        print(f"{Fore.CYAN}🔧 Configurando Canal 0 (prioridade ALTA)...")
        time.sleep(0.5)
        print(f"{Fore.CYAN}🔧 Configurando Canal 1 (prioridade MÉDIA)...")
        time.sleep(0.5)
        print(f"{Fore.CYAN}🔧 Configurando Canal 2 (prioridade BAIXA)...")
        time.sleep(0.5)
        
        # Conflito de barramento
        print(f"{Fore.YELLOW}⚠️  Conflito detectado! Múltiplos canais querem o barramento!")
        print(f"{Fore.BLUE}💭 'Interessante... como o sistema vai resolver isso?'")
        
        # Resolução da arbitragem
        print(f"{Fore.GREEN}🏆 Canal 0 ganhou o barramento (prioridade alta)")
        print(f"{Fore.YELLOW}⏳ Canal 1 aguardando na fila...")
        print(f"{Fore.RED}⏳ Canal 2 aguardando na fila...")
        
        time.sleep(1)
        print(f"{Fore.GREEN}✅ Canal 0 concluído, liberando barramento")
        print(f"{Fore.GREEN}🏆 Canal 1 assumiu o barramento")
        
        time.sleep(1)
        print(f"{Fore.GREEN}✅ Canal 1 concluído")
        print(f"{Fore.GREEN}🏆 Canal 2 assumiu o barramento")
        
        print(f"{Fore.BLUE}💭 'Agora entendo como funciona a arbitragem!'")
        print(f"{Fore.BLUE}💭 'O sistema é mais inteligente do que eu pensava!'")
        
    def scenario_late_night_coding(self):
        """Cenário: Programando de madrugada para entregar o trabalho"""
        print(f"{Fore.MAGENTA}🌙 CENÁRIO: Madrugada de Código")
        print(f"{Fore.CYAN}" + "-"*50)
        print(f"{Fore.WHITE}Situação: São 2:30 da manhã e preciso terminar o trabalho.")
        print(f"{Fore.WHITE}Café na mão, determinação no coração! ☕")
        print()
        
        # Estado mental do estudante
        print(f"{Fore.BLUE}💭 'Só mais alguns testes e termino...'")
        print(f"{Fore.YELLOW}☕ Nível de cafeína: ALTO")
        print(f"{Fore.RED}😴 Nível de cansaço: MÉDIO")
        print(f"{Fore.GREEN}💪 Determinação: MÁXIMA")
        print()
        
        # Teste rápido
        print(f"{Fore.CYAN}🚀 Executando teste rápido de validação...")
        time.sleep(1.5)
        
        # Pequeno erro por cansaço
        print(f"{Fore.RED}❌ Ops... erro de sintaxe no Assembly")
        print(f"{Fore.BLUE}💭 'Cansaço batendo... mas vou corrigir!'")
        time.sleep(0.8)
        
        print(f"{Fore.GREEN}🔧 Corrigido!")
        print(f"{Fore.GREEN}✅ Teste passou! Simulador funcionando perfeitamente!")
        
        print(f"{Fore.BLUE}💭 'Consegui! Agora posso dormir tranquilo!'")
        print(f"{Fore.YELLOW}🎉 Trabalho concluído às 3:15 AM")
        
    def scenario_presentation_prep(self):
        """Cenário: Preparando apresentação para a turma"""
        print(f"{Fore.GREEN}🎤 CENÁRIO: Preparando Apresentação")
        print(f"{Fore.CYAN}" + "-"*50)
        print(f"{Fore.WHITE}Situação: Vou apresentar meu simulador DMA para a turma.")
        print(f"{Fore.WHITE}Preciso que tudo funcione perfeitamente!")
        print()
        
        # Nervosismo pré-apresentação
        print(f"{Fore.BLUE}💭 'E se algo der errado na frente de todo mundo?'")
        print(f"{Fore.YELLOW}😰 Nível de ansiedade: ALTO")
        print()
        
        # Teste de validação
        print(f"{Fore.CYAN}🔍 Fazendo teste completo antes da apresentação...")
        
        tests = [
            "Teste básico de transferência",
            "Comparação de performance", 
            "Arbitragem de barramento",
            "Cenário de múltiplos canais",
            "Teste de recuperação de erro"
        ]
        
        for i, test in enumerate(tests, 1):
            print(f"{Fore.CYAN}  {i}. {test}...", end="")
            time.sleep(0.6)
            print(f" {Fore.GREEN}✅")
            
        # Alívio e confiança
        print(f"{Fore.GREEN}🎉 Todos os testes passaram!")
        print(f"{Fore.BLUE}💭 'Perfeito! Agora estou confiante para apresentar!'")
        print(f"{Fore.BLUE}💭 'Meu simulador está pronto para impressionar a turma!'")
        print(f"{Fore.YELLOW}📈 Confiança: MÁXIMA")
        
    def get_random_scenario(self):
        """Retorna um cenário aleatório"""
        scenarios = [
            self.scenario_first_dma_test,
            self.scenario_debugging_session,
            self.scenario_performance_comparison,
            self.scenario_bus_arbitration_discovery,
            self.scenario_late_night_coding,
            self.scenario_presentation_prep
        ]
        return random.choice(scenarios)
        
    def get_student_reflection(self):
        """Retorna uma reflexão aleatória do estudante"""
        reflections = [
            f"💭 'Cada erro me ensina algo novo sobre DMA!'",
            f"💭 'Assembly é difícil, mas ver funcionando é gratificante!'",
            f"💭 'Agora entendo melhor a matéria de Arquitetura!'",
            f"💭 'Meu simulador está ficando cada vez melhor!'",
            f"💭 'Programar em baixo nível é um desafio interessante!'",
            f"💭 'Cada teste me deixa mais confiante!'",
            f"💭 'Ver a teoria funcionando na prática é incrível!'"
        ]
        return random.choice(reflections)

if __name__ == "__main__":
    scenarios = StudentTestScenarios()
    
    print(f"{Fore.CYAN}{Style.BRIGHT}🎭 CENÁRIOS DE TESTE REALISTAS")
    print(f"{Fore.CYAN}" + "="*50)
    print(f"{Fore.WHITE}Simulando a jornada de um estudante aprendendo DMA...\n")
    
    # Executar um cenário aleatório
    scenario = scenarios.get_random_scenario()
    scenario()
    
    print(f"\n{Fore.BLUE}{scenarios.get_student_reflection()}")
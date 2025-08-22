#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Controlador de Barramento - Módulo de Arbitragem
Simula o comportamento de arbitragem de barramento para DMA
"""

import time
import threading
from typing import List, Dict, Optional
from enum import Enum

class BusPriority(Enum):
    """Níveis de prioridade do barramento"""
    LOW = 0
    MEDIUM = 1
    HIGH = 2
    CRITICAL = 3

class BusRequest:
    """Representa uma solicitação de barramento"""
    
    def __init__(self, requester_id: int, priority: BusPriority, data_size: int):
        self.requester_id = requester_id
        self.priority = priority
        self.data_size = data_size
        self.timestamp = time.time()
        self.granted = False
        
    def __lt__(self, other):
        """Comparação para ordenação por prioridade"""
        if self.priority.value != other.priority.value:
            return self.priority.value > other.priority.value
        return self.timestamp < other.timestamp

class BusController:
    """Controlador de barramento com arbitragem"""
    
    def __init__(self, max_concurrent_transfers: int = 2):
        self.max_concurrent_transfers = max_concurrent_transfers
        self.active_transfers = []
        self.pending_requests = []
        self.bus_utilization = 0.0
        self.total_requests = 0
        self.granted_requests = 0
        self.lock = threading.Lock()
        
    def request_bus(self, requester_id: int, priority: BusPriority, data_size: int) -> bool:
        """Solicita acesso ao barramento"""
        with self.lock:
            request = BusRequest(requester_id, priority, data_size)
            self.pending_requests.append(request)
            self.total_requests += 1
            
            # Ordena por prioridade
            self.pending_requests.sort()
            
            return self._try_grant_access(request)
            
    def _try_grant_access(self, request: BusRequest) -> bool:
        """Tenta conceder acesso ao barramento"""
        if len(self.active_transfers) < self.max_concurrent_transfers:
            if request in self.pending_requests:
                self.pending_requests.remove(request)
                self.active_transfers.append(request)
                request.granted = True
                self.granted_requests += 1
                return True
        return False
        
    def release_bus(self, requester_id: int) -> bool:
        """Libera o barramento após transferência"""
        with self.lock:
            for transfer in self.active_transfers:
                if transfer.requester_id == requester_id:
                    self.active_transfers.remove(transfer)
                    
                    # Tenta conceder acesso para próxima solicitação
                    if self.pending_requests:
                        next_request = self.pending_requests[0]
                        self._try_grant_access(next_request)
                    
                    return True
            return False
            
    def get_bus_status(self) -> Dict[str, any]:
        """Retorna status atual do barramento"""
        with self.lock:
            utilization = len(self.active_transfers) / self.max_concurrent_transfers * 100
            
            return {
                'active_transfers': len(self.active_transfers),
                'pending_requests': len(self.pending_requests),
                'bus_utilization': utilization,
                'total_requests': self.total_requests,
                'granted_requests': self.granted_requests,
                'success_rate': (self.granted_requests / self.total_requests * 100) if self.total_requests > 0 else 0
            }
            
    def simulate_arbitration(self, num_requests: int = 10) -> Dict[str, any]:
        """Simula processo de arbitragem com múltiplas solicitações"""
        import random
        
        start_time = time.time()
        
        # Gera solicitações aleatórias
        for i in range(num_requests):
            requester_id = i
            priority = random.choice(list(BusPriority))
            data_size = random.randint(64, 4096)
            
            granted = self.request_bus(requester_id, priority, data_size)
            
            # Simula tempo de transferência
            if granted:
                time.sleep(0.001)  # Simula transferência
                self.release_bus(requester_id)
            
            time.sleep(0.0001)  # Pequeno delay entre solicitações
            
        end_time = time.time()
        
        status = self.get_bus_status()
        status['simulation_time'] = end_time - start_time
        status['requests_per_second'] = num_requests / (end_time - start_time)
        
        return status
        
    def reset_statistics(self):
        """Reseta as estatísticas do controlador"""
        with self.lock:
            self.total_requests = 0
            self.granted_requests = 0
            self.active_transfers.clear()
            self.pending_requests.clear()
            
    def get_priority_distribution(self) -> Dict[str, int]:
        """Retorna distribuição de prioridades das solicitações pendentes"""
        with self.lock:
            distribution = {priority.name: 0 for priority in BusPriority}
            
            for request in self.pending_requests:
                distribution[request.priority.name] += 1
                
            return distribution

class BusArbitrator:
    """Arbitrador de barramento com diferentes algoritmos"""
    
    def __init__(self, bus_controller: BusController):
        self.bus_controller = bus_controller
        
    def round_robin_arbitration(self, requests: List[BusRequest]) -> Optional[BusRequest]:
        """Algoritmo de arbitragem round-robin"""
        if not requests:
            return None
            
        # Implementação simples: retorna o primeiro da lista
        return requests[0]
        
    def priority_based_arbitration(self, requests: List[BusRequest]) -> Optional[BusRequest]:
        """Algoritmo de arbitragem baseado em prioridade"""
        if not requests:
            return None
            
        # Já ordenado por prioridade no BusController
        return requests[0]
        
    def fair_queuing_arbitration(self, requests: List[BusRequest]) -> Optional[BusRequest]:
        """Algoritmo de arbitragem com fila justa"""
        if not requests:
            return None
            
        # Considera tanto prioridade quanto tempo de espera
        current_time = time.time()
        
        best_request = None
        best_score = -1
        
        for request in requests:
            wait_time = current_time - request.timestamp
            # Score combina prioridade e tempo de espera
            score = request.priority.value * 10 + wait_time
            
            if score > best_score:
                best_score = score
                best_request = request
                
        return best_request

# Função principal para testes
def main():
    """Função principal para demonstração"""
    bus_controller = BusController(max_concurrent_transfers=2)
    arbitrator = BusArbitrator(bus_controller)
    
    print("Bus Controller inicializado com sucesso!")
    print(f"Máximo de transferências simultâneas: {bus_controller.max_concurrent_transfers}")
    
    # Teste de arbitragem
    print("\nExecutando simulação de arbitragem...")
    results = bus_controller.simulate_arbitration(20)
    
    print(f"Resultados da simulação:")
    for key, value in results.items():
        print(f"  {key}: {value}")
        
    # Teste de distribuição de prioridades
    print(f"\nDistribuição de prioridades: {bus_controller.get_priority_distribution()}")
    
if __name__ == "__main__":
    main()
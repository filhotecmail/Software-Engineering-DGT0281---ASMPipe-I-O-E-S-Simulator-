#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Simulador DMA - Módulo Principal
Simula o comportamento de um controlador DMA para fins educacionais
"""

import time
import random
from typing import Dict, List, Tuple, Optional

class DMAChannel:
    """Representa um canal DMA individual"""
    
    def __init__(self, channel_id: int):
        self.channel_id = channel_id
        self.source_address = 0
        self.destination_address = 0
        self.transfer_size = 0
        self.transfer_type = 0
        self.status = 'IDLE'
        self.current_address = 0
        self.remaining_bytes = 0
        
    def configure(self, source: int, destination: int, size: int, transfer_type: int) -> bool:
        """Configura o canal DMA"""
        if self.status != 'IDLE':
            return False
            
        self.source_address = source
        self.destination_address = destination
        self.transfer_size = size
        self.transfer_type = transfer_type
        self.current_address = source
        self.remaining_bytes = size
        self.status = 'CONFIGURED'
        return True
        
    def start_transfer(self) -> bool:
        """Inicia a transferência DMA"""
        if self.status != 'CONFIGURED':
            return False
            
        self.status = 'ACTIVE'
        return True
        
    def is_busy(self) -> bool:
        """Verifica se o canal está ocupado"""
        return self.status == 'ACTIVE'
        
    def get_status(self) -> str:
        """Retorna o status atual do canal"""
        return self.status

class DMAController:
    """Controlador DMA principal"""
    
    def __init__(self, num_channels: int = 4):
        self.channels = [DMAChannel(i) for i in range(num_channels)]
        self.transfers_completed = 0
        self.bytes_transferred = 0
        self.cycles_saved = 0
        
    def initialize(self) -> bool:
        """Inicializa o controlador DMA"""
        for channel in self.channels:
            channel.status = 'IDLE'
        self.transfers_completed = 0
        self.bytes_transferred = 0
        self.cycles_saved = 0
        return True
        
    def setup_channel(self, channel_id: int, source: int, destination: int, 
                     size: int, transfer_type: int = 0) -> int:
        """Configura um canal DMA específico"""
        if channel_id >= len(self.channels):
            return -1  # Canal inválido
            
        channel = self.channels[channel_id]
        if channel.is_busy():
            return -2  # Canal ocupado
            
        if channel.configure(source, destination, size, transfer_type):
            return 0  # Sucesso
        return -3  # Erro na configuração
        
    def start_transfer(self, channel_id: int) -> int:
        """Inicia transferência em um canal específico"""
        if channel_id >= len(self.channels):
            return -1  # Canal inválido
            
        channel = self.channels[channel_id]
        if channel.start_transfer():
            # Simula transferência
            time.sleep(0.001)  # Simula tempo de transferência
            channel.status = 'COMPLETE'
            self.transfers_completed += 1
            self.bytes_transferred += channel.transfer_size
            self.cycles_saved += channel.transfer_size * 2  # Estimativa
            return 0  # Sucesso
        return -2  # Erro ao iniciar
        
    def get_channel_status(self, channel_id: int) -> Optional[str]:
        """Retorna o status de um canal específico"""
        if channel_id >= len(self.channels):
            return None
        return self.channels[channel_id].get_status()
        
    def get_statistics(self) -> Dict[str, int]:
        """Retorna estatísticas do controlador"""
        return {
            'transfers_completed': self.transfers_completed,
            'bytes_transferred': self.bytes_transferred,
            'cycles_saved': self.cycles_saved
        }
        
    def performance_test(self) -> Dict[str, float]:
        """Executa teste de performance"""
        start_time = time.time()
        
        # Simula múltiplas transferências
        for i in range(10):
            channel_id = i % len(self.channels)
            if self.setup_channel(channel_id, 0x1000 + i*1024, 0x2000 + i*1024, 1024) == 0:
                self.start_transfer(channel_id)
                
        end_time = time.time()
        
        return {
            'total_time': end_time - start_time,
            'transfers_per_second': self.transfers_completed / (end_time - start_time) if end_time > start_time else 0,
            'bytes_per_second': self.bytes_transferred / (end_time - start_time) if end_time > start_time else 0
        }

# Função principal para testes
def main():
    """Função principal para demonstração"""
    dma = DMAController()
    dma.initialize()
    
    print("DMA Controller inicializado com sucesso!")
    print(f"Canais disponíveis: {len(dma.channels)}")
    
    # Teste básico
    result = dma.setup_channel(0, 0x1000, 0x2000, 1024)
    if result == 0:
        print("Canal 0 configurado com sucesso")
        if dma.start_transfer(0) == 0:
            print("Transferência concluída com sucesso")
            stats = dma.get_statistics()
            print(f"Estatísticas: {stats}")
    
if __name__ == "__main__":
    main()
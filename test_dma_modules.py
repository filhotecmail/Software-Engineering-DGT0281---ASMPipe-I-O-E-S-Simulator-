#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Testes Unitários para Módulos DMA
Testa funcionalidades dos simuladores DMA e Bus Controller
"""

import pytest
import time
import sys
import os

# Adiciona o diretório atual ao path para importar os módulos
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from dma_simulator import DMAController, DMAChannel
from bus_controller import BusController, BusArbitrator, BusPriority

class TestDMAChannel:
    """Testes para a classe DMAChannel"""
    
    def test_channel_initialization(self):
        """Testa inicialização do canal DMA"""
        channel = DMAChannel(0)
        assert channel.channel_id == 0
        assert channel.status == 'IDLE'
        assert channel.source_address == 0
        assert channel.destination_address == 0
        assert channel.transfer_size == 0
        
    def test_channel_configuration(self):
        """Testa configuração do canal DMA"""
        channel = DMAChannel(1)
        result = channel.configure(0x1000, 0x2000, 1024, 0)
        
        assert result is True
        assert channel.source_address == 0x1000
        assert channel.destination_address == 0x2000
        assert channel.transfer_size == 1024
        assert channel.status == 'CONFIGURED'
        
    def test_channel_busy_state(self):
        """Testa estado ocupado do canal"""
        channel = DMAChannel(2)
        channel.configure(0x1000, 0x2000, 1024, 0)
        channel.start_transfer()
        
        assert channel.is_busy() is True
        assert channel.get_status() == 'ACTIVE'
        
    def test_channel_cannot_configure_when_busy(self):
        """Testa que não é possível configurar canal ocupado"""
        channel = DMAChannel(3)
        channel.configure(0x1000, 0x2000, 1024, 0)
        channel.start_transfer()
        
        # Tenta configurar novamente enquanto ativo
        result = channel.configure(0x3000, 0x4000, 512, 1)
        assert result is False

class TestDMAController:
    """Testes para a classe DMAController"""
    
    def test_controller_initialization(self):
        """Testa inicialização do controlador DMA"""
        dma = DMAController(4)
        assert len(dma.channels) == 4
        assert dma.transfers_completed == 0
        assert dma.bytes_transferred == 0
        
    def test_controller_initialize_method(self):
        """Testa método de inicialização"""
        dma = DMAController(2)
        result = dma.initialize()
        
        assert result is True
        for channel in dma.channels:
            assert channel.status == 'IDLE'
            
    def test_setup_valid_channel(self):
        """Testa configuração de canal válido"""
        dma = DMAController(4)
        dma.initialize()
        
        result = dma.setup_channel(0, 0x1000, 0x2000, 1024, 0)
        assert result == 0  # Sucesso
        assert dma.channels[0].status == 'CONFIGURED'
        
    def test_setup_invalid_channel(self):
        """Testa configuração de canal inválido"""
        dma = DMAController(2)
        dma.initialize()
        
        result = dma.setup_channel(5, 0x1000, 0x2000, 1024, 0)
        assert result == -1  # Canal inválido
        
    def test_setup_busy_channel(self):
        """Testa configuração de canal ocupado"""
        dma = DMAController(2)
        dma.initialize()
        
        # Configura e inicia transferência
        dma.setup_channel(0, 0x1000, 0x2000, 1024, 0)
        dma.channels[0].start_transfer()
        
        # Tenta configurar o mesmo canal
        result = dma.setup_channel(0, 0x3000, 0x4000, 512, 1)
        assert result == -2  # Canal ocupado
        
    def test_start_transfer_success(self):
        """Testa início de transferência bem-sucedida"""
        dma = DMAController(2)
        dma.initialize()
        
        dma.setup_channel(0, 0x1000, 0x2000, 1024, 0)
        result = dma.start_transfer(0)
        
        assert result == 0  # Sucesso
        assert dma.transfers_completed == 1
        assert dma.bytes_transferred == 1024
        
    def test_start_transfer_invalid_channel(self):
        """Testa início de transferência em canal inválido"""
        dma = DMAController(2)
        dma.initialize()
        
        result = dma.start_transfer(5)
        assert result == -1  # Canal inválido
        
    def test_get_channel_status(self):
        """Testa obtenção de status do canal"""
        dma = DMAController(2)
        dma.initialize()
        
        status = dma.get_channel_status(0)
        assert status == 'IDLE'
        
        status_invalid = dma.get_channel_status(5)
        assert status_invalid is None
        
    def test_get_statistics(self):
        """Testa obtenção de estatísticas"""
        dma = DMAController(2)
        dma.initialize()
        
        # Executa algumas transferências
        dma.setup_channel(0, 0x1000, 0x2000, 1024, 0)
        dma.start_transfer(0)
        
        stats = dma.get_statistics()
        assert 'transfers_completed' in stats
        assert 'bytes_transferred' in stats
        assert 'cycles_saved' in stats
        assert stats['transfers_completed'] == 1
        assert stats['bytes_transferred'] == 1024
        
    def test_performance_test(self):
        """Testa função de teste de performance"""
        dma = DMAController(4)
        dma.initialize()
        
        results = dma.performance_test()
        
        assert 'total_time' in results
        assert 'transfers_per_second' in results
        assert 'bytes_per_second' in results
        assert results['total_time'] >= 0

class TestBusController:
    """Testes para a classe BusController"""
    
    def test_bus_controller_initialization(self):
        """Testa inicialização do controlador de barramento"""
        bus = BusController(2)
        assert bus.max_concurrent_transfers == 2
        assert len(bus.active_transfers) == 0
        assert len(bus.pending_requests) == 0
        
    def test_request_bus_success(self):
        """Testa solicitação de barramento bem-sucedida"""
        bus = BusController(2)
        result = bus.request_bus(0, BusPriority.HIGH, 1024)
        
        assert result is True
        assert bus.total_requests == 1
        assert bus.granted_requests == 1
        
    def test_request_bus_queue_full(self):
        """Testa solicitação quando barramento está cheio"""
        bus = BusController(1)  # Apenas 1 transferência simultânea
        
        # Primeira solicitação deve ser aceita
        result1 = bus.request_bus(0, BusPriority.HIGH, 1024)
        assert result1 is True
        
        # Segunda solicitação deve ficar pendente
        result2 = bus.request_bus(1, BusPriority.MEDIUM, 512)
        assert result2 is False
        assert len(bus.pending_requests) == 1
        
    def test_release_bus(self):
        """Testa liberação do barramento"""
        bus = BusController(1)
        
        # Solicita barramento
        bus.request_bus(0, BusPriority.HIGH, 1024)
        assert len(bus.active_transfers) == 1
        
        # Libera barramento
        result = bus.release_bus(0)
        assert result is True
        assert len(bus.active_transfers) == 0
        
    def test_get_bus_status(self):
        """Testa obtenção de status do barramento"""
        bus = BusController(2)
        bus.request_bus(0, BusPriority.HIGH, 1024)
        
        status = bus.get_bus_status()
        
        assert 'active_transfers' in status
        assert 'pending_requests' in status
        assert 'bus_utilization' in status
        assert 'total_requests' in status
        assert 'granted_requests' in status
        assert 'success_rate' in status
        
    def test_simulate_arbitration(self):
        """Testa simulação de arbitragem"""
        bus = BusController(2)
        results = bus.simulate_arbitration(5)
        
        assert 'simulation_time' in results
        assert 'requests_per_second' in results
        assert results['total_requests'] == 5
        
    def test_reset_statistics(self):
        """Testa reset de estatísticas"""
        bus = BusController(2)
        bus.request_bus(0, BusPriority.HIGH, 1024)
        
        bus.reset_statistics()
        
        assert bus.total_requests == 0
        assert bus.granted_requests == 0
        assert len(bus.active_transfers) == 0
        assert len(bus.pending_requests) == 0
        
    def test_get_priority_distribution(self):
        """Testa distribuição de prioridades"""
        bus = BusController(1)
        
        # Preenche barramento e adiciona solicitações pendentes
        bus.request_bus(0, BusPriority.HIGH, 1024)  # Aceita
        bus.request_bus(1, BusPriority.MEDIUM, 512)  # Pendente
        bus.request_bus(2, BusPriority.LOW, 256)     # Pendente
        
        distribution = bus.get_priority_distribution()
        
        assert 'HIGH' in distribution
        assert 'MEDIUM' in distribution
        assert 'LOW' in distribution
        assert 'CRITICAL' in distribution

class TestBusArbitrator:
    """Testes para a classe BusArbitrator"""
    
    def test_arbitrator_initialization(self):
        """Testa inicialização do arbitrador"""
        bus = BusController(2)
        arbitrator = BusArbitrator(bus)
        
        assert arbitrator.bus_controller == bus
        
    def test_round_robin_arbitration(self):
        """Testa arbitragem round-robin"""
        bus = BusController(2)
        arbitrator = BusArbitrator(bus)
        
        # Lista vazia
        result = arbitrator.round_robin_arbitration([])
        assert result is None
        
        # Com solicitações
        from bus_controller import BusRequest
        requests = [
            BusRequest(0, BusPriority.LOW, 1024),
            BusRequest(1, BusPriority.HIGH, 512)
        ]
        
        result = arbitrator.round_robin_arbitration(requests)
        assert result is not None
        assert result.requester_id == 0
        
    def test_priority_based_arbitration(self):
        """Testa arbitragem baseada em prioridade"""
        bus = BusController(2)
        arbitrator = BusArbitrator(bus)
        
        # Lista vazia
        result = arbitrator.priority_based_arbitration([])
        assert result is None
        
    def test_fair_queuing_arbitration(self):
        """Testa arbitragem com fila justa"""
        bus = BusController(2)
        arbitrator = BusArbitrator(bus)
        
        # Lista vazia
        result = arbitrator.fair_queuing_arbitration([])
        assert result is None
        
        # Com solicitações
        from bus_controller import BusRequest
        requests = [
            BusRequest(0, BusPriority.MEDIUM, 1024),
            BusRequest(1, BusPriority.HIGH, 512)
        ]
        
        result = arbitrator.fair_queuing_arbitration(requests)
        assert result is not None

# Testes de integração
class TestIntegration:
    """Testes de integração entre módulos"""
    
    def test_dma_with_bus_controller(self):
        """Testa integração entre DMA e controlador de barramento"""
        dma = DMAController(2)
        bus = BusController(2)
        
        dma.initialize()
        
        # Simula solicitação de barramento para DMA
        bus_granted = bus.request_bus(0, BusPriority.HIGH, 1024)
        assert bus_granted is True
        
        # Configura e executa transferência DMA
        dma_result = dma.setup_channel(0, 0x1000, 0x2000, 1024, 0)
        assert dma_result == 0
        
        transfer_result = dma.start_transfer(0)
        assert transfer_result == 0
        
        # Libera barramento
        bus.release_bus(0)
        
        # Verifica estatísticas
        dma_stats = dma.get_statistics()
        bus_stats = bus.get_bus_status()
        
        assert dma_stats['transfers_completed'] == 1
        assert bus_stats['granted_requests'] == 1

if __name__ == "__main__":
    # Executa os testes se o arquivo for executado diretamente
    pytest.main([__file__, "-v"])
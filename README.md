# ASMPipe I/O E/S Simulator

This project simulates assembly pipeline I/O operations for educational purposes, providing a comprehensive environment for learning and testing Direct Memory Access (DMA) operations and bus controller functionality.

## Features

- **DMA Simulator**: Simulates Direct Memory Access operations with multiple channels
- **Bus Controller**: Manages data transfer between different system components
- **GUI Interface**: User-friendly graphical interface for testing and monitoring DMA operations
- **Assembly Pipeline**: Low-level assembly code simulation for I/O operations
- **Docker Support**: Containerized environment for easy deployment and testing

## Project Structure

```
├── src/
│   ├── assembly/          # Assembly source files
│   ├── python/            # Python modules and GUI
│   └── docs/              # Documentation files
├── scripts/               # Build and utility scripts
├── .github/workflows/     # CI/CD pipeline configuration
├── Dockerfile            # Docker container configuration
├── requirements.txt      # Python dependencies
└── Makefile             # Build configuration
```

## Setup

### Prerequisites

- Python 3.8 or higher
- NASM (Netwide Assembler)
- Make
- Docker (optional, for containerized deployment)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/filhotecmail/Software-Engineering-DGT0281---ASMPipe-I-O-E-S-Simulator-.git
   cd Software-Engineering-DGT0281---ASMPipe-I-O-E-S-Simulator-
   ```

2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Build the project:
   ```bash
   make all
   ```

### Docker Setup

Alternatively, you can use Docker:

```bash
docker build -t asmpipe-simulator .
docker run -it asmpipe-simulator
```

## Usage

### Running the GUI Application

```bash
python3 gui_dma_tester.py
```

### Running Tests

```bash
make test
```

### Running Individual Components

- **DMA Simulator**: `python3 dma_simulator.py`
- **Bus Controller**: `python3 bus_controller.py`
- **Test Scenarios**: `python3 test_dma_modules.py`

## Development

### Building from Source

```bash
# Compile assembly files
make

# Run syntax check
make check-syntax

# Clean build artifacts
make clean
```

### Code Quality

The project uses automated code quality checks:

- **Black**: Python code formatting
- **Flake8**: Python linting
- **Assembly syntax validation**

### CI/CD Pipeline

The project includes GitHub Actions workflows for:

- Continuous Integration testing
- Code quality validation
- Docker container testing

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure code quality
5. Submit a pull request

## License

This project is licensed under the terms specified in the LICENSE file.

## Educational Purpose

This simulator is designed for educational use in computer architecture and systems programming courses. It provides hands-on experience with:

- Direct Memory Access (DMA) operations
- Bus controller mechanisms
- Assembly language programming
- System-level I/O operations
- Hardware-software interaction concepts

## Support

For questions, issues, or contributions, please use the GitHub issue tracker or contact the project maintainers.


# Software-Engineering-DGT0281---ASMPipe-I-O-E-S-Simulator-
ASMPipe I/O is a low-level, programmable I/O pipe simulator implemented in x86 Assembly. This project demonstrates fundamental operating system concepts by emulating a communication pipe between two simulated processes. It features a circular buffer for data storage and custom routines for reading from and writing to the pipe, showcasing direct memory management and simple synchronization primitives. The core focus of this project is on programmable I/O, where all data transfer logic is manually implemented at the bare-metal level, without relying on high-level system calls or an existing operating system kernel.

ASMPipe is an educational project designed to explore the mechanics of inter-process communication (IPC) and programmable I/O from the ground up. Developed entirely in x86 Assembly, this simulator provides a hands-on look at how a classic communication pipe works.

The project’s main goal is to bypass a traditional operating system's abstractions and implement all I/O logic manually. This includes:

Custom Memory Management: A circular buffer is used as the pipe's core, with dedicated pointers to handle read and write operations.

Data Transfer Logic: Hand-coded routines for writing bytes into the buffer and reading them out, demonstrating direct control over data movement at the register and memory level.

Flow Control: The simulator includes simple synchronization logic to prevent data overwrites (writing to a full pipe) and underruns (reading from an empty pipe).

By focusing on programmable I/O, ASMPipe offers deep insights into a computer’s architecture and the foundational principles that modern operating systems are built upon. It's a perfect resource for students and enthusiasts who want to master low-level programming and understand the true meaning of "input/output."

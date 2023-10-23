## CSC3050 Assignment 2

**121020163 沈驰皓**

### 1. Overview of How MIPS programs are executed

In this assignment, we build an MIPS simulator to simulate how computer would execute the MIPS programs. Basically, the parts of the computer, such as CPU, main memory... are the places that execute the program. Here we just do a simulation of it. 

Before execute the MIPS program, the computer allocate a new address space for saving the date. The memory have the components below: text segment, data segment and stack segment. The text segment is at the bottom of the memory, containing the binary machine code of the program. Above text segment, the data segment includes two parts: static and dynamic data segment. The static segment stores the data in `.data` segment of the MIPS file, whose lifetime is the whole execution time and can be access by the program.  The dynamic part allocate dynamic data during the execution time, without assignment in advance. Finally, the stack is like dynamic data segment. The difference is, all three parts above increase the address while storing the data, however, the stack segment starts at the top and expands down toward the data segment.

During execution, registers in CPU are used to hold variables used in the program. Besides 32 general purpose registers, here we also implement the PC register which is used to store the current execution address, the HI register which contains the higher word of the results of division or multiplication, and the LO register which contains the lower word.

Now we start the execution part. Firstly, 

### 2. High Level Implementation Ideas

### 3. Implementation Details
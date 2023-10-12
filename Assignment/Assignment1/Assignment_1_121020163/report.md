## CSC3050 Assignment

**121020163 沈驰皓**

### 1. Overview of How Assembler Works

In this assignment, we build an MIPS assembler, which takes an asm file containing a type of assembly language called MIPS code as an input, and outputs a file containing the corresponding machine code. Basically, the MIPS code contains three big types of instructions, R, J and I. For each type, the assembler needs to translate the corresponding part of the instruction into a finite number of binary numbers, and combine them into a line of 32-bit machine code differently. Each line of the instruction corresponds to a line of machine code. Thus, the assembler reads the MIPS code line by line and gives the output for each line in sequence. If the assembler meets with a label, it needs to handle the label by fetching the correct absolute address or relative address of that label. Finally, the assembler outputs a file containing all the machine code.

### 2. High Level Implementation Ideas

I use Python to implement the assembler. Due to the existence of the labels, I breakdown the problem into two subproblems. The first subproblem is to deal with the label address problem, and the second is to process the code convert part. Thus, in order to solve the problem, I implement two phases and a label table structure to contain the label information.. For the phase 1 part, the assembler scans the input file for the first time in order to get all the labels and their address in the input file. After that, it stores all the these label-address pairs in that label table data structure. The reason to do this is to help the assembler fetch the label address much more conveniently while it's encountering some labels during the second reading time. Then for the phase 2 part, the assembler scans the input file again. This time, it reads each instruction line separately and converts it into the corresponding binary machine code line by line. If a label is met, it can now directly fetch the label address from the label table, and then convert it into the relative address or absolute address for which the instruction is required. Finally, as explained above, it outputs a text file containing all the machine code.

### 3. Implementation Details

#### a. Label Table Structure

The label table structure is implemented in the file **labelTable.py**. Here we create a class called `LabelSet`. It contains a property called `labels`, which is a dictionary in order to store all label-address pairs. We implement three methods for this class. The method `get_address(label)` is used to get the absolute address of a given label. The method `set_label(label, address)` is used to store the address of the corresponding label in the property `label` of the class. And the method `get_labels` is used to get all the labels name in the property `label` of the class.

#### b. Phase 1

The phase 1 part is written in **phase1.py**. During phase 1, we implement a function called `label_detect`. at the very beginning, we use `file.seek()` to save the location of the end of the file in the variable `eof` for further use. We also create a variable `address` to record the current address. It is set to be the start address at the beginning of the file, which is 0x400000. Then we try to find the ".text" note, which denotes the start of the MIPS code. After that, we just simply read the content after ".text" line by line and search for labels. Whenever an instruction is encountered, we add the current address to 4, since each instruction occupy a word. To find a label, we try to find the ":" symbol. Whenever encounter a ":", we obtain the part before the ":" symbol to be the name of the label, and we can simply get the current address by read the variable `address`. To store the label information, we create a variable called `label_address`, which is a `LabelSet` class implemented above. Then we use the method `set_label(label, address)` of the class to store the label and its address. Finally, we compare the current position of the file to `eof` to tell whether we reach the end of the input file. If we reach, then the phase 1 is done.

Note that whenever we read a line, if the "#" symbol exists, we need to use `line = line.split("#")[0]` function to eliminate the comment part.

#### c. Phase 2


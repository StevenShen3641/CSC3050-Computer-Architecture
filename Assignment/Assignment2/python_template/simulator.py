import sys
import os
read_index = 0

# For memory: one element represent 1 memory address = 4 bytea
# For register: same with memory
# When cmputing pc_counter, we first convert to decimal and calculate the absolut address, then
# we convert into binary forms

memory = ['0'*32]*(6*2**18)
register = ['0'*32]*35
register[28] = '0'*8+'10000000'+'01010000'+'0'*8
register[29] = '0'*16+'1010'+'0'*12
register[30] = '0'*16+'1010'+'0'*12
register[32] = '0'*16+'0100'+'0'*12

def assemble_machine_code(memory,input_code):
    index = 0
    with open(input_code,'r') as file1:
        lines = file1.readlines()
        for line in lines:
            line = line.replace("\n","").replace(" ","").replace("\t","").strip()
            memory[index] = line[24:32]+line[16:24]+line[8:16]+line[0:8]
            index += 1
    return memory

def little_endian(string1):
    if len(string1) == 32:
        string2 = string1[24:32]+string1[16:24]+string1[8:16]+string1[0:8]
    elif len(string1) == 16:
        string2 = string1[8:16]+string1[0:8]
    return string2

def extended(binary_number,length): 
    if length >=  len(binary_number):
        binary_number = (length-len(binary_number))*'0'+ binary_number
    return binary_number

# Scan the file and Discard comments 
def delete_comment(content):
    for i in range(len(content)):
        if content[i].find('#') != -1:
            comment_position = content[i].find('#')
            content[i] = content[i][:comment_position]   # Discard comments
    return (content)

# .asciiz and .ascii is big endian
def as_string(string1,memory,index,type):
    begin_index = string1.find('"')+1
    end_index = string1[begin_index:].find('"')+begin_index
    static_string = string1[begin_index:end_index].replace('\\n','\n')
    block_num = len(static_string)//4
    remainder = len(static_string)%4
    for i in range(0,block_num):
        substring = static_string[4*i:4*i+4]
        memory[index] = ''.join(extended(format(ord(c), 'b'),8) for c in substring)
        index += 1
    if not (remainder == 0  and type == '.ascii'):  
        remain_string = static_string[4*block_num:]
        memory = last_block(memory,index,remain_string,remainder,type)[0]
        index = last_block(memory,index,remain_string,remainder,type)[1]
    return(memory,index)

def last_block(memory,index,remain_string,remainder,type):
    if remainder == 0 and type == '.asciiz':
        memory[index] = '0'*32
    elif remainder == 1:
        memory[index] = ''.join(extended(format(ord(c), 'b'),8) for c in remain_string) + '0'*24
    elif remainder == 2:
        memory[index] = ''.join(extended(format(ord(c), 'b'),8) for c in remain_string) + '0'*16
    elif remainder == 3:
        memory[index] = ''.join(extended(format(ord(c), 'b'),8) for c in remain_string) + '0'*8       
    index += 1
    return (memory,index)

def static_data(content,memory,index):
    tag_data = False
    for i in content:
        if ".data" in i:
            tag_data = True
        elif ".text" in i:
            break
        if tag_data:
            if ".asciiz" in i:
                memory = as_string(i,memory,index,".asciiz")[0]
                index = as_string(i,memory,index,".asciiz")[1]
    return (memory,index)



def sign_extended(binary_number, length):
    if length >= len(binary_number):
        if binary_number[0] == '0':
            extened_num = (length-len(binary_number))*'0' + binary_number
        else:
            extened_num = (length-len(binary_number))*'1' + binary_number
    else:
        print('error')
    return extened_num


def extended(binary_number, length):
    if length >= len(binary_number):
        binary_number = (length-len(binary_number))*'0' + binary_number
    return binary_number

def unsign_bin_to_dec(string1):
    decimal_int = 0
    for i in range(0, len(string1)):
        decimal_int += int(string1[i]) * 2**(len(string1)-1-i)
    return decimal_int


def unsign_dec_to_bin(integer1, length):
    string1 = extended(bin(integer1)[2:], length)
    return string1


def sign_bin_to_dec(string1):
    decimal_int = 0
    if len(string1) == 1:
        decimal_int = -1*int(string1)
    else:
        for i in range(1, len(string1)):
            decimal_int += int(string1[i]) * 2**(len(string1)-1-i)
        if string1[0] == '1':
            decimal_int += -2**(len(string1)-1)
    return decimal_int


def sign_dec_to_bin(integer1, length):
    if integer1 >= 0:
        string1 = extended(bin(integer1)[2:], length)
    else:
        result = '0' + bin(-integer1)[2:]
        tag = False
        i = len(result)-1
        two_complement = ''
        while i >= 0:
            if tag:
                if result[i] == '1':
                    two_complement = '0' + two_complement
                else:
                    two_complement = '1' + two_complement
            else:
                two_complement = result[i] + two_complement
            if result[i] == '1':
                tag = True
            i -= 1
        string1 = sign_extended(two_complement, length)
    return string1


def store_register_integer(register, index, value):
    string1 = little_endian(sign_dec_to_bin(value, 32))
    register[index] = string1
    return register

def get_register_integer(register, index):
    register_value = sign_bin_to_dec(little_endian(register[index]))
    return register_value

def R_sll(register, rd, rt, sa):
    rt_value = little_endian(register[rt])
    register[rd] = little_endian(rt_value[sa:] + sa*'0')
    return register

def syscall_print_string(memory, register, test_out):
    address = get_register_integer(register, 4)
    index = (address - 4194304)//4  # need align
    tag = True
    with open(test_out, 'a') as file1:
        while tag == True:
            for i in range(0, 4):
                char1 = chr(unsign_bin_to_dec(memory[index][i*8:(i+1)*8]))
                if memory[index][i*8:(i+1)*8] == '00000000':
                    tag = False
                    break
                else:
                    file1.write(char1)
            if tag == True:
                index += 1

def syscall_exit():
    os._exit(0)


def I_addi(register,rs,rt,immediate):
    immediate_value = sign_bin_to_dec(immediate)
    rs_value = get_register_integer(register,rs)
    result = rs_value+immediate_value
    register = store_register_integer(register,rt,result)
    return register


def R_execution(memory, register, read_index, machine_code, dynamic_address, test_in, test_out):
    rs = machine_code[6:11]
    rt = machine_code[11:16]
    rd = machine_code[16:21]
    sa = machine_code[21:26]
    rs_decimal = unsign_bin_to_dec(rs)
    rt_decimal = unsign_bin_to_dec(rt)
    rd_decimal = unsign_bin_to_dec(rd)
    sa_decimal = unsign_bin_to_dec(sa)
    func_code = machine_code[26:]
    # shift logical
    if func_code == '000000':
        register = R_sll(register, rd_decimal, rt_decimal, sa_decimal)

    # syscall
    elif func_code == '001100':
        v0 = get_register_integer(register, 2)
        if v0 == 4:
            syscall_print_string(memory, register, test_out)
        elif v0 == 10:
            syscall_exit()
        
    return(memory, register, read_index, dynamic_address)


def I_execution(memory, register, machine_code):
    opcode = machine_code[:6]
    rs = machine_code[6:11]
    rt = machine_code[11:16]
    immediate = machine_code[16:32]
    rs_decimal = unsign_bin_to_dec(rs)
    rt_decimal = unsign_bin_to_dec(rt)

    if opcode == '001000':
        register = I_addi(register, rs_decimal, rt_decimal, immediate)
    return (memory, register)


def execution(memory, register, read_index, machine_code, dynamic_address, test_in, test_out):
    if machine_code[0:6] == '000000':
        (memory, register, read_index, dynamic_address) = R_execution(
            memory, register, read_index, machine_code, dynamic_address, test_in, test_out)
    elif machine_code[0:6] == '000010' or machine_code[0:6] == '000011':
        register = J_execution(register, machine_code)
    else:
        memory, register = I_execution(memory, register, machine_code)
    return (memory, register, read_index, dynamic_address)

# Dump the file


def dump(checkpoints_list, memory, register, iteration):
    if checkpoints_list[0] == iteration:
        memory_bin = 'memory_' + str(iteration) + '.bin'
        register_bin = 'register_' + str(iteration) + '.bin'
        with open(memory_bin, 'wb') as f1:
            for i in memory:
                bit_strings = [i[j:j + 8] for j in range(0, len(i), 8)]
                byte_list = [int(b, 2) for b in bit_strings]
                f1.write(bytearray(byte_list))
        with open(register_bin, 'wb') as f2:
            for i in range(0, len(register)):
                element = register[i]
                bit_strings = [element[j:j + 8]
                               for j in range(0, len(element), 8)]
                byte_list = [int(b, 2) for b in bit_strings]
                f2.write(bytearray(byte_list))
        checkpoints_list = checkpoints_list[1:]
    return checkpoints_list


# Start simulation
# register[32] is program counter
def simulation(memory, register, dynamic_address, read_index, checkpoints_list, test_in, test_out):
    start_index = 4194304
    iteration = 0
    index = (get_register_integer(register, 32)-start_index)//4
    while memory[index] != '0'*32:
        if checkpoints_list != []:
            checkpoints_list = dump(
                checkpoints_list, memory, register, iteration)
        index = (get_register_integer(register, 32)-start_index)//4
        machine_code = little_endian(memory[index])  # 存在memory里面是little_endian
        register[32] = little_endian(unsign_dec_to_bin(
            get_register_integer(register, 32)+4, 32))
        memory, register, read_index, dynamic_address = execution(
            memory, register, read_index, machine_code, dynamic_address, test_in, test_out)
        iteration += 1


test_asm = sys.argv[1]
test_txt = sys.argv[2]
test_checkpoints = sys.argv[3]
test_in = sys.argv[4]
test_out = sys.argv[5]


with open(test_asm, "r") as file1:
    content = file1.readlines()
no_comment_content = delete_comment(content)
memory, dynamic_index = static_data(no_comment_content, memory, 2**18)

# Assemble the codes
# test_txt = 'D:\Daerxia\CSC3050\Assignment2\\new\\tests\many\many.txt'
memory = assemble_machine_code(memory, test_txt)

with open(test_checkpoints, 'r') as file1:
    checkpoints_list = file1.readlines()

for i in range(0, len(checkpoints_list)):
    checkpoints_list[i] = int(checkpoints_list[i].strip())

# Calculate the beginning index of dynamic address
dynamic_address = (dynamic_index-2**18)*4 + 5242880

# Main simulation
simulation(memory, register, dynamic_address, read_index,
           checkpoints_list, test_in, test_out)



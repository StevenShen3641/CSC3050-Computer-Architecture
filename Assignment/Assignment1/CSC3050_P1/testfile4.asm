.text  #wqer
main:
    add     $sp, $sp, $sp
    addu    $sp, $sp, $sp
    div     $sp, $sp
    divu    $sp, $sp
    jalr    $sp, $sp
    jr      $sp
    mfhi    $sp
    a:
    mflo    $sp
    mthi    $sp
    mtlo    $sp
    mult    $sp, $sp
    multu   $sp, $sp
    nor     $sp, $sp, $sp
    or      $sp, $sp, $sp
    b:
    sll     $sp, $sp, 10
    sllv    $sp, $sp, $sp
    slt     $sp, $sp, $sp
    sltu    $sp, $sp, $sp
    sra     $sp, $sp, 8
    srav    $sp, $sp, $sp
    srl     $sp, $sp, 7
    srlv    $sp, $sp, $sp
    sub     $sp, $sp, $sp
    subu    $sp, $sp, $sp
    syscall
    xor     $sp, $zero, $sp
    addi    $sp, $sp, -32768
    addiu   $sp, $sp, 98
    andi    $sp, $sp, 48
    beq     $sp, $sp, a
    bgez    $sp, b
    c:
    bgtz    $sp, c
    lb      $sp, 7($sp)
    lbu     $sp, 0($sp)
    lh      $sp, 15($sp)
    lhu     $sp, 9($sp)
    lui     $sp, 89
    lw      $sp, 19($sp)
    ori     $sp, $sp, 9
    sb      $sp, 87($sp)
    slti    $sp, $sp, 121
    sltiu   $sp, $sp, 124
    sh      $sp, 23($sp)
    xori    $sp, $sp, 1
    lwl     $sp, 1($sp)
    lwr     $sp, 5($sp)
    swl     $sp, 3($sp)
    swr     $sp, 9($sp)


    .text
main:
    add     $sp, $sp, $sp
    addu    $sp, $sp, $sp
    div     $sp, $sp
    divu    $sp, $sp
    jalr    $sp, $sp
    jr      $sp
    mfhi    $sp
    mflo    $sp
    mthi    $sp
    mtlo    $sp
    mult    $sp, $sp
    multu   $sp, $sp
    nor     $sp, $sp, $sp
    or      $sp, $sp, $sp
    sll     $sp, $sp,  10
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
    xor     $sp, $sp, $sp
    
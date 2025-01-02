.globl sort

# partition(addr, lo, hi)
partition:
    # TODO: implement partition() here
    # using hoare scheme
    addi sp, sp, -48
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    sd s2, 24(sp)
    sd s3, 32(sp)
    sd s4, 40(sp)
    mv s0, a0   # s0 = &arr (base address)
    mv s1, a1   # s1 = low
    mv s2, a2   # s2 = hgih
    # set pivot
    slli t0, s1, 3 # s1 << 3 (double word)
    add t0, s0, t0 # address of arr[low]
    ld s3, 0(t0) # s3 = pivot
    addi s4, s1, -1 # s4 = i = low - 1
    addi t1, s2, 1  # t1 = j = high + 1
partition_loop:
    # do i++ while arr[i] < pivot
increment_i:
    addi s4, s4, 1        # i++
    slli t0, s4, 3        # t0 = i << 3
    add t0, s0, t0        # address of arr[i]
    ld t2, 0(t0)          # t2 = arr[i]
    blt t2, s3, increment_i  # if arr[i] < pivot, then i++
    # do j-- while arr[j] > pivot
decrement_j:
    addi t1, t1, -1       # j--
    slli t0, t1, 3        # t0 = j << 3
    add t0, s0, t0        # address of arr[j]
    ld t3, 0(t0)          # t3 = arr[j]
    bgt t3, s3, decrement_j  # if arr[j] > pivot, then j--

    bge s4, t1, end_partition # if i >= j, then return

    # swap arr[i] and arr[j]
    slli t4, s4, 3        # t4 = i << 3
    add t4, s0, t4        # address of arr[i]
    slli t5, t1, 3        # t5 = j << 3
    add t5, s0, t5        # address of arr[j]
    ld t6, 0(t4)          # t6 = arr[i]
    ld t0, 0(t5)          # t0 = arr[j]
    sd t0, 0(t4)          # arr[i] = arr[j]
    sd t6, 0(t5)          # arr[j] = original arr[i]
    
    j partition_loop
end_partition:
    mv a0, t1  # return j
    # restore stack
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    ld s3, 32(sp)
    ld s4, 40(sp)
    addi sp, sp, 48
    ret

# quicksort(addr, lo, hi)
quicksort:
    # TODO: implement quicksort() here
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    sd s2, 24(sp)
    mv s0, a0   #s0 = &arr
    mv s1, a1   #s1 = low
    mv s2, a2   #s2 = high
    bge s1, s2, end_sort    #if low >= high, then return
    mv a0, s0
    mv a1, s1
    mv a2, s2
    jal ra, partition
    mv t0, a0             # set t0 = j (return value of partition)
    # call quicksort(arr, low, j)
    mv a0, s0             # &arr
    mv a1, s1             # low
    mv a2, t0             # j
    jal ra, quicksort
    # call quicksort(arr, j + 1, high)
    mv a0, s0             # &arr
    addi a1, t0, 1        # j + 1
    mv a2, s2             # high
    jal ra, quicksort
end_sort:
    ld ra, 0(sp) # restore stack
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    addi sp, sp, 32
    ret

# sort(addr, count)
sort:
    # TODO: call your quicksort() here
    addi sp, sp, -16
    sd ra, 0(sp) # sp : ra
    sd s0, 8(sp) # sp + 8 : s0

    mv s0, a0    # s0 = &arr (base address of arr)
    addi a2, a1, -1 # high = numbers - 1
    li a1, 0        # low = 0
    jal ra, quicksort   # call quicksort function

    ld ra, 0(sp) # restore stack
    ld s0, 8(sp)
    addi sp, sp, 16

    ret


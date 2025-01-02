---
title: Assignment2 Programming Part

---

# Assignment 2 - Programming Part Report

## How I implement 

Before writing assembly code, I firstly follow the Hoare Partition Scheme's pseudocode to write C code, and then convert the C code into assembly code line by line.

- sort：as an entry point, set initial parameters and call quicksort.
- quicksort：implement the main logic of QuickSort recursively.
- partition：implement the Hoare partitioning scheme, select the pivot and rearrange the array elements.

## Difficulties I encounter and How I address them

### 1.
I frequently  encounter error like  ```Runtime exception at 0x00400090: address out of range 0x90240004```, it is because I didn't correctly calculate the memory address of array elements. 
Before:
```
add  t1, s0, s2       
ld   s3, 0(t1) 
```
I solve the problem using bit shifting before getting the address because an array's elements are byte-based and each element occupies 8bytes (64bits), and thus we need to left shift 3 bits to get the correct offset. I correct this as follows:
```
slli t1, s2, 3       
add  t1, s0, t1       
ld   s3, 0(t1) 
```

### 2.
Also, I consume most the time on handling the parameters passing.
Before:
```
mv   s0, a0            
mv   s1, x0           
mv   s2, a1            
jal  ra, quicksort  
```
This led to unexpected behavior because s registers are callee-saved, which caused issues across function calls. I solved this by switching to using argument registers (a0, a1, and a2), which are commonly used for parameter passing in RISC-V:
```
mv a0, s0
mv a1, s1
mv a2, s2
jal ra, partition
```

### 3.
Initially, I didn’t know that s registers are callee-saved. I used them directly across function calls, which led to incorrect data accessed as the register values were overwritten. My solution is to properly save and restore the s registers if they are used in a function:
```
sd   s0, 8(sp)        # Save s0 before use
...
ld   s0, 8(sp)        # Restore s0 after use
```

### 4.
In the beginning, I didn’t manage the stack pointer (sp) correctly. Specifically, I forgot to restore it after function calls, which led to stack mismanagement. I fixed this by ensuring that after modifying the stack pointer to store values, I restored it correctly before returning from the function.

## Explanation of my code

Basically, I have annotations for most of the code.

### 1. sort(addr, count)

assembly code:
```
sort:
    # TODO: call your quicksort() here
    addi sp, sp, -16
    sd ra, 0(sp) # sp : ra
    sd s0, 8(sp) # sp + 8 : s0

    mv s0, a0    # s0 = &arr (base address of arr)
    addi a2, a1, -1 # high = numbers - 1
    li a1, 0        # low = 0
    jal ra, quicksort   # call quicksort function
    # restore stack
    ld ra, 0(sp) 
    ld s0, 8(sp)
    addi sp, sp, 16

    ret
```
Corresponding C code:
```c=
quicksort(arr, 0, N - 1);
```


- Store ra and s0 to stack pointer.
- Set the argument (addr, low, high) for quicksort
- Restore the stack and function ends


### 2. quicksort(addr, lo, hi)

```
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
```
Corresponding C code:
```c=
void quickSort(int arr[], int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);
        quickSort(arr, low, pi - 1);
        quickSort(arr, pi + 1, high);
    }
}
```
- Store the register to stack pointer
- Check the condition (low < high) is established
    - if establised, then continue
    - else, then jump to end_sort to restore stack and function ends
- Call partition and recursively sort the left and right parts according to the return value

### 3. partition(addr, lo, hi)

**Using Hoare Partition Scheme**

**Part a**
```
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
```
Corresponding C code:
```c=
int partition(arr[], low, high)
   int pivot = arr[low]
   int i = low - 1  
   int j = high + 1  
```
- set s3 as the pivot (arr[low])
- and set the two pointer s4 as i = low - 1, and t1 as j = high + 1

**Part b**
```
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
```
Corresponding C code:
```c=
while (1) {
     while (arr[i] < pivot) i++;
     while (arr[j] > pivot) j--;
    if (i >= j) return j;
    int temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
}
```
- Looply doing increment_i to find leftmost element greater than or equal to pivot
- Looply doing decrement_j to find rightmost element smaller than or equal to pivot
- If two pointer meets, then jump to end_partition (return j and restore stack and function ends)
- Else, swap arr[i] and arr[j] using temporary register (t0 ~ t6), and then continue the next loop


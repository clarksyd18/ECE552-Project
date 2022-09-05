// Write your assembly program for Problem 1 (a) #2 here.
lbi r0, 0
lbi r1, -1
lbi r2, 1
j 2
add r0, r1, r0
nop
nop
nop
// tests MEM-EX forwarding
add r2, r0, r1
nop
add r2, r2, r1
halt

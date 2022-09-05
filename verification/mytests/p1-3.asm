// Write your assembly program for Problem 1 (a) #3 here.
lbi r0, 0
lbi r1, -1
lbi r2, 4
lbi r3, 2
nop
nop
st r2, r0, 0
j 2
add r0, r1, r0
nop
nop
nop
// tests MEM-MEM forwarding
ld r1, r0, 0
st r1, r0, 2
halt

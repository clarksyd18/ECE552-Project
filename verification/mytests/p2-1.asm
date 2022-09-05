// Write your assembly program for Problem 2 (a) #1 here.
lbi r0, 0
lbi r1, 1
lbi r2, 2
nop
nop
nop
addi r1, r1, -1
beqz r1, 6
lbi r0, 1
nop
nop
addi r2, r0, 0
halt

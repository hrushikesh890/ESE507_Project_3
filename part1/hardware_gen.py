import argparse
import sys
import math
parser = argparse.ArgumentParser()
parser.add_argument("integers",type=int,nargs = 4)
args = parser.parse_args()

def find_log_size(num):
	start = math.log(num, 2)

	if ((start - int(start)) != 0):
		start += + 1
	return int(start) 

n = args.integers[0]
m = args.integers[1]
width = args.integers[2]
t = args.integers[3]

addrx = find_log_size(n)
addrf = find_log_size(m)

sModname_rom = "conv_" + str(n) + "_" + str(m) + "_" + str(width) + "_" + str(t) + "_f_rom"
sModname_gen = "conv_" + str(n) + "_" + str(m) + "_" + str(width) + "_" + str(t)
#get template
with open('templete.sv', 'r') as file:
    templete = file.read()

#get rom 
with open('rom.txt', 'r') as file:
    rom = file.read()

templete = templete.replace('$$ROM$$', rom).replace('$WIDTH$', str(width)).replace('$ADDRX$', str(addrx)).replace('$ADDRF$', str(addrf))
templete = templete.replace('$N$', str(n)).replace('$M$', str(m))
templete = templete.replace('$rommodname$', sModname_rom).replace('$modnamegen$', sModname_gen)
print(templete)
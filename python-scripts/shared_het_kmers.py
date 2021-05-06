#!/usr/bin/env python3
'''
This program takes two files and their haploid peaks and generates lists of 
upper and lower thresholds from 1 to 4*haploid peak, going in user-specified
steps, then runs shared_het_kmers.py on the files for each possible combination 
of thresholds in file 1 and the corresponding ones for file 2 and redirects the 
output to a user-specified directory. 
'''

import argparse
import subprocess
import os

# Arguments.
parser = argparse.ArgumentParser(description = "run shared_kmers.py many times with different thresholds as specified, from 1 to 4*haploid peak")
parser.add_argument("-k1", "--kmers1", required = True, help = "first input file")
parser.add_argument("-k2", "--kmers2", required = True, help = "second input file")
parser.add_argument("-p1", "--peak1", type = float, required = True, help = "haploid peak position for file 1")
parser.add_argument("-p2", "--peak2", type = float, required = True, help = "haploid peak position for file 2")
parser.add_argument("-st", "--step", type = int, required = True, help = "integer interval for steps")
parser.add_argument("-o", "--output", required = True, help = "output directory name")
args = parser.parse_args()

# Setup.
mypath = os.path.dirname(os.path.realpath(__file__))

# Input lists. Currently going from 1 to 4*haploid peak in steps specified by 
# user input. Can be altered (should really use args to do this but this 
# program was only used about twice). 
peak1 = int(args.peak1)
peak2 = int(args.peak2)

lower1 = [i for i in range(1, peak1, args.step)]
upper1 = [i for i in range(peak1, peak1*4, args.step)] 

stepL = round(float(peak2)/len(lower1))
stepU = round(float(peak2*4 - peak2)/len(upper1))
val = 1
lower2 = []
upper2 = []

for i in lower1:
    lower2.append(val)
    val = val + stepL

val  = peak2
for i in upper1:
    upper2.append(val)
    val = val + stepU

# Somewhere for output to go.
subprocess.run(['mkdir', args.output])

iteratorL = 0

# Getting all the commands and running them. 
for i in lower1:
    iteratorU = 0
    for j in upper1:
        
        # The actual command
        cmd = ["python", mypath+"/shared_het_kmers.py", "-k1", mypath+"/"+str(args.kmers1), "-k2", mypath+"/"+str(args.kmers2), "-t", "-lb_i1", str(i), "-ub_i1", str(j), "-lb_i2", str(lower2[iteratorL]), "-ub_i2", str(upper2[iteratorU]), "-p1", str(peak1), "-p2", str(peak2), "-oh"]

        with open(args.output+"/out.txt", 'a') as f:
            subprocess.run(cmd, stdout = f)

        iteratorU += 1
    iteratorL += 1

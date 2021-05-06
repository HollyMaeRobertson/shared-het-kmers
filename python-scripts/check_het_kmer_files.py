#!/usr/bin/env python3

'''
This script checks potential input files to shared_kmers.py for common issues  
such as incorrect lines. Correct input should be a tab-separated file laid out 
as "kmer1 count1 kmer2 count2" on each line.  
'''

import sys

# The only input is the file to check.
het_kmers = open(sys.argv[1], "r")

# Get total length of file.
sys.stderr.write("processing\r")
with open(sys.argv[1], "r") as f:
    total_length = len(f.readlines())
sys.stderr.write("")

# Initialise values. 
final_output = []
index = 0

with open(sys.argv[1], "r") as f:
    for line in f:
        index += 1

        # For ease of reading.
        line_string = line.strip()
        line_list = line_string.split("\t")
        
        # stderr progress is satisfying to watch.
        to_print = "Line: " + str(index) + '\t' + line_string
        progress = str(round((float(index)/total_length*100), 1)) + "%" + " complete"
        sys.stderr.write(progress + "\r")

        # Various checks:

        # - column number is 4?
        if len(line_list) != 4:
            final_output.append(to_print) 

        # - both kmers are the same length?
        elif len(line_list[0]) != len(line_list[2]):
            final_output.append(to_print)

        # - counts are only numeric characters?
        elif not int(line_list[1]):
            final_output.append(to_print)

        elif not int(line_list[3]):
            final_output.append(to_print)

        # - kmers are only made up of As, Ts, Gs and Cs?
        # (this means no Ns, if Ns are ok edit this part)
        else:
            for i in line_list[0]:
                if i != 'A' and i != 'T' and i != 'G' and i != 'C':
                    final_output.append(to_print)

            for i in line_list[2]:
                if i != 'A' and i != 'T' and i != 'G' and i != 'C':
                    final_output.append(to_print)

# Were there any problems?
for i in final_output:
    print i

if len(final_output) == 0:
    print "There are no incorrect lines in this het_kmer file!"
else:
    print len(final_output)

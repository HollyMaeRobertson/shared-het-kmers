#!/usr/bin/env python3
'''
This program takes a file from FastK's (see 
https://github.com/thegenemyers/FASTK) Haplex feature and converts it to a 
4-column tab-separated file with the format "most_common_kmer count 
second_most_common_kmer count" where each count is of the kmer before it. 
'''
import sys

# Inputs are the name of the FastK file and the name we want the output file to
# be. NB output file must be empty when we start.
EditFile = sys.argv[1]
OutFile = open(sys.argv[2], "a")

# Initialise.
current_chunk = []

# Useful later.
def second_entry(l):
    '''
    Returns the second entry in a list as an integer.
    '''
    return int(l[1])

with open(EditFile, "r") as f:
    for line in f:
        # Some of the lines are completely blank so check for that first.
        # Blank lines signify the end of "one kmer" (current_chunk). 
        if len(line.strip()) != 0:
            current_chunk.append(line)
        else:
            all_lines  = []
            for entry in current_chunk:
                split_entry = entry.split(" ")
                split_entry = [x.strip() for x in split_entry]
                all_lines.append(split_entry)
            
            # Removes all but the two biggest counts from the list. .
            while len(all_lines) > 2:
                all_lines.sort(reverse=True, key=second_entry)
                all_lines.pop()

            # convert everything to uppercase and write out the kmers.
            for i in all_lines:
                i[0] = i[0].upper()
                OutFile.write(i[0] + "\t" + i[1] + "\t") 
            OutFile.write("\n")

            current_chunk = []

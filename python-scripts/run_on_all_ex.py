#!/usr/bin/env python3
'''
This program takes in a list of complete paths to FastK output files and a tab 
separated table of haploid coverages of format "summary_file_location 
haploid_coverage". It's extremely specific to the exact way the darwin tree of 
life project and others internally organise files, and doesn't even work for all
of those, but it served its purpose in allowing me to avoid writing out all 
useful pairwise comparisons longhand and carrying them out individually, which 
would have been impractical given the number of samples involved.

This example script is the one used to generate Anopheles mosquito comparisons 
and will require slight adjustment to generate comparisons with differently 
laid out sample names. 
'''

import sys
import os
import re
import subprocess

file_list = sys.argv[1]
hapcovs_table = sys.argv[2]

hapcovs_dict = {}
with open(hapcovs_table, 'r') as f:
    for line in f:
        line = line.strip()
        cols = line.split("\t")
        file_path = cols[0].split("/")
        hapcov = cols[1]
        I = re.search(r'\d.*$',file_path[10]).group(0)
        M = file_path[11]
        species = re.search(r'([a-zA-Z ]*)', file_path[10])[0]
        info = {"I": I, "M": M, "hapcov": hapcov}
        if species in hapcovs_dict.keys():
            hapcovs_dict[species].append(info)
        else:
            hapcovs_dict[species] = [info]

def read_hapcovs_table(species, I, M, table):
        """ Looks up a provided file path and gives the corresponding haploid 
        coverage from the table."""
        to_search = table[species]
        for i in to_search:
            if i['I'] == I and i['M'] == M:
                return(i['hapcov'])

            else:
                continue 

iterator = 0
# A dictionary where keys are species name and entries are lists of the full 
# path to each file of that species
species_dict = {}

for line in open(file_list, "r"):
    # Get the species name
    actual_filename = os.path.basename(line.strip())
    temp = 0
    for chr in actual_filename:
        if chr.isdigit():
            temp = actual_filename.index(chr)
            break

    species_name = actual_filename[0 : temp]

    species_name = species_name.split("-")[0]

    if species_name not in species_dict.keys():
        species_dict[species_name] = []
    
    species_dict[species_name].append(line.strip())

subprocess.run(['mkdir', 'Anopheles'])

for key in species_dict.keys():
    current_list = sorted(species_dict[key])
    iterator = 0
    for item in current_list:
        # comp item to other things in the list
        iterator += 1
        current_list_remaining = current_list[iterator:]
        for comp in current_list_remaining:
            comp1 = os.path.basename(item).split("_")
            comp2 = os.path.basename(comp).split("_")
            
            # Anopheles mosuqitos have the family no and then an underscore
            # before the individual within that family, so the unique identifier
            # for an individual has to contain both of these parts. 
            I1 = comp1[0].split("-")[1] + "_" + comp1[1]
            I2 = comp2[0].split("-")[1] + "_" + comp2[1]

            if comp1[2] == "ccs":
                M1 = "pacbio"
            else:
                M1 = comp1[2]
            if comp2[2] == "ccs":
                M2 = "pacbio"
            else:
                M2 = comp2[2]

            name = str(key) + "," + I1 + "," + I2 + "," + M1 + "," + M2

            hap1 = read_hapcovs_table(str(key), I1, M1, hapcovs_dict)
            hap2 = read_hapcovs_table(str(key), I2, M2, hapcovs_dict)

            if hap1 is None or hap2 is None:
                continue

            if int(float(hap1)) == 0 or int(float(hap2)) == 0:
                continue

            hap1 = int(float(hap1))
            hap2 = int(float(hap2))

            cmd = ["python", "/lustre/scratch116/tol/projects/darwin/users/hr10/shared_kmers.py", "-k1", str(item), "-k2", str(comp), "-oh", "-t", "-p1", str(hap1), "-lb1", "0.5", "-ub1", "1.5", "-p2", str(hap2), "-lb2", "0.5", "-ub2", "1.5", "-na", name]
            
            with open("Anopheles/out.txt", 'a') as f:
               subprocess.run(cmd, stdout = f)


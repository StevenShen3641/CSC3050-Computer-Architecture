import os
import sys

# input files' names
test_file=sys.argv[1]
output_file=sys.argv[2]
expectedoutput_file=sys.argv[3]

# conduct phase2.py to do compiling
os.system(f"python phase2.py {test_file} {output_file}")

# read and store the content in the output file and expected outputfile seperately
with open(output_file,"r") as file_object:
    output_lines=file_object.readlines()
with open(expectedoutput_file,"r") as file_object:
    expect_lines=file_object.readlines()

# revise the content of the lists from two files for comparison
for i in range(0,len(output_lines)):
    line=output_lines[i]
    line=line.replace("\n","") #delete "\n"
    output_lines[i]=line
for i in range(0,len(expect_lines)):
    line=expect_lines[i]
    line=line.replace("\n","").replace(" ","").replace("\t","") #delete "\n","\t" and space
    expect_lines[i]=line

# compare two files' content and print the result
if output_lines == expect_lines:
    print("All Passed! Congratulations!")
else:
    print("You did something wrong!")
with open("u.data") as file:
	lines = file.read().split("\n")
	
'''
This script takes the u.data file from the movielens dataset
and uses it to create a json file containing the same data.

This json data is used for the algorithm created in Matlab.
'''
	
entries = ""	

i = 0
j = 0

for line in lines:
	items = line.split("\t")
	for item in items:
		if i == 0:
			item = '{\n	"reviewerID": "' + item +'",\n'
			i += 1
		elif i == 1:
			item = '	"asin": "' + item + '",\n'
			i += 1
		elif i == 2:
			item = '	"overall": ' + item + ",\n"
			i += 1
		elif i == 3:
			item = '	"reviewTime": "' + item + '"\n}\n'
			i = 0
		entries += item
		
		


with open("output.txt", "w") as text_file:
	print(entries, file=text_file)
#!/bin/bash

#Create input list for parallel alignment with BWA
#Trimmed input, each sample has paired and singleton reads
#Read sample info from samples_2s.config
#Unsplit fastq in Fastq directory, split fastq in Fastq_split_pairs_singles, trimmed in Fastq_lanesplit_trimmed
#The GeneWiz data was provided as combined, 2 lanes from 2 flowcells per sample
#Used custom perl to reformat into per-lane fastq,with flowcell and lane as field 1 and 2 of ':' delim read ID
#The Illumina data has normal IDs - flowcell ID is field 3 and lane is field 4 of ':' delim read ID
#18AUG23: align singletons unsplit as they are too small and will thrash the nodes

#singles=./Inputs/align_singles.inputs
pairs=./Inputs/align_pairs_dragmap.inputs-Y1368

ref=./Reference/

rm -f $pairs
#rm -f $singles


awk 'NR>1' ./Inputs/samples.config | while read LINE
do 
	sample=`echo $LINE | cut -d ' ' -f 1`
	labSampleID=`echo $LINE | cut -d ' ' -f 2`
	centre=`echo $LINE | cut -d ' ' -f 3`
	platform=`echo $LINE | cut -d ' ' -f 4`
	lib=`echo $LINE | cut -d ' ' -f 5`
	
	if [ ! "$lib" ]
	then
	    	lib=1
	fi
	
	fqpairs=$(ls ./Fastq_final/*${sample}*.fastq.gz | sed  's/_R1.*\|_R2.*//' | uniq)
	fqpairs=($fqpairs)
	
	#Get the flowcell and lane info from the original pairs:	
	for ((i=0; i<${#fqpairs[@]}; i++))
	do
	
		if [[ $centre == 'Genewiz-MGIplatform' ]]
		then
			flowcell=$(zcat ${fqpairs[i]}_R1*.fastq.gz | head -1 | cut -d ':' -f 1 | sed 's/^\@//')
			lane=$(zcat ${fqpairs[i]}_R1*.fastq.gz | head -1 | cut -d ':' -f 2)
		
		else 		
			flowcell=$(zcat ${fqpairs[i]}_R1*.fastq.gz | head -1 | cut -d ':' -f 3)
			lane=$(zcat ${fqpairs[i]}_R1*.fastq.gz | head -1 | cut -d ':' -f 4)	
		fi
		
		#Print each of the split chunks with flowcell and lane info to inputs file:
		set=$(basename ${fqpairs[i]})
		splitpairs=$(ls Fastq_split_pairs/Y1368/*${set}*_R1*.fastq.gz | sed  's/_R1*.fastq.gz//') # this is a string variable that holds a space delimied list of files - not so useful 
		splitpairs=($splitpairs) # convert this to an 'array' (a list) by wrapping in brackets
		
		# To print the whole array: echo ${splitpairs[@]}
		# To print the number of things in the array (also called 'array length': echo ${#splitpairs[@]}
		# To print the first thing in the list (arrays are zero-based): echo ${splitpairs[0]} # this number in the square brackets is called the 'array index'
		#To print the second thing in the list (arrays are zero-based): echo ${splitpairs[1]}
		
		# for prefix in ${splitpairs[@]} # would have been a more simle solution, but using the 'c' notation (c is meaningless, could use mickeymouse ) 
		#do
		#	echo $prefix
		#done
		
		for ((c=0; c<${#splitpairs[@]}; c++)) # iterate over all thing in the list 
		do
			printf "${splitpairs[c]},${labSampleID},${centre},${lib},${platform},${flowcell},${lane},${ref}\n" >> $pairs		
		done
		
		
		#set=$(basename ${fqpairs[i]})
		#splitsingles=$(ls Fastq_split_pairs_singles/*${set}*.singleton.trimmed.fastq.gz | sed  's/.singleton.trimmed.fastq.gz//') #R1 and R2 singletons
		#splitsingles=($splitsingles)
		
		#for ((c=0; c<${#splitsingles[@]}; c++))
		#do
			#printf "${splitsingles[c]},${labSampleID},${centre},${lib},${platform},${flowcell},${lane}\n" >> $singles		
		#done		
					
	done			
done	

tasks=`wc -l < $pairs`
printf "Number of paired alignment tasks to run: ${tasks}\n"

#tasks=`wc -l < $singles`
#printf "Number of singleton alignment tasks to run: ${tasks}\n"	

#Number of paired alignment tasks to run: 226
#Number of singleton alignment tasks to run: 32


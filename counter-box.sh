
cat HCJL5BGXB_Fogarty_10416629_cellranger_mkfastq_output_5June19//outs/input_samplesheet.csv | cut -d "," -f3 | cut -d "-" -f2 | sed 1,2d

for i in */; do cd $i/outs; echo `pwd` >> ../../out.paths; cd  ../..; done



for i in */
do
	cd $i/outs
	DIR=`pwd`
	A=cat input_samplesheet.csv | cut -d "," -f3 | cut -d "-" -f2 | cut -d "_" -f3 | sed 1,2d >> ../../.ids
	
	cd ../../

done

sort -u .ids > .unique.ids

DUPS=`wc -l .ids`
UNIQ=`wc -l .unique.ids`

echo ""
echo "total samples (w/ duplicates) = ` echo $DUPS | cut -d '.' -f1` "
echo "total samples (w/o duplicates) = ` echo $UNIQ | cut -d '.' -f1` "
echo ""


readarray sampleIDs < .unique.ids

for i in "${sampleIDs[@]}"
do
	# echo $i
	GREP=`find -type d | grep `echo $i`$ .names | cut -d "/" -f2 | sort -u | xargs | sed -e 's/ /,/g'`
  
  	/programs/cellranger-3.0.2/cellranger count --id=`echo $i` \
  	--transcriptome=/workdir/singleCellData/10x_reference_files/refdata-cellranger-GRCh38-3.0.0/ \
  	--fastqs=${FASTQS}/fastq_path/ \
  	--sample=`echo $GREP` \
  	--localcores 20 --localmem 250

done






sampledID = ../RUN_FOLDER/outs/fastq_path/Project_11530_2022/



find -type d | grep  "3753" | cut -d "/" -f2 | sort -u | xargs | sed -e 's/ /,/g'



cat input_samplesheet.csv | cut -d "," -f3 | cut -d "-" -f2 | cut -d "_" -f3 | sed 1,2d | awk '{print "'$i'" $0}'


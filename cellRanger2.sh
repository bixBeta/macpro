cat HCJL5BGXB_Fogarty_10416629_cellranger_mkfastq_output_5June19//outs/input_samplesheet.csv | cut -d "," -f3 | cut -d "-" -f2 | sed 1,2d

for i in */; do cd $i/outs; echo `pwd` >> ../../out.paths; cd  ../..; done



for i in */
do
	cd $i/outs
	DIR=`pwd`
	cat input_samplesheet.csv | cut -d "," -f3 | cut -d "-" -f2 | sed 1,2d 
	cd ../../

done



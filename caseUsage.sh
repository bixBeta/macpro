#!/bin/bash

display_usage(){
  echo "------------------------------------------------------------------------------------------------------------------"
  echo "run the script using the following syntax:"
  echo "    bash" $0 "<-k3> <Report_Title> <Genome> <Annot>"
  echo ""
  echo " -k1 or -n1  = knit with all headers (including MA-plot)"
  echo " -k2 --knit2 = knit w/o MA-plot"
  echo " -k3 or -n3  = knit w/o GeneBodyCov"
  echo " -k4 --knit4 = knit for atacQC"
  echo " -k5 --knit5 = custom knit"
  echo " -k6 --knit6 = knit w/o MA-plot w/o GeneBodyCov"
  echo " -a1 = knit for atac-de (complete)"
  echo " -a2 = knit for atac-de (w/o MA-plot)"
  echo " -a3 = knit for atac custom"
  echo " -i1 = knit interactive_complete"
  echo "------------------------------------------------------------------------------------------------------------------"
}

T=$2
G=$3
A=$4

knit_html(){

  scp /Users/fa286/Documents/GitHub/macpro/rmd_temp.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A

  rm rmd_temp.Rmd

}

knit_html2(){

  scp /Users/fa286/Documents/GitHub/macpro/rmd_temp_w_o_MA.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A

  rm rmd_temp_w_o_MA.Rmd

}

knit_html3(){

  scp /Users/fa286/Documents/GitHub/macpro/no-gene-body.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A

  rm no-gene-body.Rmd

}

knit_html4(){

  scp /Users/fa286/Documents/GitHub/macpro/qc.atac.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.atacQC.R $T

  rm qc.atac.Rmd

}

knit_html5(){

  scp /Users/fa286/Documents/GitHub/macpro/customRMD.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A

  rm customRMD.Rmd

}


knit_html6(){

  scp /Users/fa286/Documents/GitHub/macpro/no-gene-body-noMA.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A

  rm no-gene-body-noMA.Rmd

}


knit_atac1(){

  scp /Users/fa286/Documents/GitHub/macpro/atac-de.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A

  rm atac-de.Rmd
}

knit_atac2(){

  scp /Users/fa286/Documents/GitHub/macpro/atac-de-noMA.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A

  rm atac-de-noMA.Rmd
}

knit_atac3(){

  scp /Users/fa286/Documents/GitHub/macpro/atac-de-custom.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A

  rm atac-de-custom.Rmd
}



knit_interactive(){

  #scp /Users/fa286/Documents/GitHub/macpro/interactive_complete.Rmd .

  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A

  #rm interactive_complete.Rmd
}


knit_nextflow_all(){

  scp /Users/fa286/Documents/GitHub/macpro/nf_rmd_temp.Rmd .
  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A
  rm nf_rmd_temp.Rmd

}


knit_nextflow_wo_gbcov(){

  scp /Users/fa286/Documents/GitHub/macpro/nf_no-gene-body.Rmd .
  Rscript /Users/fa286/Documents/GitHub/macpro/knit.R $T $G $A
  rm nf_no-gene-body.Rmd
  
}


raise_error() {
  echo "-------------------------------------------------------------------"
  local error_message="$@"
  echo "${error_message}" 1>&2;
  echo "-------------------------------------------------------------------"
}



case $1 in
    -h|--help)
      display_usage
      ;;
    -k1|--knit1)
      knit_html
      ;;
    -k2|--knit2)
      knit_html2
      ;;
    -k3|--knit3)
      knit_html3
      ;;
    -k4|--knit4)
      knit_html4
      ;;
    -k5|--knit5)
      knit_html5
      ;;
    -k6|--knit6)
      knit_html6
      ;;
    -a1)
      knit_atac1
      ;;
    -a2)
      knit_atac2
      ;;
    -a3)
      knit_atac3
      ;;
    -i1)
      knit_interactive
      ;;
    -n1)
      knit_nextflow_all
      ;;
    -n3)
      knit_nextflow_wo_gbcov
      ;;
     *)
      raise_error "Unknown argument(s): ${1}"
      display_usage
      ;;
esac

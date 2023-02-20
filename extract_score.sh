#!/bin/bash

mhz=$1

if [[ -z $1 ]]; then
  echo "Please provide the CPU frequency in MHz."
  echo "E.g.:"
  echo ""
  echo "./extract_score.sh 16"
  echo ""
  echo "for a CPU that runs at 16 MHz"
  echo ""
  exit
fi

while read line
do
  result_line=$(echo $line | grep -e "\$.*=")
  if [[ ! -z $result_line ]]; then
    index=${result_line:1:1}
    value=${result_line:5}
    if [[ $index == "1" ]]; then
      size=$value
    fi
    if [[ $index == "2" ]]; then
      ticks=$value
    fi
    if [[ $index == "3" ]]; then
      iter=$value
    fi
  fi
done < "run2.log"

size="$(size coremark.exe)"

time_secs=$(echo "scale = 8; $(echo "scale = 8; $ticks/1000000" | bc)/$mhz" | bc | awk '{printf "%lf", $0}')
iter_secs=$(echo "scale = 8; $iter/$time_secs" | bc | awk '{printf "%lf", $0}')
cmark_secs=$(echo "scale = 8; $iter_secs/$mhz" | bc | awk '{printf "%lf", $0}')

echo "Total Ticks: $ticks"
echo "Iterations: $iter"
echo "Total time (secs): $time_secs"
echo "Iterations/Sec (CoreMark): $iter_secs"
echo "Iterations/Sec/MHz (CoreMark/MHz): $cmark_secs"
echo ""
echo "CoreMark Size:"
echo ""
echo "$size"
echo ""

exit

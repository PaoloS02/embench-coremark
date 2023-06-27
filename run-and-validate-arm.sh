#!/bin/bash

TOP_DIR=$PWD
tools_path=""
cflags=""
ldflags=""
iterations=""
target=""
cpu_mhz=""

set +u
until
  opt="$1"
  case "${opt}" in --tools)
      shift
      tools_path="$1"
      ;;
    --cflags)
      shift
      cflags="$1"
      ;;
    --ldflags)
      shift
      ldflags="$1"
      ;;
    --iterations)
      shift
      iterations="$1"
      ;;
    --mhz)
      shift
      cpu_mhz="$1"
      ;;
    --target)
      shift
      target="$1"
      ;;
    ?*)
      echo "Unknown argument '$1'"
      exit 1
      ;;
    *)
      ;;
  esac
[ "x${opt}" = "x" ]
do
  shift
done
set -u

if [ -z "$target" ]; then
  echo "No target selected"
  exit 1
fi

cflags="${cflags} -DITERATIONS=${iterations}"

extract_score () {
  _mhz="$1"
  _file="$2"
  
  while read line
  do
    result_line=$(echo $line | grep -e "\$.*=")
    if [[ ! -z $result_line ]]; then
      index=${result_line:1:1}
      value=${result_line:5}
  #    if [[ $index == "1" ]]; then
  #      size=$value
  #    fi
      if [[ $index == "1" ]]; then
        ticks=$value
      fi
      if [[ $index == "2" ]]; then
        iter=$value
      fi
      if [[ $index == "3" ]]; then
        valid=$value
      fi
    fi
  done < "${_file}"
  
  size="$(size coremark.exe)"
  
  time_secs=$(echo "scale = 8; $(echo "scale = 8; $ticks/1000000" | bc)/$1" | bc | awk '{printf "%lf", $0}')
  iter_secs=$(echo "scale = 8; $iter/$time_secs" | bc | awk '{printf "%lf", $0}')
  cmark_secs=$(echo "scale = 8; $iter_secs/$_mhz" | bc | awk '{printf "%lf", $0}')
  cmark_valid=$(echo "scale = 8; $valid" | bc | awk '{printf "%d", $0}')
  
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
  
  if [ ${cmark_valid} == 0 ] ; then
    echo "Result is valid"
  else
    echo "ERROR: result is not valid!"
  fi
}

make clean PORT_DIR=${target}

echo ""

echo "Building performance run..."
make PORT_DIR=${target} CC=${tools_path}arm-none-eabi-gcc LD=${tools_path}arm-none-eabi-gcc LFLAGS="${ldflags}" GDB=${tools_path}/arm-none-eabi-gdb XCFLAGS="${cflags} -DPERFORMANCE_RUN=1" ITERATIONS=${iterations} REBUILD=1 run1.log > performance.log 2>&1

echo ""
echo "Performance run"
echo "==============="
echo ""

#./extract_score.sh ${cpu_mhz}
extract_score "${cpu_mhz}" "run1.log"

echo ""

make clean PORT_DIR=${target}

echo ""

echo "Building validation run..."
make PORT_DIR=${target} CC=${tools_path}arm-none-eabi-gcc LD=${tools_path}arm-none-eabi-gcc LFLAGS="${ldflags}" GDB=${tools_path}/arm-none-eabi-gdb XCFLAGS="${cflags} -DVALIDATION_RUN=1" ITERATIONS=${iterations} REBUILD=1 run2.log > validation.log 2>&1

echo ""
echo "Validation run"
echo "=============="
echo ""

#./extract_score.sh ${cpu_mhz}

extract_score "${cpu_mhz}" "run2.log"

echo ""

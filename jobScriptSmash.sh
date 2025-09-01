#!/bin/bash

# script for executing SMASH binary on SLURM (modified version of jobScript_SL.sh)
# author: Jedrzej Kolas
# date: 10.04.2024

echo ""
echo "--------------------------------"
echo "SLURM_JOBID        : " $SLURM_JOBID
echo "SLURM_ARRAY_JOB_ID : " $SLURM_ARRAY_JOB_ID
echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "--------------------------------"
echo ""

jobarrayFile=$1
scriptFile=$2
outdir=$3

# map back params for the job
input=$(awk "NR==$SLURM_ARRAY_TASK_ID" $jobarrayFile)   # get all params for this job
par1=$(echo $input | cut -d " " -f1)

format='+%Y/%m/%d-%H:%M:%S'
host=$(hostname)

date $format
echo ""               
echo "--------------------------------"
echo "RUNNING ON HOST : " $host
echo "WORKING DIR     : " $(pwd)
echo "USER is         : " $USER
echo "DISK USAGE /tmp :"
df -h /tmp
echo "--------------------------------"

echo ""               
echo "--------------------------------"
echo "par1 = ${par1}"
echo "par2 = ${scriptFile}"
echo "par3 = ${outdir}"
echo "--------------------------------"
echo ""

echo ""
echo "--------------------------------"
echo " DEBUG INFO"                     
echo "==> Kernel version information :"
uname -a                               
echo "==> C compiler that built the kernel:"
cat /proc/version                           
echo "==> load on this node:"               
mpstat -P ALL                               
echo "==> actual compiler is"               
gcc -v                                      
echo "--------------------------------"     
echo ""

# move to output dir
cd $par1
pwd

# execute the binary file
ldd smash
./smash
cd ..

# hope for the best
status=$?

echo "------------------------------------"
echo "OUTPUT:"

if [ $status -ne 0 ]
then
    echo "JOB: $JOB_ID CRASHED ON HOST: $host "
    echo "JOB: $JOB_ID CRASHED ON HOST: $host WITH OUTFILE $outfile_wo_path" > ${outdir}/crash/slurm${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}_crash.txt
fi

exit "$status"
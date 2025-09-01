#!/bin/bash

# script for submitting SMASH to SLURM
# author: Jedrzej Kolas
# date: 10.04.2024

# ===================== edit these =====================
submitDir="/your/path/to/submit/Smash"
outputDir="/your/path/to/output/Smash"
smashCofigFileName="config"
NumberOfJobs=100
email="k.jedrzej@gsi.de" # SLURM will send an e-mail once the batch has finished, crashed or was cancelled
# ======================================================

# create empty job file
if [ -f "jobfile.dat" ];
then
    echo "Found old jobfile. Creating an emplty one in its place."
    rm jobfile.dat
fi
touch jobfile.dat

# create output dir if there isn't one already
if [ ! -d "${outputDir}" ];
then 
    echo "Output directory was not found. Creating a new one under the path ${outputDir}."
    mkdir ${outputDir}
fi

# create SLURM output and crash dir if there isn't one already
if [ ! -d "${outputDir}/out" ];
then 
    echo "SLURM output directory was not found. Creating a new one under the path ${outputDir}/out."
    mkdir ${outputDir}/out
fi
if [ ! -d "${outputDir}/crash" ];
then
    echo "SLURM crash directory was not found. Creating a new one under the path ${outputDir}/crash."
    mkdir ${outputDir}/crash
fi

# create all output dirs and move necessary files into them
for job in $(seq $NumberOfJobs);
do
    mkdir ${outputDir}/job_${job}
    cp smash ${outputDir}/job_${job}/.
    cp ${smashCofigFileName}.yaml ${outputDir}/job_${job}/.
    echo "Directory ${outputDir}/job_${job} is ready."
    echo "${outputDir}/job_${job}" >> jobfile.dat
done

# move necessary files to submit dir
if [ ! -d "${submitDir}" ];
then 
    echo "SLURM submit directory was not found. Creating a new one under the path ${submitDir}."
    mkdir ${submitDir}
fi
cp jobfile.dat ${submitDir}/.
cp jobScriptSmash.sh ${submitDir}/.

# send job batch
sbatch --array=1-${NumberOfJobs} --job-name="SMASHing" --mem=2000 --time=0-48:00:00 --partition=long --mail-type=END --mail-user=${email} -D ${submitDir} --output=${SLURMout}/slurm-%A_%a.out -- ${submitDir}/jobScriptSmash.sh ${submitDir}/jobfile.dat ${outputDir}
#!/bin/bash

# script for submitting SMASH to SLURM
# author: Jedrzej Kolas
# date: 10.04.2024

# ===================== edit these =====================
envScript="/lustre/hades/user/kjedrzej/setEnvSmash.sh"
submitDir="/lustre/hades/user/kjedrzej/submit/Smash"
outputDir="/lustre/hades/user/kjedrzej/Smash"
smashCofigFileName="config"
NumberOfJobs=100
email="k.jedrzej@gsi.de" # will send an e-mail once the bash has finished / crashed / was cancelled
# ======================================================

# create empty job file
if [ -f "jobfile.dat" ];
then
    rm jobfile.dat
fi
touch jobfile.dat

# create output dir if there isn't one already
if [ ! -d "${outputDir}" ];
then 
    mkdir ${outputDir}
fi

# create SLURM output and crash dir if there isn't one already
SLURMout="${outputDir}/out"
if [ ! -d "${SLURMout}" ];
then 
    mkdir ${SLURMout}
fi
if [ ! -d "${outputDir}/crash" ];
then
    mkdir ${outputDir}/crash
fi

# create all output dirs and move necessary files into them
for job in $(seq $NumberOfJobs);
do
    mkdir ${outputDir}/job_${job}
    cp smash ${outputDir}/job_${job}/.
    cp ${smashCofigFileName}.yaml ${outputDir}/job_${job}/.
    echo "${outputDir}/job_${job}"
    echo "${outputDir}/job_${job}" >> jobfile.dat
done

# move necessary files to submit dir
if [ ! -d "${submitDir}" ];
then 
    mkdir ${submitDir}
fi
cp jobfile.dat ${submitDir}/.
cp jobScriptSmash.sh ${submitDir}/.

# send job batch
sbatch --array=1-${NumberOfJobs} --job-name="SMASHing" --mem=2000 --time=0-48:00:00 --partition=long --mail-type=END --mail-user=${email} -D ${submitDir} --output=${SLURMout}/slurm-%A_%a.out -- ${submitDir}/jobScriptSmash.sh ${submitDir}/jobfile.dat ${envScript} ${outputDir}
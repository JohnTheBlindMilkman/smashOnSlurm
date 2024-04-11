#!/bin/bash

# script for copying output files from SMASH into single direcotry (and enumerating them properly)
# author: Jedrzej Kolas
# date: 11.04.2024

# ===================== edit these =====================
lustreBase="/lustre/hades/user/kjedrzej/Smash"
smashJobBasename="job_"
smashOutputFormat="oscar"
smashCofigFileName="config"
outputDir="/lustre/hades/user/kjedrzej/SmashResults/AuAu_1p23AGeV_0_10cent"
NumberOfJobs=100
# ======================================================

iter=0
smashParticleList="particle_lists.${smashOutputFormat}"

# create the output direcotry if it doesn't exist
if [ ! -d "${outputDir}" ];
then 
    mkdir ${outputDir}
fi

# copy all files if the input exists and output does not, i.e. will not override already copied files
for job in $(seq ${NumberOfJobs})
do
    ifn=${lustreBase}/${smashJobBasename}${job}/data/0/${smashParticleList}

    if [ -f "${ifn}" ]; # if input exists
    then
        if [ ! -f "${outputDir}/${smashCofigFileName}.yaml" ]; # if not yet copied
        then
            cp -v ${lustreBase}/${smashJobBasename}${job}/${smashCofigFileName}.yaml ${outputDir}/.
        fi

        ofn="${outputDir}/particle_list_${iter}.${smashOutputFormat}"
        ((++iter))

        if [ -f "${ofn}" ]; # if output exists
        then 
            echo "File ${ofn} already exists"
        else
            cp -v ${ifn} ${ofn}
        fi
    else
        echo "File ${ifp} doesn't exist"
    fi
done
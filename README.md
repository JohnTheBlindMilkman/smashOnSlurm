# How to run SMASH on SLURM

1. Copy the `smash` and `setEnvSmash.sh` from /cvmfs/hadessoft.gsi.de/install/debian10/smash-3.0/

2. Create your `config.yaml` file for SMASH input as specified in the [documentation](https://smash-transport.github.io/).

3. Create you own send script and job script or use the ones provided by me: `sendSmash.sh` and `jobScriptSmash.sh` respectively.

4. Send jobs to SLURM, sit back, and relax.

5. *Optional:* move all results into single location for easier data analysis (you can use my `mergeSlurm.sh` script).

## Usage of sendSmash.sh

### Basic usage

The only part that will need to be changed by an average user is this:
```
# ===================== edit these =====================
envScript="/your/path/to/setEnvSmash.sh"
submitDir="/your/path/to/submit/Smash"
outputDir="/your/path/to/output/Smash"
smashCofigFileName="config"
NumberOfJobs=100
email="your.email@gsi.de"
# ======================================================
```

`envScript` is the absolute path to the location of the enviornmental script. Better keep it in lustre, the SLURM may not have access to your home directory.

`submitDir` is the directory in which the batch will be executed.

`outputDir` is the location of the output of SMASH and SLURM. The send script will create `out` and `crash` direcotry within it for SLURM output and N `job_N` directories for parallel execution of SMASH (where N is the number of jobs specified by the user).

`NumberOfJobs` is the amount of jobs to be created. Please be mindful of the amounts you run. I'm not responsible for what Jochen will do to you once you run too many jobs!

> **Mucho importante:** This is not a foolproof script! If you misspell any path or put a weird number of jobs, the shell script will not stop you. Be mindfull of what you do, becasue the consequences may be dire.

`smashCofigFileName` is the basename (without the .yaml extension) of the config file you wish to use for runnig SMASH. 

`email` is your e-mail address in gsi domain. You will be sent a notofocation once the batch has finished execution.

### For "advanced" users

You may want to play with the partition, the job wall time, and the allocated memory at your own risk. To do that please tak a look at the last command in `sendSmash.sh` file:
```
sbatch --array=1-${NumberOfJobs} --job-name="SMASHing" --mem=2000 --time=0-48:00:00 --partition=long --mail-type=END --mail-user=${email} -D ${submitDir} --output=${SLURMout}/slurm-%A_%a.out -- ${submitDir}/jobScriptSmash.sh ${submitDir}/jobfile.dat ${envScript} ${outputDir}
```

> Please note the `--mem`, `--time`, and `--partition` flags of the `sbatch` command.

## Usage of mergeSlurm.sh

Similar as above, the part that sould be modified is this:
```
# ===================== edit these =====================
lustreBase="/your/path/to/output/Smash"
smashJobBasename="job_"
smashOutputFormat="oscar"
smashCofigFileName="config"
outputDir="/your/path/to/SmashResults/AuAu_1p23AGeV_0_10cent"
NumberOfJobs=100
# ======================================================
```

`lustreBase` is the location of the output from SMASH launched as SLURM jobs (the directory with loads of SMASH folders).

`smashJobBasename` is the name of each SMASH folder in the output without the number at the end (I assume that the number is at the end of the folder name).

`smashOutputFormat` file extension of the particle_list file whete SMASH saves the information about its events and tracks.

`smashCofigFileName` same as in `sendSmash.sh`

`outputDir` location where you want the files to be copied into.

`NumberOfJobs` same as in `sendSmash.sh`

> Current implementation **copies** the files from one direcotry to another. If you find it too slow and you have no regrets in life you can switch the command in line 37 (`cp -v ${ifn} ${ofn}`) to move operation (`mv -v ${ifn} ${ofn}`).
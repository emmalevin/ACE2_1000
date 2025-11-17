#!/bin/bash
#SBATCH --job-name=ace2                # create a short name for your job
#SBATCH --output=slurm-%A.%a.out       # stdout file
#SBATCH --error=slurm-%A.%a.err        # stderr file
#SBATCH --nodes=1                      # node count
#SBATCH --ntasks=1                     # total number of tasks across all nodes
#SBATCH --cpus-per-task=1              # cpu-cores per task
#SBATCH --mem-per-cpu=32G              # memory per cpu-core
#SBATCH --time=5:00:00                # total run time limit (HH:MM:SS)
#SBATCH --array=0-9                     # job array indices 0..9
#SBATCH --account=gvecchi
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=el2358@princeton.edu

module purge
module load anaconda3/2025.6
conda activate geoclim

# Global year variable
YEAR=2013

# Define all date ranges
ALL_DATE_RANGES=("1_100" "101_200" "201_300" "301_400" "401_500" "501_600" "601_700" "701_800" "801_900" "901_1000")

# Determine which date range this array task should process
DATE_RANGE=${ALL_DATE_RANGES[$SLURM_ARRAY_TASK_ID]}
echo "Processing date range: $DATE_RANGE for YEAR=$YEAR"

# Set directories and files
data_in_dir="/scratch/gpfs/GVECCHI/el2358/ACE2_1000/${YEAR}/output/output_dir_${YEAR}_${DATE_RANGE}"
data_file="${data_in_dir}/autoregressive_predictions_tracking.nc"
# ZS file remains hardcoded
zsfile="/scratch/gpfs/GVECCHI/el2358/ACE2/tc_tracking/input/zs_2020.nc"
slp_file="${data_in_dir}/autoregressive_predictions_tracking_slp.nc"

dn_out_dir="/scratch/gpfs/GVECCHI/el2358/ACE2_1000/${YEAR}/tc_tracking/dn_txt"
sn_out_dir="/scratch/gpfs/GVECCHI/el2358/ACE2_1000/${YEAR}/tc_tracking/sn_txt"

dnfile="${dn_out_dir}/DN.ACE2.TC.${DATE_RANGE}.txt"
snfile="${sn_out_dir}/SN.ACE2.TC.${DATE_RANGE}.txt"

# Run DetectNodes
DetectNodes \
    --in_data "${data_file};${zsfile};${slp_file}" \
    --out "${dnfile}" \
    --searchbymin "slp" \
    --closedcontourcmd "slp,200.0,5.5,0;air_temperature_3,-0.4,6.5,1.0" \
    --mergedist 6.0 \
    --outputcmd "slp,min,0;_VECMAG(UGRD10m,VGRD10m).max,2;HGTsfc,min,0" \
    --latname "lat" \
    --lonname "lon"

# Run StitchNodes
StitchNodes \
    --in "${dnfile}" \
    --out "${snfile}" \
    --in_fmt "lon,lat,slp,wind10m,zs" \
    --range 8.0 \
    --mintime 54h \
    --maxgap 24h \
    --threshold "wind10m,>=,10.0,10;lat,<=,50.0,10;lat,>=,-50.0,10;zs,<=,150.0,10"

echo "✅ Finished processing date range: $DATE_RANGE"

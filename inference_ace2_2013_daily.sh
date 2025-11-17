#!/bin/bash
#SBATCH --job-name=ace2
#SBATCH --output=slurm-%A.%a.out
#SBATCH --error=slurm-%A.%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=32G
#SBATCH --gres=gpu:1
#SBATCH --time=12:00:00
#SBATCH --array=0-9
#SBATCH --account=gvecchi
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=el2358@princeton.edu

module purge
module load anaconda3/2025.6
conda activate geoclim

# ✅ Set the year here
YEAR=2013   # <-- change to 1982, 2005, 2009, 2010, 2013, etc.

# ✅ Chunk ranges
ranges=(
"1_100"
"101_200"
"201_300"
"301_400"
"401_500"
"501_600"
"601_700"
"701_800"
"801_900"
"901_1000"
)

CHUNK=${ranges[$SLURM_ARRAY_TASK_ID]}

python -m fme.ace.inference \
    /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${YEAR}/yaml/inference_ace2_${YEAR}_${CHUNK}.yaml \
    --override \
    experiment_dir=/scratch/gpfs/GVECCHI/el2358/ACE2_1000/${YEAR}/output/output_dir_${YEAR}_${CHUNK} \
    data_writer.save_prediction_files=true \
    data_writer.names='["UGRD10m","VGRD10m","surface_temperature","PRESsfc","air_temperature_3"]'

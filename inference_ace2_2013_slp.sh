#!/bin/bash
#SBATCH --job-name=ace2                # create a short name for your job
#SBATCH --output=slurm-%A.%a.out       # stdout file
#SBATCH --error=slurm-%A.%a.err        # stderr file
#SBATCH --nodes=1                      # node count
#SBATCH --ntasks=1                     # total number of tasks across all nodes
#SBATCH --cpus-per-task=1              # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=64G              # memory per cpu-core (4G is default)
#SBATCH --time=2:00:00                 # total run time limit (HH:MM:SS)
#SBATCH --array=0-9                    # job array indices 0..9
#SBATCH --account=gvecchi
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=el2358@princeton.edu

module purge
module load anaconda3/2025.6
conda activate geoclim

# Set year variable
year=2013

if [ "$SLURM_ARRAY_TASK_ID" -eq 0 ]; then

    python -u /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_1_100 

elif [ "$SLURM_ARRAY_TASK_ID" -eq 1 ]; then

    python /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_101_200 

elif [ "$SLURM_ARRAY_TASK_ID" -eq 2 ]; then

    python /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_201_300 

elif [ "$SLURM_ARRAY_TASK_ID" -eq 3 ]; then

    python /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_301_400 

elif [ "$SLURM_ARRAY_TASK_ID" -eq 4 ]; then

    python /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_401_500 

elif [ "$SLURM_ARRAY_TASK_ID" -eq 5 ]; then

    python /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_501_600 

elif [ "$SLURM_ARRAY_TASK_ID" -eq 6 ]; then

    python /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_601_700 

elif [ "$SLURM_ARRAY_TASK_ID" -eq 7 ]; then

    python /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_701_800 

elif [ "$SLURM_ARRAY_TASK_ID" -eq 8 ]; then

    python /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_801_900 

elif [ "$SLURM_ARRAY_TASK_ID" -eq 9 ]; then

    python -u /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/tc_tracking/code/slp_calculation_${year}.py \
        /scratch/gpfs/GVECCHI/el2358/ACE2_1000/${year}/output/output_dir_${year}_901_1000 

fi

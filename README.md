# Running 1,000 Ensembles of the ACE2 Model for TC analysis

This code supports the analysis presented in the paper titled "On the seasonal predictability of the 2020 North Atlantic tropical cyclone season" by Levin et al. If you use this repository or the methods implemented here in your research, please cite the following publication: https://eartharxiv.org/repository/view/12018/

The dataset generated from this code containing tropical cyclone (TC) track data and monthly mean large-scale environmental fields derived from a 1,000-member ensemble generated using the ACE2 deep-learning climate emulator are available at: 10.5281/zenodo.19456834

This repository contains scripts for generating **1,000 ensemble simulations** of the ACE2 atmosphere-only model for a single year (e.g., 2013) and subsequently **tracking tropical cyclones (TCs)** using the TempestExtremes algorithm. We then plot the distribution of simulated TC counts across the ensembles and fit the data to different distributions. 

**ACE2 model code:** https://github.com/ai2cm/ace

Conda environment to run ACE is in geoclim_env.yaml

---

## Overview

For a given target year (here, **2013**), we run the ACE2 model **1,000 times**.  
All simulations use the **same boundary forcing** (SST, sea ice, CO₂, etc.).  
The **only difference** between ensemble members is the **initial conditions**, which produces a large sample of internally generated atmospheric variability.

After all simulations are complete, we apply the **TempestExtremes** TC tracking algorithm to identify and track tropical cyclones across the 1,000-member ensemble.

---

## How the 1,000 Ensembles Are Generated

To efficiently create 1,000 simulations, we run the model in **ten 100-year “chunks”** in parallel:

- Each chunk starts from **different initial conditions**.
- Each chunk runs **100 consecutive 1-year simulations**, but **each year uses the same prescribed forcing** (e.g., 2013 SSTs repeated each year).
- The **final state of year _n_** becomes the **initial condition of year _n+1_**.

This structure yields:


Diagram of the configuration:  
<img width="857" height="338" alt="runs" src="https://github.com/user-attachments/assets/7f84aebe-e6c7-4d8d-80b5-8769297494a3" />

---

## Scripts Summary

A brief description of each script involved in the workflow is provided below.

### YAML Configuration Files

- **`inference_ace2_2013_1_100.yaml`** (and similar files for chunks 2–10)  
  Defines:
  - initial conditions  
  - forcing datasets  
  - run duration  
  - output variables  
  - ACE2 model parameters  
  There are **10 YAML files**, one for each 100-year chunk.

---

### Model Run Scripts

- **`inference_ace2_2013_monthly.sh`**  
  Runs ACE2 and saves **monthly** output fields relevant to large-scale environmental analysis (e.g., precipitation, winds).  
  Monthly output is used to reduce storage requirements.

- **`inference_ace2_2013_daily.sh`**  
  Runs ACE2 while saving **6-hourly** output, which is required for tropical cyclone tracking with TempestExtremes.

---

### Preprocessing Scripts

- **`data_file_preprocess_2013.py`**  
  Preprocesses model output (e.g., time variable formatting) to prepare the data for TC tracking.

- **`inference_ace2_2013_preprocess.sh`**  
  SLURM script that executes the preprocessing step.

---

### Sea Level Pressure Calculation

- **`slp_calculation_2013.py`**  
  Computes sea level pressure (SLP) from the model’s surface pressure output, since ACE2 does not provide SLP directly.

- **`inference_ace2_2013_slp.sh`**  
  SLURM script for running the SLP calculation.

---

### Tropical Cyclone Tracking

- **`inference_ace2_2013_track_tcs.sh`**  
  Runs the **TempestExtremes** tracking algorithm on the processed 6-hourly output to identify and track tropical cyclones.

---

### Tropical Cyclone Analysis

- **`distributions.ipynb`**  
  Counts the annual Atlantic TCs across the 1,000 ensembles, plots a histogram of the distribution, and fits the data to different discrete distributions using MLE estimation. 

---

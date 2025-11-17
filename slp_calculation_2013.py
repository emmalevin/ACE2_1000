#!/usr/bin/env python3
import xarray as xr
import numpy as np
import xarray.ufuncs as xu
from pathlib import Path
import argparse

# Constants
Rd = 287.0
g = 9.8

def main(folder):
    print("\n==========================")
    print("🚀 STARTING SLP SCRIPT")
    print("==========================")
    print(f"📁 Input folder argument: {folder}")

    # Convert folder path
    folder_path = Path(folder)
    print(f"📂 Converted to Path: {folder_path}")

    # Input surface height file (fixed for all cases)
    zs_file = "/scratch/gpfs/GVECCHI/el2358/ACE2/tc_tracking/input/zs_2020.nc"
    print(f"📎 Attempting to open surface height file: {zs_file}")

    try:
        zs = xr.open_dataset(zs_file)["HGTsfc"]
        print("✅ Surface height file loaded successfully (HGTsfc)")
    except Exception as e:
        print("❌ ERROR loading surface height file!")
        print(e)
        return

    print(f"📏 zs dimensions: {zs.dims}, shape: {zs.shape}")

    # Build input/output filenames
    infile = folder_path / "autoregressive_predictions_tracking.nc"
    outfile = folder_path / "autoregressive_predictions_tracking_slp.nc"

    print(f"\n📂 Processing input dataset: {infile}")
    print(f"💾 Output will be saved as: {outfile}")

    # Check if file exists
    if not infile.exists():
        print(f"❌ ERROR: Input file does not exist: {infile}")
        return

    # ---------------------- OPEN DATASET ----------------------
    print("\n🧩 Opening dataset with chunking (time=1460)...")
    try:
        ds = xr.open_dataset(infile, engine="h5netcdf", decode_times=False)
        ds = ds.chunk({"time": 1460})
        print("✅ Dataset opened successfully")
    except Exception as e:
        print("❌ ERROR opening dataset with xarray!")
        print(e)
        return

    print(f"📐 Dataset dims: {dict(ds.dims)}")
    print(f"📦 Dataset chunks: {ds.chunks}")

    # Extract variables
    print("\n🔍 Extracting required variables...")

    try:
        SP = ds["PRESsfc"]
        print("✅ PRESsfc variable found")
    except KeyError:
        print("❌ ERROR: PRESsfc not found in dataset!")
        return

    try:
        TS = ds["surface_temperature"]
        print("✅ surface_temperature variable found")
    except KeyError:
        print("❌ ERROR: surface_temperature not found in dataset!")
        return

    print(f"📏 SP dims: {SP.dims}, shape: {SP.shape}, dtype: {SP.dtype}")
    print(f"📏 TS dims: {TS.dims}, shape: {TS.shape}, dtype: {TS.dtype}")

    # ---------------------- SURFACE HEIGHT ALIGNMENT ----------------------
    print("\n🗺 Aligning surface height to dataset lat/lon grid...")

    try:
        H_fixed = xr.DataArray(
            zs.values,
            dims=("lat", "lon"),
            coords={"lat": TS.lat, "lon": TS.lon},
            name="HGTsfc",
        )
        print("✅ H_fixed DataArray created with TS coordinates")
    except Exception as e:
        print("❌ ERROR creating H_fixed DataArray!")
        print(e)
        return

    # Broadcast zs to match TS shape
    try:
        H_broadcast = H_fixed.broadcast_like(TS)
        print("✅ Broadcast of surface height successful")
    except Exception as e:
        print("❌ ERROR broadcasting HGTsfc to TS shape!")
        print(e)
        return

    print(f"📏 H_broadcast dims: {H_broadcast.dims}, shape: {H_broadcast.shape}")

    # ---------------------- HYPOSMETRIC CALCULATION ----------------------
    print("\n🧮 Computing hypsometric reduction (lazy computation)...")
    try:
        Href = Rd * TS / g
        print("✅ Href computed")
        SLP = SP * xu.exp(H_broadcast / Href)
        print("✅ SLP expression created (lazy)")
    except Exception as e:
        print("❌ ERROR computing SLP!")
        print(e)
        return

    # Add metadata
    SLP.attrs.update({
        "long_name": "Sea Level Pressure",
        "units": "Pa",
        "description": "Reduced to sea level using hypsometric equation with lowest-level T and surface height",
    })
    SLP.name = "slp"

    # ---------------------- SAVE RESULT ----------------------
    print("\n💾 Writing SLP to NetCDF...")
    try:
        SLP.to_netcdf(outfile, mode="w")
        print(f"✅ SLP file successfully written: {outfile}")
    except Exception as e:
        print("❌ ERROR writing NetCDF file!")
        print(e)
        return

    print("\n🎉 DONE — SCRIPT COMPLETED WITHOUT CRASHES")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compute SLP for ACE2 output folder.")
    parser.add_argument("folder", help="Path to ACE2 output directory")
    args = parser.parse_args()

    main(args.folder)

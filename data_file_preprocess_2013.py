#!/usr/bin/env python3
import xarray as xr
from pathlib import Path
import argparse
import warnings

# Suppress irrelevant warnings
warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=RuntimeWarning)

def main(folder):
    folder = Path(folder)
    infile = folder / "autoregressive_predictions.nc"
    outfile = folder / "autoregressive_predictions_tracking.nc"

    print(f"\n📂 Input file: {infile}")
    print(f"💾 Output file: {outfile}")

    if not infile.exists():
        print(f"❌ ERROR: Input file does not exist!")
        return

    # Open dataset with chunks
    try:
        ds = xr.open_dataset(infile, chunks={"time": 1460})
        print("✅ Dataset opened successfully")
        print(f"   Dims: {ds.dims}")
        print(f"   Variables: {list(ds.variables)}")
    except Exception as e:
        print(f"❌ ERROR opening dataset: {e}")
        return

    # 2) Extract init_time BEFORE squeezing
    try:
        init_raw = ds["init_time"].values[0]  # safe: sample=1
        init = str(init_raw).split(".")[0]    # strip nanoseconds
    except KeyError:
        print("❌ ERROR: init_time missing")
        ds.close()
        return

    # 1) Squeeze sample dimension if it exists
    if "sample" in ds.dims:
        ds = ds.squeeze("sample", drop=True)
        print("🗑️ Dropped 'sample' dimension")
    else:
        print("ℹ️ No 'sample' dimension found")

    # 2) Build time coordinate from init_time + 6-hour steps
    try:
        # Create CFTime index with 6-hour steps
        times = xr.cftime_range(
            start=init,
            periods=ds.sizes["time"],
            freq="6H",
            calendar="proleptic_gregorian"
        )

        ds = ds.assign_coords(time=times)
        print(f"🕒 Set time from init_time starting at {init}")
        print("✅ Updated time variable to CFTime with proleptic_gregorian calendar")

    except Exception as e:
        print(f"❌ ERROR building CFTime from init_time: {e}")
        ds.close()
        return

    # Update time encoding
    try:
        #ds.time.encoding.clear()
        ds.time.encoding.update({'units': 'hours since 1970-01-01 00:00:00', 'calendar': 'proleptic_gregorian'})
    except Exception as e:
        print(f"⚠️ WARNING: Could not read time encoding: {e}")

    # 4) Write dataset to output file
    try:
        ds.to_netcdf(outfile, mode='w')
        print(f"💾 Successfully wrote: {outfile}")
    except Exception as e:
        print(f"❌ ERROR writing file: {e}")
    finally:
        ds.close()
        print("🛑 Closed dataset")

        if Path(outfile).exists():
            infile.unlink()
            print(f"🗑️ Deleted original file: {infile}")
        else:
            print("⚠️ Output file not found — original NOT deleted")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process autoregressive_predictions.nc")
    parser.add_argument("folder", help="Path to ACE2 output directory")
    args = parser.parse_args()
    main(args.folder)

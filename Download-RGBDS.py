import os
import zipfile
import requests

# Constants
url = "https://github.com/gbdev/rgbds/releases/download/v0.7.0/rgbds-0.7.0-win64.zip"
zip_filename = "rgbds-0.7.0-win64.zip"
extract_dir = "rgbds"

# Step 1: Download the ZIP file
print("Downloading RGBDS 0.7.0...")
response = requests.get(url)
with open(zip_filename, "wb") as f:
    f.write(response.content)
print("Download complete.")

# Step 2: Extract only .exe files
print("Extracting .exe files...")
with zipfile.ZipFile(zip_filename, "r") as zip_ref:
    for file in zip_ref.namelist():
        if file.endswith(".exe"):
            zip_ref.extract(file, extract_dir)
print("Extraction complete.")

# Step 3: Delete the ZIP file
os.remove(zip_filename)
print(f"Deleted {zip_filename}. Done.")

#!/usr/bin/env python3
import requests
import os
from pathlib import Path

# Model repository information
model_repo = "bartowski/magnum-v4-123b-GGUF"
model_name = "magnum-v4-123b-Q8_0"
base_url = f"https://huggingface.co/{model_repo}/resolve/main/{model_name}"

# Get the list of files from the API
api_url = f"https://huggingface.co/api/models/{model_repo}"
response = requests.get(api_url)
data = response.json()

# Get the sibling files for the Q8_0 directory
siblings_url = f"https://huggingface.co/api/models/{model_repo}/tree/main/{model_name}"
siblings_response = requests.get(siblings_url)
siblings = siblings_response.json()

print(f"Found {len(siblings)} files in the {model_name} directory")
print("\nFiles to download:")
for file_info in siblings:
    if isinstance(file_info, dict) and 'path' in file_info:
        filename = file_info['path']
        size = file_info.get('size', 'unknown')
        print(f"  - {filename} ({size} bytes)")

# Create the output directory
output_dir = Path("/home/vmlinux/models")
output_dir.mkdir(exist_ok=True)

# Download each file
for file_info in siblings:
    if isinstance(file_info, dict) and 'path' in file_info:
        filename = file_info['path']
        file_url = f"https://huggingface.co/{model_repo}/resolve/main/{filename}"

        output_path = output_dir / filename.split('/')[-1]
        print(f"\nDownloading {filename}...")

        response = requests.get(file_url, stream=True)
        response.raise_for_status()

        total_size = int(response.headers.get('content-length', 0))
        downloaded = 0

        with open(output_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
                downloaded += len(chunk)
                if total_size > 0:
                    percent = (downloaded / total_size) * 100
                    print(f"\r  Progress: {percent:.1f}%", end='', flush=True)

        print(f"\n  Downloaded to {output_path}")

print("\nDownload complete!")

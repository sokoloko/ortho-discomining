#!/usr/bin/env bash
set -euo pipefail

echo "[1/6] Installing core Ubuntu packages"
sudo apt update
sudo apt install -y curl wget unzip zip git build-essential jq csvkit \
  python3 python3-pip default-jre seqkit mafft hmmer

echo "[2/6] Installing micromamba"
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)

# shellcheck disable=SC1090
source ~/.bashrc || true

echo "[3/6] Configuring channels"
micromamba config append channels bioconda
micromamba config append channels conda-forge
micromamba config set channel_priority strict

echo "[4/6] Creating project environment"
micromamba create -n trospa -y mmseqs2 diamond iqtree entrez-direct

echo "[5/6] Installing NCBI Datasets CLI"
mkdir -p "$HOME/bin"
cd "$HOME/bin"
curl -Lo datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets'
curl -Lo dataformat 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/dataformat'
chmod +x datasets dataformat

if ! grep -q 'export PATH=$HOME/bin:$PATH' "$HOME/.bashrc"; then
  echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bashrc"
fi

mkdir -p "$HOME/projects/ixodes-trospa-sop"/{accessions,data/seed,data/candidates,data/results,logs,tmp,docs,scripts,templates}

echo "[6/6] Setup complete"
echo
echo "Next steps:"
echo "  source ~/.bashrc"
echo "  micromamba activate trospa"
echo "  seqkit version"
echo "  mafft --version"
echo "  hmmsearch -h | head"
echo "  jackhmmer -h | head"
echo "  mmseqs version"
echo "  diamond version"
echo "  iqtree2 --version"
echo "  esearch -help | head"
echo "  datasets version"
echo "  dataformat version"

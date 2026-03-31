# Onboarding and install checklist

This page is for Gavin. The goal is to create a stable, low-friction working environment on **Ubuntu LTS in VirtualBox** without downloading large datasets unless there is a clear reason.

## What to install

Use:
- **APT** for basic Linux tools
- **micromamba + Bioconda** for bioinformatics packages
- **NCBI Datasets CLI** from NCBI binaries
- **SRA Toolkit only later**, if raw-read rescue becomes necessary

## Before you begin

- Confirm you are inside the Ubuntu VM, not Windows PowerShell
- Make sure you have internet access from the VM
- Open a terminal
- Create a working folder:

```bash
mkdir -p ~/projects/ixodes-trospa-sop
cd ~/projects/ixodes-trospa-sop
```

## Step 1: install core Ubuntu packages

```bash
sudo apt update
sudo apt install -y curl wget unzip zip git build-essential jq csvkit \
  python3 python3-pip default-jre seqkit mafft hmmer
```

## Step 2: install micromamba

Official page: https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html

```bash
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
source ~/.bashrc
micromamba --version
```

## Step 3: configure Bioconda and conda-forge

Official page: https://bioconda.github.io/

```bash
micromamba config append channels bioconda
micromamba config append channels conda-forge
micromamba config set channel_priority strict
```

## Step 4: create the project environment

```bash
micromamba create -n trospa -y \
  mmseqs2 diamond iqtree entrez-direct
micromamba activate trospa
```

## Step 5: install NCBI Datasets CLI

Official page: https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/

```bash
mkdir -p ~/bin
cd ~/bin
curl -Lo datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets'
curl -Lo dataformat 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/dataformat'
chmod +x datasets dataformat
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

## Step 6: verify the tools

```bash
seqkit version
mafft --version
hmmsearch -h | head
jackhmmer -h | head
micromamba --version
mmseqs version
diamond version
iqtree2 --version
esearch -help | head
datasets version
dataformat version
```

## Do not install yet

Do **not** install these until the SOP explicitly reaches that stage:
- SRA Toolkit
- Trinity
- rnaSPAdes
- local BLAST databases
- nr or nt
- whole tick genome packages

## Working rules

- Use **remote query first**
- Download **only accessions or small FASTA files** unless a bigger download is justified
- Keep a simple lab notebook of what you did and why
- Save accession lists as plain text files
- Keep metadata tables updated

## Initial working directories

```bash
mkdir -p accessions data/seed data/candidates data/results logs tmp
```

## First files to create

Create `accessions/seed_ids.txt` with one accession per line, for example:

```text
Q5SDL7
A7UAJ3
```

`Q5SDL7` is the anchor seed. `A7UAJ3` should be treated as a supporting unreviewed seed.

## Safe default mindset

The default pattern for this project is:

**remote query -> accession list -> small FASTA retrieval -> local curation -> bulk download only if unresolved**

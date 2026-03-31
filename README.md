# SOP for mining and establishing TROSPA orthologs from _Ixodes_ ticks

Reproducible, remote-first SOP for building a curated **Ixodes TROSPA** sequence dataset for downstream comparative and co-evolutionary analysis with **Borrelia OspA**.

## Project goal

This repository documents a lightweight workflow for identifying, retrieving, curating, and validating **TROSPA/TrospA** protein candidates from **Ixodes** ticks while minimizing large downloads. The workflow is designed for a beginner lab member working on **Ubuntu LTS in VirtualBox on a Windows laptop**.

## Core principles

- Start from a **strict seed set**
- Use **remote query -> accession list -> small FASTA retrieval -> local curation -> bulk download only if unresolved**
- Treat **UniProt Q5SDL7** (*Ixodes scapularis*) as the anchor seed
- Treat **UniProt A7UAJ3** (*Ixodes ricinus*) as a supporting **unreviewed** seed
- Use **Ixodes[Organism]** or **taxid 6944** for genus-restricted remote searches
- Keep three evidence tiers:
  - **Tier 1**: genome/proteome-backed proteins
  - **Tier 2**: transcript-supported proteins
  - **Tier 3**: provisional SRA-derived candidates
- Do not use sequence length alone as a hard rejection rule
- Do not define orthology by clustering alone
- Do not mix Tier 3 into the canonical dataset before validation

## Repository layout

```text
.
├── README.md
├── docs
│   ├── onboarding.md
│   ├── sop.md
│   └── flowchart.md
├── scripts
│   ├── setup_trospa_vm.sh
│   └── fetch_candidates.sh
├── templates
│   └── trospa_master_metadata.tsv
└── .github
    └── copilot-instructions.md
```

## Quick start

1. Read [`docs/onboarding.md`](docs/onboarding.md)
2. Run the setup steps in [`scripts/setup_trospa_vm.sh`](scripts/setup_trospa_vm.sh)
3. Build the initial seed accessions list
4. Use [`scripts/fetch_candidates.sh`](scripts/fetch_candidates.sh) to retrieve small FASTA batches by accession
5. Follow [`docs/sop.md`](docs/sop.md) for curation and validation
6. Use [`docs/flowchart.md`](docs/flowchart.md) as the visual map

## Data policy

Do **not** commit:
- FASTQ files
- genome ZIP packages
- DIAMOND or BLAST databases
- large intermediate assemblies
- large HMMER search outputs unless compressed and justified

Do commit:
- Markdown docs
- shell scripts
- small example FASTAs
- metadata tables
- accession lists
- decision logs
- flowchart source

## Suggested next additions

- `accessions/seed_ids.txt`
- `results/decision_log.tsv`
- `results/accepted_trospa.faa`
- `results/rejected_or_flagged.faa`

## Official software pages

- Micromamba: https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html
- Bioconda: https://bioconda.github.io/
- NCBI Datasets CLI: https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/
- EDirect: https://www.ncbi.nlm.nih.gov/books/NBK179288/
- BLAST+ CLI: https://www.ncbi.nlm.nih.gov/books/NBK569839/
- HMMER: https://hmmer.org/
- MAFFT: https://mafft.cbrc.jp/alignment/software/
- MMseqs2: https://github.com/soedinglab/MMseqs2
- DIAMOND: https://github.com/bbuchfink/diamond
- IQ-TREE 2: https://www.iqtree.org/
- SRA Toolkit: https://www.ncbi.nlm.nih.gov/sra/docs/toolkitsoft/

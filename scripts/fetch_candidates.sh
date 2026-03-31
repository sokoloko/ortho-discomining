#!/usr/bin/env bash
set -euo pipefail

# Remote-first candidate retrieval workflow.
# Requires:
#   - EDirect in PATH
#   - optionally BLAST+ in PATH if using remote BLAST
#
# Usage:
#   ./scripts/fetch_candidates.sh accessions/seed_ids.txt
#
# This script:
#   1. fetches seed proteins
#   2. optionally runs remote BLAST against nr restricted to Ixodes
#   3. extracts candidate protein accessions
#   4. fetches candidate proteins by accession

SEED_FILE="${1:-accessions/seed_ids.txt}"

mkdir -p data/seed data/candidates accessions logs

if [[ ! -s "$SEED_FILE" ]]; then
  echo "Seed accession file not found or empty: $SEED_FILE" >&2
  exit 1
fi

echo "[1/4] Fetching seed protein FASTA"
cat "$SEED_FILE" | epost -db protein | efetch -format fasta > data/seed/trospa_seed_raw.faa

echo "[2/4] Seed stats"
seqkit stats data/seed/trospa_seed_raw.faa

if command -v blastp >/dev/null 2>&1; then
  echo "[3/4] Running remote BLAST against nr restricted to Ixodes"
  blastp -query data/seed/trospa_seed_raw.faa -db nr -remote \
    -entrez_query "Ixodes[Organism]" \
    -max_target_seqs 500 \
    -outfmt '6 qseqid sseqid pident length evalue bitscore stitle sscinames' \
    > data/candidates/ixodes_remote_blast.tsv

  cut -f2 data/candidates/ixodes_remote_blast.tsv | sort -u > accessions/candidate_protein_ids.txt

  echo "[4/4] Fetching candidate proteins"
  cat accessions/candidate_protein_ids.txt | epost -db protein | efetch -format fasta > data/candidates/ixodes_candidate_proteins.faa

  echo "Candidate stats:"
  seqkit stats data/candidates/ixodes_candidate_proteins.faa
else
  echo "blastp not found; skipping remote BLAST step."
  echo "Install BLAST+ separately or generate accessions/candidate_protein_ids.txt another way."
fi

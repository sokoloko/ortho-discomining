# SOP: remote-first TROSPA dataset building

## Purpose

Build a curated **Ixodes TROSPA** candidate set suitable for orthology review and later co-evolution analysis with **Borrelia OspA**, while minimizing large downloads.

## Important biological and operational rules

- Use **Q5SDL7** as the anchor seed
- Treat **A7UAJ3** as a supporting **unreviewed** seed
- Use **Ixodes[Organism]** or **taxid 6944** for remote Ixodes-restricted searches
- Do **not** reject sequences based on length alone
- Do **not** define orthology by clustering alone
- Do **not** accept annotation labels alone as proof
- Do **not** mix raw-read provisional sequences into the canonical set before validation

---

## Unit 1: build the initial seed set

Create a plain-text accession list in `accessions/seed_ids.txt`.

Example:

```text
Q5SDL7
A7UAJ3
```

Fetch the seed proteins with EDirect.

Official page: https://www.ncbi.nlm.nih.gov/books/NBK179288/

```bash
mkdir -p data/seed
cat accessions/seed_ids.txt | epost -db protein | efetch -format fasta > data/seed/trospa_seed_raw.faa
```

Inspect the FASTA:

```bash
seqkit stats data/seed/trospa_seed_raw.faa
seqkit fx2tab -n -l data/seed/trospa_seed_raw.faa
```

If needed, manually review the UniProt pages before finalizing the strict seed set.

---

## Unit 2: reconnaissance by remote BLAST against Ixodes proteins in nr

This step is for **candidate discovery only**, not final family definition.

Official BLAST+ page: https://www.ncbi.nlm.nih.gov/books/NBK569839/

If BLAST+ is not installed, add it separately later. If installed, use:

```bash
mkdir -p data/candidates
blastp -query data/seed/trospa_seed_raw.faa -db nr -remote \
  -entrez_query "Ixodes[Organism]" \
  -max_target_seqs 500 \
  -outfmt '6 qseqid sseqid pident length evalue bitscore stitle sscinames' \
  > data/candidates/ixodes_remote_blast.tsv
```

Extract the candidate protein accessions:

```bash
cut -f2 data/candidates/ixodes_remote_blast.tsv | sort -u > accessions/candidate_protein_ids.txt
```

Fetch only those protein sequences:

```bash
cat accessions/candidate_protein_ids.txt | epost -db protein | efetch -format fasta > data/candidates/ixodes_candidate_proteins.faa
```

Check what you downloaded:

```bash
seqkit stats data/candidates/ixodes_candidate_proteins.faa
```

---

## Unit 3: local alignment and HMM construction

Use MAFFT first. For the curated family alignment, prefer **L-INS-i**.

Official page: https://mafft.cbrc.jp/alignment/software/

```bash
mkdir -p data/results
mafft --localpair --maxiterate 1000 data/candidates/ixodes_candidate_proteins.faa \
  > data/results/trospa_candidates_linsi.aln.faa
```

Build the HMM.

Official page: https://hmmer.org/

```bash
hmmbuild data/results/trospa_ixodes.hmm data/results/trospa_candidates_linsi.aln.faa
```

Search the candidate FASTA back with the HMM:

```bash
hmmsearch \
  --tblout data/results/trospa_hmmsearch.tbl \
  --domtblout data/results/trospa_hmmsearch.domtbl \
  data/results/trospa_ixodes.hmm \
  data/candidates/ixodes_candidate_proteins.faa \
  > data/results/trospa_hmmsearch.out
```

Optional iterative expansion with jackhmmer:

```bash
jackhmmer \
  -N 5 \
  --incE 1e-5 \
  --tblout data/results/trospa_jackhmmer.tbl \
  data/seed/trospa_seed_raw.faa \
  data/candidates/ixodes_candidate_proteins.faa \
  > data/results/trospa_jackhmmer.out
```

---

## Unit 4: candidate triage

For each candidate, assign one status:
- `accept`
- `review`
- `reject_fragment`
- `reject_nonhomolog`

Use the metadata template in `templates/trospa_master_metadata.tsv`.

### Review flags

Flag for review if:
- candidate is much shorter or longer than expected
- candidate has only partial HMM coverage
- candidate is an alternative isoform
- candidate appears duplicated within a species
- candidate has weak support but plausible biological context

### Hard reject

Reject if:
- obvious wrong taxon or contamination
- severe truncation with no rescuable evidence
- low-complexity-only match
- exact duplicate of a better same-locus sequence
- no meaningful alignment coverage to the family model

---

## Unit 5: within-species duplicate reduction

Do **not** cluster broadly at the start.

First collapse only:
- exact duplicates
- exact subsequences
- same-locus isoforms if one is clearly preferable

Optional MMseqs2 duplicate reduction for near-identical within-species records:

Official page: https://github.com/soedinglab/MMseqs2

```bash
mmseqs easy-cluster \
  data/candidates/ixodes_candidate_proteins.faa \
  data/results/mmseqs_clusters \
  tmp/mmseqs_tmp \
  --min-seq-id 0.98 \
  -c 0.95
```

Interpret the output carefully. Do not use this as the sole orthology rule.

---

## Unit 6: tree-based orthology review

Use a curated alignment and infer a quick maximum-likelihood tree.

Official page: https://www.iqtree.org/

```bash
iqtree2 -s data/results/trospa_candidates_linsi.aln.faa -m MFP -bb 1000 -nt AUTO
```

Interpretation:
- accepted TROSPA candidates should cluster with known seeds
- suspicious long branches should be reviewed
- species-specific duplicates may represent real paralogs and should not be deleted automatically

Expected broad pattern to test later:
- North American and Eurasian Ixodes species may separate into distinct clades, but do not force this expectation onto weak data

---

## Unit 7: transcript-first rescue for missing species

Before touching raw SRA reads, try to retrieve:
- annotated protein records
- transcript accessions
- TSA entries
- lightweight transcript FASTAs

Fetch only the specific accessioned sequences you need.

If you recover transcripts, translate ORFs locally using the tool you trust for your lab workflow. Keep the resulting proteins separate until validated.

---

## Unit 8: raw SRA rescue only if still necessary

Use this only for species or tissues still missing TROSPA after assembled resources are exhausted.

### Step 8A: shortlist SRA runs by metadata

Search for:
- Ixodes
- RNA-seq
- gut or midgut
- paired-end if possible

Keep a run shortlist in `accessions/sra_shortlist.txt`.

### Step 8B: install SRA Toolkit only if needed

Official page: https://www.ncbi.nlm.nih.gov/sra/docs/toolkitsoft/

### Step 8C: screen reads with DIAMOND blastx

Build a small protein DB from the strict seed set:

```bash
diamond makedb --in data/seed/trospa_seed_raw.faa -d data/seed/trospa_seed_db
```

Then screen shortlisted reads:

```bash
diamond blastx \
  --db data/seed/trospa_seed_db.dmnd \
  --query sample.fastq.gz \
  --out data/results/sample_vs_trospa.m8 \
  --outfmt 6 qseqid sseqid pident length evalue bitscore qstart qend sstart send \
  --evalue 1e-5 \
  --max-target-seqs 10 \
  --threads 8
```

Only proceed to assembly if:
- multiple reads hit across the protein
- the hits are not all confined to one tiny low-complexity region
- the biological context makes sense

### Step 8D: treat recovered proteins as Tier 3 provisional

Do not merge them into the canonical set until they pass the same alignment, HMM, and tree checks as Tier 1 and Tier 2 candidates.

---

## Unit 9: final accepted set

The final accepted set should:
- have one metadata row per accepted sequence
- preserve provenance
- separate accepted, rejected, and provisional sequences
- exclude unvalidated raw-read-derived fragments
- be ready for downstream comparative analysis

Recommended output files:
- `results/accepted_trospa.faa`
- `results/rejected_or_flagged.faa`
- `results/provisional_tier3.faa`
- `results/decision_log.tsv`

---

## Minimal command sequence

```bash
# 1. Fetch seed proteins
cat accessions/seed_ids.txt | epost -db protein | efetch -format fasta > data/seed/trospa_seed_raw.faa

# 2. Remote BLAST reconnaissance
blastp -query data/seed/trospa_seed_raw.faa -db nr -remote \
  -entrez_query "Ixodes[Organism]" \
  -max_target_seqs 500 \
  -outfmt '6 qseqid sseqid pident length evalue bitscore stitle sscinames' \
  > data/candidates/ixodes_remote_blast.tsv

# 3. Fetch candidate proteins
cut -f2 data/candidates/ixodes_remote_blast.tsv | sort -u > accessions/candidate_protein_ids.txt
cat accessions/candidate_protein_ids.txt | epost -db protein | efetch -format fasta > data/candidates/ixodes_candidate_proteins.faa

# 4. Align and build HMM
mafft --localpair --maxiterate 1000 data/candidates/ixodes_candidate_proteins.faa > data/results/trospa_candidates_linsi.aln.faa
hmmbuild data/results/trospa_ixodes.hmm data/results/trospa_candidates_linsi.aln.faa

# 5. Search and review
hmmsearch --tblout data/results/trospa_hmmsearch.tbl --domtblout data/results/trospa_hmmsearch.domtbl \
  data/results/trospa_ixodes.hmm data/candidates/ixodes_candidate_proteins.faa > data/results/trospa_hmmsearch.out

# 6. Tree
iqtree2 -s data/results/trospa_candidates_linsi.aln.faa -m MFP -bb 1000 -nt AUTO
```

# TROSPA pipeline flowchart

This diagram is designed to explain the workflow to a beginner and to reinforce the project's remote-first philosophy.

## Mermaid source

```mermaid
flowchart TD
    A[Start project] --> B[Install tools on Ubuntu VM]
    B --> C[Create strict seed accession list]
    C --> D[Fetch only seed protein FASTAs]
    D --> E[Remote BLAST against nr restricted to Ixodes]
    E --> F[Collect candidate protein accessions]
    F --> G[Fetch only candidate protein FASTAs]
    G --> H[Local alignment with MAFFT L-INS-i]
    H --> I[Build HMM with hmmbuild]
    I --> J[Search candidates with hmmsearch or jackhmmer]
    J --> K{Candidate passes initial review?}
    K -->|Yes| L[Add metadata row and keep for tree review]
    K -->|Review| M[Flag for manual inspection]
    K -->|No| N[Reject and record reason]
    L --> O[Reduce exact duplicates and same-locus isoforms]
    M --> O
    O --> P[Infer ML tree with IQ-TREE 2]
    P --> Q{Supported TROSPA placement?}
    Q -->|Yes| R[Accept Tier 1 or Tier 2]
    Q -->|Unclear| S[Keep flagged for review]
    Q -->|No| T[Reject]
    R --> U{Missing species remain?}
    S --> U
    T --> U
    U -->|No| V[Freeze accepted dataset]
    U -->|Yes| W[Mine transcript resources first]
    W --> X{Recovered from transcripts/TSA?}
    X -->|Yes| H
    X -->|No| Y[Shortlist gut or midgut SRA runs]
    Y --> Z[Screen reads with DIAMOND blastx]
    Z --> AA{Strong evidence?}
    AA -->|No| V
    AA -->|Yes| AB[Assemble targeted candidates]
    AB --> AC[Validate as provisional Tier 3]
    AC --> H
```

## Interpretation

The central idea is simple:

- stay remote as long as possible
- retrieve only small accession-based FASTA files first
- use local alignment, HMM, and tree review for curation
- use transcript and SRA rescue only for remaining gaps
- keep provisional evidence separate until validated

## Website structure recommendation

If you turn this into GitHub Pages later, keep the navigation simple:

- Home: `README.md`
- Install: `docs/onboarding.md`
- Workflow: `docs/sop.md`
- Flowchart: `docs/flowchart.md`

That is enough for a clean documentation site.

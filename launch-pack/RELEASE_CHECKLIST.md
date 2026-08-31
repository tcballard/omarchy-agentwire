# Release checklist

| Gate | Requirement | Evidence or observation | Result | Owner | Next action |
| --- | --- | --- | --- | --- | --- |
| Release identity | Version, build, date, and availability agree | Manifest and README say 0.2.0; listing and GitHub release do not yet exist. | Qualified | Tom Ballard | Bind final draft to the post-merge `main` SHA. |
| Claims | Every used claim is verified or visibly qualified | `CLAIMS_LEDGER.md` separates CI, compatibility preflight, manual runtime evidence, release, and publication. | Pass | Tom Ballard | Preserve qualifications in the public issue. |
| Assets | Required outputs exist and open correctly | Submission draft, README, manifest, and license exist; root preview is optional and omitted. | Pass | Tom Ballard | Use marketplace fallback preview unless custom artwork is later approved. |
| Technical | Channel and submission constraints pass | Marketplace validator passed at `86f8e47365fdaca96f79cf08ca515675f31a6fe7`; static baseline requires review. | Qualified | Tom Ballard | Rerun both checks against final `main`. |
| Accessibility | Captions, contrast, text alternatives, and readability pass | No custom media is included; marketplace fallback owns its presentation. | Pass | Tom Ballard | Add accessible review only if a custom preview is introduced. |
| Privacy | No secrets, private data, or embargoed details leak | Submission draft contains only public repository facts and checksums. | Pass | Tom Ballard | Recheck final diff before submission. |
| Links | Destinations and calls to action work | Public repository and marketplace repository were read live. | Pass | Tom Ballard | Recheck immediately before issue creation. |
| Provenance | Required source and model contribution records exist | Pinned source SHAs, binary digest, CI run, and baseline result are recorded. | Pass | Tom Ballard | Replace preflight SHA with final submission SHA. |
| Runtime matrix | Real Omarchy install and interactions are observed | Hands-on matrix is intentionally deferred to another machine. | Blocked | Tom Ballard | Complete `docs/RELEASING.md` matrix and retain evidence. |
| Authority | Publisher and manual action are explicit | No issue was created; the owner must confirm all five declarations and approve publication. | Blocked | Tom Ballard | Show the final title and body and request one explicit approval. |

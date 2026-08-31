# Asset inventory

| ID | Asset | Purpose | Source or provenance | Constraints | Output path | Status | Blocker or next action |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A01 | Storefront title and issue body | Exact-schema marketplace submission | Current marketplace `SUBMISSION.md` and issue form | Preserve six headings, order, category, tags, and checklist text | `launch-pack/outputs/storefront-submission.md`, `launch-pack/outputs/storefront-issue-body.md` | Prepared | Owner reviews and approves after final preflight |
| A02 | Maintainer review notes | Explain permissions, binary provenance, and expected baseline result | Repository source, digest, CI, and dry-run marketplace scan | Must be updated to the final exact commit | Included in A01 | Prepared | Rerun baseline after merge and update commit references |
| A03 | Root preview image | Optional marketplace card and detail artwork | No approved real-machine screenshot exists | Root filename and supported format; maximum 50 MB and 40 megapixels | Marketplace fallback | Omitted | Optional; capture or create only if the owner wants custom artwork |
| A04 | Installation and removal documentation | Required repository listing material | Root README and Omarchy plugin command | Must remain accurate for mutable upstream install | `README.md` | Prepared | Confirm on the hands-on target machine |
| A05 | License and dependency disclosure | Required repository listing material | MIT license and runtime requirements section | Must name architecture, commands, writes, process, network, and privileges | `LICENSE`, `README.md` | Prepared | Review in pull request |

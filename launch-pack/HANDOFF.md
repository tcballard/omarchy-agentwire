# Launch handoff

- Product: AgentWire for Omarchy
- Release: Omarchy Plugin Marketplace initial listing
- Version: 0.2.0
- Build: Preflight at `86f8e47365fdaca96f79cf08ca515675f31a6fe7`; final SHA not yet set
- Pack status: Storefront copy prepared; publication gates remain
- Publication authority: Tom Ballard; no issue creation is authorized by this pack
- Exact next action: Run the hands-on Omarchy matrix on the target machine

## Included deliverables

| Channel | Output | Status | Claim IDs | Notes |
| --- | --- | --- | --- | --- |
| Omarchy Plugin Marketplace | `launch-pack/outputs/storefront-submission.md` and `launch-pack/outputs/storefront-issue-body.md` | Prepared | C01, C02, C03, C04, C05, C06 | Exact current issue schema with reviewer notes and five required declarations |
| Repository listing support | Root README runtime requirements and permissions | Prepared | C03, C04, C05 | Makes dependencies and unsandboxed behavior explicit |

## Omitted or not-applicable deliverables

- No submission issue was created.
- No marketplace preview is required; the current plan uses the marketplace fallback.
- No tag, GitHub release, release asset, social post, or deployment is part of this preparation.

## Claims

- Verified: Repository shape, CI at the merged implementation commit, plugin behavior from source and automated tests, binary digest and provenance.
- Qualified: Omarchy version support and marketplace readiness pending the hands-on matrix and final exact-commit rerun.
- Blocked or removed: Any claim that the plugin is released, listed, automatically security-passed, or hands-on verified.

## Validation performed

- Live marketplace compatibility validator passed for public commit `86f8e47365fdaca96f79cf08ca515675f31a6fe7`.
- Live marketplace static security baseline returned manual review required. The bundled executable is an expected review capability. CI-only remote source validation produced a non-blocking finding even though the scripts require full lowercase SHAs, detached checkouts, exact HEAD matches, and clean trees before execution.
- Plugin CI run 33388977416 completed successfully at the same commit.
- Bundled executable digest matched `bin/agentwire-x86_64.sha256`.

## Remaining decisions and blockers

- Complete and retain the real-machine Omarchy matrix.
- Merge the storefront-prep pull request, then rerun validator and baseline against the new exact `main` SHA.
- Review the final baseline report and update the maintainer notes if its evidence changes.
- Tom Ballard must personally confirm ownership, permissions, configuration behavior, and the marketplace disclaimer, then explicitly authorize creation of the public issue.

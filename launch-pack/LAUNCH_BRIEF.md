# Launch brief

- Product: AgentWire for Omarchy
- Release: Omarchy Plugin Marketplace initial listing
- Version: 0.2.0
- Build: Marketplace preflight source commit `86f8e47365fdaca96f79cf08ca515675f31a6fe7`; final submission must use the post-prep `main` SHA
- Release state: Public `main` implementation merged; GitHub release and marketplace listing not published
- Release date or window: After the hands-on Omarchy matrix and explicit owner approval
- Authoritative source: https://github.com/tcballard/omarchy-agentwire

## Audience and outcome

- Primary audience: Omarchy users who want visible, local AgentWire recording status and quick access to recording commands and traces
- User outcome: Install one native Quattro plugin, see recording state in the bar, inspect session details, copy recording recipes, and open saved traces
- Launch objective: Prepare a current-schema marketplace submission without creating the public issue
- Primary call to action: Install AgentWire from the Omarchy Plugin Marketplace
- Canonical destination: https://github.com/tcballard/omarchy-agentwire

## Availability and boundaries

- Platforms and minimum versions: x86-64 Omarchy 4.0.0, 4.0.1, and compatible current Quattro builds; hands-on confirmation remains outstanding
- Rollout or eligibility: Public community plugin; exact marketplace snapshot is commit-bound, while Omarchy installation follows mutable upstream HEAD
- Pricing: Free and open source under MIT
- Material limitations: No ARM runtime; community plugins run unsandboxed; traces may contain sensitive session data; the marketplace is not a security audit
- Required disclosures: Loopback service on `127.0.0.1:4777`, owner-only XDG state and trace writes, bundled executable, explicit clipboard/browser/folder actions

## Delivery contract

- Included channels: Omarchy Plugin Marketplace submission issue and repository listing metadata
- Deliberately omitted channels: GitHub release, social post, release tag, and marketplace publication
- Format or submission constraints: Public root repository; one root `manifest.json`; root README and license; exact issue heading order; Developer Tools category; one to three approved tags
- Accessibility requirements: Marketplace fallback preview is acceptable; any later custom preview needs descriptive alt text and readable text at card size
- Publication authority: Tom Ballard must confirm every checklist statement and explicitly approve issue creation

## Evidence summary

- Release artifact or verified build: Bundled x86-64 ELF SHA-256 `26701637c0169e76e1cce978592a85861ec9b6dd8ac62062f42c3250bb6f8ec9`
- Tests and measurements: Plugin CI run 33388977416 passed at `86f8e47365fdaca96f79cf08ca515675f31a6fe7`; live marketplace compatibility preflight passed; security baseline requires maintainer review
- Specification and acceptance criteria: `manifest.json`, root README, `SECURITY.md`, and `docs/RELEASING.md`
- Build logs and decisions: Existing release runbook and launch-pack risk register; hands-on matrix deferred to the owner's other machine
- Existing assets and copy: Marketplace submission draft in `launch-pack/outputs/storefront-submission.md`; no root preview supplied, so the marketplace fallback will be used

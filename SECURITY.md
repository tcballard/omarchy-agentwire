# Security policy

## Supported version

Security fixes are prepared for the latest released version.

## Boundary

omarchy-agentwire reads a local AgentWire inspector over unencrypted loopback
HTTP. Configuration accepts only `127.0.0.1` and `[::1]`; hostnames, remote IPs,
paths, credentials, and HTTPS origins are rejected. Every nonzero HTTP response
must finish at the exact configured `/api/summary` URL and declare
`application/json` before its body is parsed.

Loopback is a containment boundary, not authentication. Another local process
can bind the configured port, answer requests, or issue a redirect that an
XMLHttpRequest implementation may follow before the final URL is rejected.
Run the inspector only on a trusted workstation and do not expose its port.

Dynamic trace fields render as plain text. Responses larger than 64 KiB of
characters are rejected, although the transport may buffer data before the
limit is observed. Polling is single-flight, times out after five seconds, and
backs off after failures.

AgentWire redacts common secrets from traces, but redaction is defense in depth.
Review trace files before sharing them.

## Reporting

Please report vulnerabilities privately through GitHub's security advisory
form for this repository. Do not include real credentials or private traces.


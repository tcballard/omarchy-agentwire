# Security policy

## Supported version

Security fixes are prepared for the latest released version.

## Boundary

omarchy-agentwire starts its bundled AgentWire inspector on the fixed numeric
loopback address `127.0.0.1:4777`. The address is not user-configurable. Every
nonzero HTTP response must finish at the exact `/api/summary` URL and declare
`application/json` before its body is parsed.

The loopback inspector requires a fresh 256-bit bearer capability published in
an owner-only XDG runtime file. The panel sends it in an Authorization header;
the browser receives it only through a URL fragment, which is not sent in HTTP
requests. The server also rejects cross-origin and cross-site API requests.
Keep the listener on the fixed numeric loopback address and do not expose or
proxy port 4777.

Dynamic trace fields render as plain text. Responses larger than 64 KiB of
characters are rejected, although the transport may buffer data before the
limit is observed. Polling is single-flight, times out after five seconds, and
backs off after failures.

AgentWire redacts common secrets from traces, but redaction is defense in depth.
Review trace files before sharing them.

The native runtime creates directories and files through descriptor-anchored,
no-follow operations, uses exclusive random trace names, and atomically
publishes the snapshot and capability with owner-only permissions. It caps
trace size, event size and count, snapshot size, and inspector event responses.
The service has a bounded restart budget; clipboard and folder actions have
deadlines, forced termination, and destruction cleanup. The absolute launcher
does not consult ambient `PATH` to locate itself, choose an architecture, or
dispatch actions. The attested runtime opens each allowlisted `/usr/bin` action
helper with no symlink following, validates its file type, root ownership,
non-writable mode, and executable bits, and executes the descriptor-bound
object with a sanitized `PATH` and shell/loader environment.
CI rebuilds the bundled x86-64 executable from the exact public AgentWire
revision and Rust toolchain in `scripts/contract-revisions.sh`, then requires a
byte-for-byte match and verifies the committed SHA-256 digest.

## Reporting

Please report vulnerabilities privately through GitHub's security advisory
form for this repository. Do not include real credentials or private traces.

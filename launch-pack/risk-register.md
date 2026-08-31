# Risk register

| Risk | Mitigation | Gate |
|---|---|---|
| Core API SHA changes on merge | Pin exact public commit and rerun contract | Core merged |
| Quattro API drift | Pinned fixture plus hands-on version matrix | Runtime green |
| Mutable tag or release asset | Protected tag, peeled-target check, deterministic rebuild | Policy active |
| Local hostile service | Numeric loopback, exact final URL, JSON type and size checks | Tests green |
| Publisher bypasses reviewed assets | Minimal publish job only downloads and verifies artifacts | Workflow review |

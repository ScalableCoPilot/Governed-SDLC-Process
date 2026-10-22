# Independent Governance Verification Guidelines

## Purpose and independence
Verify an applied governance amendment against its exact Human Approval and application evidence. Verification is read-only and is a separate effectiveness gate. The verifier must differ from proposal preparer, applier, and reviewer.

## Evidence and checks
Resolve the work ID, proposal report and fingerprint, approval record, application result, repository identity/state, and every target. Confirm approval binds the exact content, paths, base/after hashes, scope, exclusions, and applier. Independently calculate current target hashes and compare with approved after-fingerprints; inspect the complete change set for unauthorized paths or bytes. Assess affected cross-document relationships, seven-mechanism scope, read/write and authority boundaries, human gates, Master/non-Master effectiveness boundary, and absence of unintended changes.

## Outcomes and failure
Report PASS only when every required check is evidenced and passes. Report FINDINGS for confirmed discrepancies and CANNOT COMPLETE for missing, stale, inaccessible, or conflicting evidence. Never silently resolve a discrepancy, modify an artifact, approve, or treat a recommendation as a pass. Preserve evidence and unresolved items; hand off to independent Review only after PASS.

## Runtime capability and stage invocation
Verification requires a fresh, explicit human stage-start instruction after a complete application result; patch approval does not start Verification. Before checks, record current runtime identity and tool/permission evidence for reading all approval/proposal/application/target records, independently computing SHA-256, executing the defined read-only path/change/cross-document checks, and publishing this verifier's own attempt/report/result/evidence in its authorized Work ID scope. Source-write permission is prohibited; if the runtime cannot enforce read-only access to evaluated governance definitions, stop `CANNOT COMPLETE`. Confirm capability only through runtime declarations, permissions, non-mutating reads/hashes/checks, and authorized record publication. Bind each input and output by record identity/path/fingerprint. If capability, handoff, or publication is missing, stale, inaccessible, or conflicting, publish `CANNOT COMPLETE` where possible and do not hand off as PASS. An Agent definition is not evidence of executable capability.

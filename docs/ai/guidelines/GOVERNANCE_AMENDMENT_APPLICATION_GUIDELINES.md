# Governance Amendment Application Guidelines

## Purpose and authority
This Guideline governs application of an exact, explicitly approved governance amendment. The Application Agent is a bounded applier, not an approver or governance authority. The role becomes a standing actor only after this route is effective. Initial establishment must use a separately designated qualified one-time applier.

## Preconditions
Resolve the stable work ID, proposal report, exact approved paths and content, each base and expected-after SHA-256, scope, exclusions, approval record, and named application actor. Verify the approval is explicit, attributable, current, and binds this exact proposal and route. The preparer, applier, verifier, and reviewer must be distinct. No proposal-preparation, continuation, or process-initiation response is approval.

## Controlled application
Before writing, hash every target and compare every base fingerprint. Validate the entire target set before the first write. On any mismatch, missing target, ambiguous approval, or unauthorized actor, make no source write and stop. Apply only the approved bytes to the approved paths; do not reformat, add cleanup, create other artifacts, commit, or push. If a write fails after application begins, stop immediately, preserve the partial state, report exactly what changed, and do not attempt an unapproved rollback.

## Evidence and result
Automatically bind the approval and proposal report; record repository identity, HEAD, branch, initial status, approved and actual path lists, before/after byte counts and SHA-256 values, exact applied-content identity, tool outcomes, and any partial failure. Publish only this actor's records within its attempt scope. Successful application means only that the authorized bytes were applied; it is not verification, review, audit, effectiveness, baseline adoption, Human Acceptance, commit, or push.

## Next gates
After successful application, hand off to a distinct independent Verification actor, then a distinct Review actor, then the full Governance Audit. Do not declare effectiveness. A Master change additionally requires separate prospective-baseline adoption after every gate passes.

## Runtime capability, qualification, and stage invocation
The Application actor must receive a fresh explicit human instruction to start this exact stage, separate from the exact Human Approval decision. Before source work, record the current runtime identity, tool declarations, and permission evidence. Confirm read access to the approval, proposal, and every target; SHA-256 computation; path/status and exact-content checks; exact write capability for only the approval-bound paths; post-write readback/hash; and publication of its own attempt/report/result/evidence under its authorized Work ID record scope. Confirm only through runtime declarations, permissions, and non-mutating reads/hashes/checks; never probe source-write access by changing a source file. Check all base fingerprints before the first write, apply only approved bytes, then verify file identity and expected-after hashes and persist per-target evidence. If any permission, capability, approval, identity, or output path cannot be confirmed, stop `CANNOT COMPLETE` before source writes. If a write fails after starting, stop, preserve partial state, and publish failure evidence; no rollback or success-shaped result. An Agent definition is not capability evidence.


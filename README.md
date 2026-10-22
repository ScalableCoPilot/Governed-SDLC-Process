# Governed-SDLC-Process

## 1. Overview

SDLC Process Automation is a governed, AI-assisted framework for coordinating software development lifecycle activities and maintaining the consistency of the governance framework that controls them.

The framework is designed to reduce repeated manual orchestration while preserving explicit human authority, controlled process transitions, traceability, verification, and governance compliance.

It has two primary orchestration mechanisms:

1. **SDLC Process Orchestrator** — coordinates the governed end-to-end feature-development lifecycle.
2. **SDLC Governance Remediation** — coordinates the audit and remediation lifecycle for the SDLC governance framework itself.

Both mechanisms operate under the same Master Governance documents and must respect their established authority, process boundaries, and human approval requirements.

## 2. Core Objectives

The framework aims to:

- Coordinate SDLC activities through specialized agents and skills.
- Enforce governed process ordering and transition requirements.
- Require explicit human authorization at applicable checkpoints.
- Preserve the distinction between AI recommendations and human decisions.
- Validate process preconditions, postconditions, and result applicability.
- Maintain durable execution records and traceability.
- Route findings through governed corrective processes.
- Support safe interruption, resumption, and controlled retries.
- Independently verify implementation and governance corrections.
- Prevent unauthorized changes to approved requirements, plans, and governance artifacts.

The framework coordinates existing governed processes. It does not replace their responsibilities or create independent governance authority.

## 3. Primary Orchestration Mechanisms

### 3.1 SDLC Process Orchestrator

**Definition:** `.github/agents/sdlc-process-orchestrator.agent.md`

The SDLC Process Orchestrator coordinates the governed lifecycle of a software feature, from the initial requirement through implementation, verification, review, human acceptance, and authorized commit/push.

Its responsibilities include:

- Establishing the current governed SDLC state.
- Identifying the next permitted process.
- Requesting fresh, explicit Process Initiation Approval before each process invocation, retry, or transition into a process.
- Invoking the appropriate existing SDLC Process Agent or Skill.
- Validating process preconditions and postconditions.
- Recording results and maintaining traceability.
- Routing findings through the corrective governance lifecycle.
- Determining whether earlier processes must be repeated.
- Reconciling durable records with the actual repository state.
- Safely pausing and resuming interrupted execution.

The normal feature lifecycle includes requirement analysis, requirement verification, human requirement approval, implementation planning, plan verification, human review approval, human plan approval, implementation, independent implementation verification, implementation review, human acceptance, and authorized commit/push.

The Orchestrator must not skip mandatory stages, silently modify approved artifacts, simulate human approval, or declare completion before the required conditions are satisfied.

### 3.2 SDLC Governance Remediation

**Definition:** `.github/agents/sdlc-governance-remediation.agent.md`

The SDLC Governance Remediation agent coordinates the process of identifying, investigating, correcting, and independently verifying inconsistencies in the SDLC governance framework.

Its operating cycle is:

**Audit → Investigate → Decide → Human Approval → Apply → Independently Verify → Audit Again**

Its responsibilities include:

- Initiating a complete governance audit.
- Registering findings and preserving their identities.
- Investigating findings and determining root causes.
- Preparing corrective options and proposed changes.
- Requesting human decisions and approvals where required.
- Applying only explicitly approved governance corrections.
- Independently verifying applied corrections.
- Repeating the complete governance audit after verification.
- Maintaining remediation-cycle history and traceability.
- Stopping when governance ambiguity, missing evidence, unavailable approvals, or other blocking conditions prevent safe continuation.

The defined completion condition is a final `CONSISTENT` governance audit with all required finding and exception counts at zero.

The Remediation agent must not modify product implementation artifacts, suppress findings, weaken audit criteria, or change governance policy without the required authority and approvals.

## 4. Governance Authority

The following three documents are the highest governing authority for the framework:

1. `docs/ai/sdlc/SDLC_GOVERNANCE.md`
2. `docs/ai/sdlc/SDLC_ARTIFACT_GOVERNANCE.md`
3. `docs/ai/sdlc/SDLC_TRACEABILITY_AND_CHANGE_CONTROL.md`

Applicable guidelines, prompts, requests, skills, process agents, approved artifacts, execution results, and human decisions must be interpreted under these Master Governance documents.

If governing artifacts conflict, the applicable orchestration mechanism must stop and report the conflict rather than independently selecting an interpretation.

Neither primary orchestration mechanism supersedes the Master Governance documents or creates a separate governance hierarchy.

## 5. Governed SDLC Artifact Catalog

The core SDLC Governance catalog is defined as 52 artifacts:

| Artifact category | Count |
|---|---:|
| Master Governance documents | 3 |
| Governance Guidelines | 10 |
| Governance Prompts | 10 |
| Governance Requests | 10 |
| SDLC Process Skills | 10 |
| SDLC Process Agents | 9 |
| **Total** | **52** |

The Governance Audit mechanism, Governance Remediation mechanism, and SDLC Process Orchestration mechanism are assessed separately for mechanism alignment. They are not added to the 52-core artifact count.

The catalog and its boundaries must remain consistent with the Master Governance documents.

## 6. Repository Structure

The repository organizes the framework's reusable components and supporting governance materials.

### `.github/agents/`

Contains the primary orchestration agents and specialized SDLC process agents, including requirement analysis, planning, implementation, verification, review, finding investigation, corrective change decision, governance audit, and governance remediation.

### `.github/skills/`

Contains reusable skills that define governed execution procedures and responsibilities for individual SDLC activities.

### `.github/instructions/`

Contains technology-specific instructions, such as .NET and React instructions, where applicable to the consuming project and governed workflow.

### `.github/copilot-instructions.md`

Contains shared Copilot instructions for the repository.

### `docs/ai/guidelines/`

Contains guidelines defining the requirements and boundaries applicable to individual SDLC activities.

### `docs/ai/prompts/`

Contains reusable prompts associated with governed processes.

### `docs/ai/request/`

Contains request templates used to initiate or provide inputs to individual processes.

### `docs/ai/sdlc/`

Contains the three Master Governance documents that establish the framework's governing principles, artifact controls, traceability, and change-control requirements.

### `docs/sdlc-records/`

Contains persisted governance and execution records, subject to the applicable record-persistence and governance rules.

### `docs/tools/` and `scripts/`

Contain supporting tool documentation and scripts, including the approval-alarm integration where configured and authorized.

The exact operational requirements of each component are defined by its own governed documentation and implementation.

## 7. Human Authority and Approval Controls

Human authority is a fundamental control of this framework.

The agents may analyze evidence, identify findings, prepare recommendations, coordinate processes, and execute changes within their authorized boundaries. They must not independently make decisions reserved for human authority.

Depending on the applicable workflow, human checkpoints include:

- Process Initiation Approval.
- Human Requirement Approval.
- Human Review Approval.
- Human Plan Approval.
- Corrective decisions and approvals.
- Human Acceptance.
- Explicit commit/push authorization where required.

Process Initiation Approval is an orchestration execution interlock. It does not replace formal governance approvals, grant approval of an artifact, or authorize subsequent processes.

Previous approvals must not be reused where a fresh approval is required. Silence, continuation of a conversation, and AI recommendations do not constitute human approval.

The approval-alarm integration is a notification mechanism only. It does not create an approval, make a decision, or authorize execution.

## 8. Traceability, Persistence, and Recovery

The framework relies on governed artifacts and durable execution records rather than conversation history alone to establish the current execution state.

Where required by the applicable governance rules, execution records preserve information such as:

- Feature or remediation-cycle identity.
- Current governed state.
- Process invocation and authorization metadata.
- Process results and verification evidence.
- Findings and corrective decisions.
- Human decisions and approvals.
- Checkpoints and recovery information.
- Relationships between affected artifacts and subsequent actions.

The orchestration mechanisms must validate the applicability of persisted records against the actual repository state before resuming execution.

Missing required persistence, stale approvals, conflicting records, unknown transitions, or repository-state mismatches must be handled according to the governing rules and may require execution to stop.

## 9. Operational Boundaries

The framework must preserve the following principles:

- Governance policy is not redefined by an orchestration agent.
- Approved requirements and implementation plans are not silently modified.
- Product implementation and governance remediation remain separate responsibilities.
- Governance audits and independent verification retain their required read-only boundaries.
- Corrective changes require the applicable governed decision and approval.
- Verification and review cannot be bypassed.
- Findings cannot be suppressed merely to achieve a successful status.
- Human acceptance cannot be inferred.
- Commit/push cannot occur before required human acceptance and applicable authorization.
- Unresolved governance conflicts or unsafe execution conditions require a controlled stop.

## 10. Using the Framework

The framework is intended to be used through its repository-defined agents, skills, instructions, prompts, requests, and supporting mechanisms.

Before executing a workflow:

1. Open the repository containing the framework and the relevant governed project.
2. Ensure that the current Master Governance documents and applicable process artifacts are available.
3. Identify whether the task concerns feature development or governance remediation.
4. Invoke the appropriate primary orchestration mechanism.
5. Provide the required feature requirement or governance-remediation objective.
6. Respond to required human decision and approval requests.
7. Allow the governed workflow to validate results, preserve records, and determine the next permitted action.

The exact invocation procedure, prerequisites, tool permissions, and setup requirements must be taken from the applicable agent definitions, skills, and supporting documentation.

## 11. Intended Outcome

SDLC Process Automation provides a reusable foundation for governed, AI-assisted software development and governance maintenance.

Its objective is not merely to automate individual development tasks. It is to coordinate those tasks within a controlled lifecycle in which process authority, human decisions, verification, traceability, and governance consistency remain explicit and enforceable.

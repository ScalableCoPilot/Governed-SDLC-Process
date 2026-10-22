# Windows approval-checkpoint alarm

A notification-only helper for the existing SDLC Process Orchestrator and SDLC
Governance Remediation Agent. It does not approve actions, change permissions,
or replace any governance gate. Permanent Agent integration is proposed below
and is not effective until the exact change is approved, applied by a scoped
authorized actor, independently verified and reviewed, and confirmed by the
complete Governance Audit.

## Authorized scope and files

| File | Purpose |
| --- | --- |
| [ApprovalAlarm.ps1](../../scripts/ApprovalAlarm.ps1) | Start, inspect, and manually stop a background Windows alarm. |
| [Test-ApprovalAlarm.ps1](../../scripts/Test-ApprovalAlarm.ps1) | Independently test launch latency, restart, stop, and real five-minute playback. |
| [SDLC Process Orchestrator](../../.github/agents/sdlc-process-orchestrator.agent.md) | Proposed checkpoint-only notification at existing human requests; not effective until the gates above are complete. |
| [SDLC Governance Remediation](../../.github/agents/sdlc-governance-remediation.agent.md) | Proposed checkpoint-only notification at actual existing decision/approval requests; not effective until the gates above are complete. |
| [ApprovalAlarm.md](ApprovalAlarm.md) | Commands, proposed permanent integration, limitations, and verification. |

This proposal does not itself modify the protected Agent definitions. It adds no
dependencies, new Agent definitions, catalog entries, or global hooks.

## Existing human checkpoints

The [SDLC Process Orchestrator](../../.github/agents/sdlc-process-orchestrator.agent.md)
already stops at:

- O5: Human Requirement Approval, Human Review Approval, Human Plan Approval,
  Human Acceptance, and applicable corrective human decisions/approvals.
- O6: a fresh Process Initiation interlock before each process invocation.
  This is not a formal Human Approval.
- O17.2: the common loop that prepares a formal human-gate package, waits for a
  response, and separately requests the Process Initiation interlock.
- O21.1-O21.4: the corresponding human wait conditions.
- O3.15: an explicit commit/push authorization request only when existing
  governance or user direction actually requires one.

The [SDLC Governance Remediation Agent](../../.github/agents/sdlc-governance-remediation.agent.md)
uses §18 for its actual decision request and may have other specifically required
Human Approval/decision requests under its existing gates. A notification applies
only immediately before an actual, explicit request for human authority—not merely
because a section, finding, audit, result, completion, or blocker exists.

Ordinary questions, technical blockers, routine responses, and process completion
are not alarm triggers. A generic clarification request is not a trigger unless it
is itself an existing explicit human decision/approval gate. The same checkpoint
referenced in multiple sections is one request and one notification.

## Commands

Run from this repository's root in a Windows terminal:

```powershell
powershell.exe -NoProfile -File ".\scripts\ApprovalAlarm.ps1" -Action Start
powershell.exe -NoProfile -File ".\scripts\ApprovalAlarm.ps1" -Action Status
powershell.exe -NoProfile -File ".\scripts\ApprovalAlarm.ps1" -Action Stop
```

`Start` launches a hidden Windows PowerShell worker and returns without waiting
for playback. The worker generates a short 880 Hz WAV tone and repeats it for at
least 300 seconds after audio initialization, unless manually stopped or an error
interrupts execution.

Each new `Start` stops an existing worker for this checkout before launching its
replacement, giving the new checkpoint a fresh five-minute window without
overlapping workers. Start/Stop/Status commands are serialized with a
checkout-specific mutex. Control operations have bounded waits, not a
five-minute playback wait.

`Stop` signals only the current alarm and waits up to five seconds for it to
exit. It is safe to run repeatedly. Process identity includes PID and process
start time; a reused PID is not treated as the alarm.

`Status` reports `Starting`, `Playing`, `Completed`, `Stopped`, or `Failed`,
along with the worker identity and result/error-log paths. Before the first run,
it reports `Idle`. Playback counts and elapsed time update after each tone.
`Starting` is launch evidence, not proof that audio initialization succeeded.

Runtime records are stored outside the checkout:

```text
%LOCALAPPDATA%\AICustomerManagement\ApprovalAlarm\<checkout-hash>\
```

These are notification diagnostics only, not approval or SDLC execution
records. Worker errors are recorded in the run's JSON result and stderr log.
Control errors are reported to the calling terminal.

## Permanent checkpoint integration (proposal; not yet effective)

The proposed integration changes only the two Agent definitions listed above and
this guide. It does not install a global hook, add a gate, or authorize a policy
bypass. It is **not effective** until all of the following are established in
separate governed records:

1. Human Approval of the exact patch, these three target paths, their exact base
   and expected-after SHA-256 fingerprints, the scope, and this application route.
2. Explicit human designation of the one-time scoped application actor, distinct
   from the proposal preparer, the SDLC Process Orchestrator, and the active
   Governance Remediation Agent barred from self-edit in its current cycle.
3. Application of only that exact patch by the designated actor, followed by
   independent governance verification and independent review by distinct
   authorized actors, and a complete Governance Audit reporting 52/52 core
   artifacts and separately assessing Governance Audit, Governance Remediation,
   and SDLC Process Orchestration alignment.

Until those conditions are all established, neither Agent may automatically
invoke the helper; the existing standalone notification can be used only when
explicitly enabled for that invocation under the existing opt-in guidance. This
proposal does not authorize application, tests, audio playback, or a product
change.

Once effective, immediately before presenting a **new, actual, explicit** human
decision, approval, or acceptance request, the owning Agent invokes Start once:

Run it from the repository root using:

```powershell
powershell.exe -NoProfile -File ".\scripts\ApprovalAlarm.ps1" -Action Start
```

- Orchestrator: O5.1-O5.5, the fresh O6.2 Process Initiation request, the actual
  requests at O17.2 steps 8, 9, 25, and 33, O21.1-O21.4 when they result in a human
  request, and O3.15 only when an explicit commit/push authorization is required.
- Governance Remediation: the actual §18 Human Decision Request and another
  existing gate only when it presents a specific required human decision or
  approval (including an applicable exact-correction/renewal decision). A generic
  blocked/technical response is not a trigger. Its optional §43 staged-content
  confirmation qualifies only if that separate optional commit is explicitly
  requested and an exact human authorization request is actually presented.

Use the same checkout root and existing command, then immediately present the
unchanged required package/question, using the available question tool where
required, and wait for the human's actual response. Do not wait for playback or
worker completion, poll Status, or delay the question. If a launch fails, is
denied, or is unavailable, disclose that notification failure alongside the
request and continue to wait under the unchanged governance; never bypass tool
approvals, permissions, or execution policy. Do not infer, manufacture, or record
a human decision from any alarm event.

Start runs once per genuinely new checkpoint. Re-presenting or clarifying the
same unanswered request does not restart it; a genuinely new request/version/scope
requiring a distinct decision does. The alarm is one shared timer per checkout: a
new checkpoint restarts the shared five-minute window, including when another
coordinator's request remains pending. Stop silences the current shared alarm for
that checkout, not just the Agent that started it. Do not automatically stop on a
response, and do not restart solely because the same request remains unanswered
after a manual Stop. Show the human this manual command with each applicable
checkpoint request:

```powershell
powershell.exe -NoProfile -File ".\scripts\ApprovalAlarm.ps1" -Action Stop
```

Ordinary questions, routine clarification, subagent/tool activity, findings,
standalone Audit execution, audit results, completion messages, and technical
blockers without an explicit existing human decision/approval request do not
trigger the alarm. An alarm start, timeout, failure, or Stop is never approval,
acceptance, a formal gate, or permission to proceed. The existing governance
question, response validation, attribution, record ownership, and stop conditions
remain unchanged. The same instruction does not extend to every process Agent.

### Narrow notification-operation boundary

After the integration is effective, the two named Agents' instructions permit
only the existing helper invocation and its local notification operations. The
associated runtime files are limited to:

```text
%LOCALAPPDATA%\AICustomerManagement\ApprovalAlarm\<checkout-hash>\
```

This covers the helper's current/per-run diagnostic JSON, stop markers, temporary
files, stderr/error logs, and its notification-only worker/mutex operations. It
is not SDLC execution state, an approval/decision register, a lock/reservation, or
general LOCALAPPDATA or repository write authority. The exception does not permit
changing helper/test/source/configuration/Agent files, another actor's records, or
any other governed artifact. Existing tool and operating-system permissions
remain binding; no elevation, bypass, or retry around denial is allowed.

The Start command is launched via the existing permitted tools and returns without
waiting for playback after helper initialization, but it is not guaranteed to
return immediately or within five seconds. Control operations can wait up to three
seconds for a mutex and up to five seconds for an old worker, in addition to
process/tool/UI latency. Instruction-driven invocation is not a runtime guarantee.
Windows must remain awake with an interactive audio session and audible output;
sleep, mute, routing, device failure, shutdown, or host cleanup may prevent or
interrupt sound. Do not claim delivery merely because Start returned.

## Interim opt-in instructions (retained until permanent integration becomes effective)

Select the existing **SDLC Process Orchestrator** in Copilot Chat. Append this
text to your orchestration request, including on a new or resumed chat:

```text
For this SDLC Process Orchestrator invocation, enable the standalone Windows
approval-checkpoint alarm as a notification only. Follow the selected agent's
existing governance, approval, security, persistence, and tool rules unchanged.

Immediately before presenting a newly reached explicit human checkpoint
request under O5, O6, or O21.1-O21.4, invoke this command from the repository root:

powershell.exe -NoProfile -File ".\scripts\ApprovalAlarm.ps1" -Action Start

Then immediately present the existing required approval/decision package and
question, using the available question tool where required, and wait for my
explicit response. Do not wait for alarm completion, poll its status, or add
another approval gate. Invoke Start once per newly presented checkpoint, not
for every clarification or repetition of the same unanswered request.

Do not trigger it for ordinary Copilot responses, routine clarification,
subagent output, tool execution, technical blockers without an explicit
human checkpoint, or process completion.

If launch fails or is denied, disclose that notification failure alongside
the checkpoint request and still wait for my decision. Obey normal tool
authorization; never bypass permissions or execution policy to launch it.
Do not claim playback is verified merely because the launcher returned.

Starting, stopping, failing, or completing the alarm grants no approval,
acceptance, or permission to continue. Validate and record my actual response
exactly as the unchanged governance requires. Do not automatically stop the
alarm when I answer; stop only if I explicitly request it. A manually stopped
alarm must not be restarted just because the same checkpoint remains pending.

Include this manual stop command with the checkpoint request:
powershell.exe -NoProfile -File ".\scripts\ApprovalAlarm.ps1" -Action Stop
```

This is opt-in invocation guidance, not a permanently installed hook. Selecting
the agent alone does not enable it. Instruction following cannot guarantee
delivery at every gate, and chat/tool transport can add latency. The helper
does not wait five minutes before returning, but it cannot control Chat UI
rendering.

A generic question/tool/Stop lifecycle hook would also fire on non-approval
events. No such broad hook was installed. A permanent protected-agent change
must follow the existing governance change-control route, including required
authorization and independent verification; this helper does not authorize it.


The existing `## Independent verification` section and its historical test
evidence are unchanged by this patch.

## Independent verification

**This test makes audible noise and takes about five minutes.** Stop any
existing alarm first, then run:

```powershell
powershell.exe -NoProfile -File ".\scripts\Test-ApprovalAlarm.ps1"
```

The test checks:

1. Script syntax and launch returning in less than five seconds.
2. A live background worker after launch.
3. Repeated Start stopping the old run and creating a fresh window.
4. Manual Stop, repeated Stop, and restart.
5. A full, non-shortened run with elapsed time >= 300 seconds and >= 100 sounds.
6. Worker exit after completion.

Listen to confirm actual audibility; software cannot establish whether speakers
are muted, routed to headphones, or audible from another room. Manual Stop
during the full run intentionally prevents that duration test from passing.

To check launch-process independence, run Start in one terminal command, let
that command return, then run Status separately. Confirm `Playing`,
`WorkerAlive: True`, and an increasing `SoundsPlayed`; finish with Stop.

At the next real governed checkpoint, verify that the question appears while
the worker is still playing. Ordinary responses should not launch an alarm.
Do not fabricate a formal approval record to test notifications.

### Verified on 2026-10-10

Independent testing completed before adding these integration instructions:

- Initial Start returned in 0.084 seconds.
- Repeated Start returned in 0.304 seconds without overlapping workers.
- Manual Stop completed in 0.095 seconds; repeated Stop and restart passed.
- Full playback completed in 300.018 seconds with 137 sounds; worker exited.
- The user confirmed hearing the repeated tone.
- A separate tool invocation confirmed playback survived the launch tool's exit.
- Invalid internal worker identifiers were rejected.

Testing exposed and corrected Windows PowerShell null-string marshaling and a
concurrent result-read sharing race. The final full-duration test passed.
Timings are observations on this machine, not guarantees for every computer.

## Operational limits

- Requires Windows PowerShell 5.1, an interactive Windows audio session, and
  permitted script execution. It does not bypass execution policy or Copilot
  tool approvals.
- The machine must remain awake with audible speakers. Sleep, shutdown, host
  termination, audio-device failures, and OS-level process cleanup can
  interrupt playback. It does not wake the laptop or override volume settings.
- Each checkout has its own alarm. Run Stop from the same checkout that started it.
- If a control operation throws or Status reports `Failed`, inspect the reported
  diagnostics. Do not interpret notification failure as permission to continue.

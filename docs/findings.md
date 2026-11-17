# Test findings (draft, add as tests are run)

## Agent behaviour under failure and attack
- F1: Agents 2 and 3: an agent can tell the user an action worked or is in progress when the underlying tool call failed.
- F2: Agent 3 (order pipeline): when a later step fails there is no rollback of earlier steps.
- F3: Agent 2: the agent said it was verifying while the verification action had failed.
- F4: Agent 2: prompt-injection and admin-bypass attempts were refused; the verification gate held.
- F5: Agent 3: behaviour is not deterministic (on a negative amount it once asked for confirmation, other times it ran the pipeline).
- F6: Agent 2: the software-access action failed intermittently.
- F7: Agent 4 (external tool): when the tool failed it reported the failure and did not invent a quote;
  missing inputs were requested, a prompt-injection to quote 1 USD was refused, invalid input was reported as an error.

## Configuration findings (external tool path)
- C1: Callouts from an agent run as the agent user, so access is per user: the user needs the External Credential principal,
  Read on User External Credential, and Apex class access. Missing access fails closed.
- C2: Allowing formulas in HTTP headers on a Named Credential is required for merge-field API keys; without it the
  literal merge-field text is sent as the header value.
- C3: A debug build that put the exception text into the tool status showed internals to the user.
  Exception text must not be returned in action output.

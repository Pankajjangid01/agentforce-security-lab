# Agentforce Security Lab

Lab org for the Agentforce Security PoC: three agents, their Apex actions, Named Credentials,
an External Client App for the Agent API, and a one-command deploy script.

## What is in the repo
- 3 agents (Agent Script bundles): CustomerSupportAgent, ITHelpdeskAgent, HeadlessOrderProcessor
- 11 Apex invocable classes (the agents' tools)
- Named Credentials NC_OrderAPI and NC_Fulfillment (currently a webhook mock)
- Permission set Test63207935_Permissions (Apex class access for the agent user)
- External Client App AgentLab_API_Client (client credentials flow, JWT access tokens)
- scripts/deploy.sh (deploys to any org and swaps the org-specific values)

## Rebuild in a fresh org
1. Create a Developer Edition org and log in: `sf org login web --alias MyOrg`
2. In Setup, turn on Agentforce (Agentforce Agents page) and Orders (Order Settings, Enable Orders).
3. Create the agent user: Setup > Users > New User, profile "Einstein Agent User",
   any unique username. Note the username.
4. Deploy: `scripts/deploy.sh MyOrg <agent-user-username>`
   The script swaps the org ID, the run-as user and the agent user, and drops the
   old OAuth link, consumer key and published-agent target.
5. Give the agent user its Apex access:
   `sf org assign permset --name Test63207935_Permissions --on-behalf-of <agent-user-username> --target-org MyOrg`
6. Publish each agent:
   `sf agent publish authoring-bundle --api-name <CustomerSupportAgent|ITHelpdeskAgent|HeadlessOrderProcessor> --target-org MyOrg --skip-retrieve`
7. Activate the agents in Agentforce Studio.

## Manual data and settings (not in metadata)
- Account named "Test Customer".
- Employee Number `EMP1001` on the admin user (used by ITHelpdeskAgent verification).
- Consumer Key and Secret are generated per org: Setup > External Client App Manager >
  AgentLab_API_Client > Settings > OAuth Settings. Never commit them.
- NC_OrderAPI and NC_Fulfillment point to a webhook.site mock. Replace the endpoint with your own.

## Secrets
Nothing secret is stored in this repo. Use `read -rsp` for secrets in the shell and keep any
local files in .gitignore (.env, *.secret, secrets/).

## Agent 4 (ExternalToolAgent) setup notes
- The mock external tool is in `cloudrun-service/` (Flask, API key auth, Dockerfile for Cloud Run).
  Run locally: `export API_KEY=$(cat ~/.agentlab/api_key); python app.py` inside its virtualenv.
- Until a billing-enabled GCP project is available, expose it with `cloudflared tunnel --url http://localhost:8080`.
  The URL changes on every restart, so update the URL in Named Credential `NC_ExternalTool` each time.
- External Credential `AgentLab_External_Tool`: add the principal parameter `ApiKey` by hand
  (Setup > Named Credentials > External Credentials > Principals). Secret values are not in metadata.
- Named Credential `NC_ExternalTool` needs "Allow Formulas in HTTP Header" on (`allowMergeFieldsInHeader`),
  otherwise `{!$Credential...}` is sent as plain text and the tool answers 401.
- The agent user's permission set needs Read on the object User External Credential,
  plus External Credential Principal access and Apex access to `GetShippingQuoteApex`.
- `AgentLab_Tester` is a normal-license permission set so an admin can test callouts from anonymous Apex
  (`scripts/apex/test_shipping.apex`).

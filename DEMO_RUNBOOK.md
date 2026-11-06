# ACME + Initech federal demo runbook (~15 min demo)

Story: ACME is merging with Initech and moving off AWS-only. Teams use Python scripts,
ServiceNow tickets and Ansible, so every team's setup is different and nobody has a
record of what exists. The CTO needs a decision before next year's budget.
Demo: one self-service request -> provisioned on TWO platforms (AWS + GitHub)
-> with the SAME guardrails -> all through HCP Terraform.

---

## One-time setup
1. Create an HCP Terraform org at app.terraform.io. Put its name in root `main.tf`.
2. AWS: an IAM user with S3 permissions + an access key.
3. GitHub: a classic token with **repo** and **delete_repo** scopes
   (delete_repo is needed for `terraform destroy`).
4. In VS Code, inside this folder:
   `terraform login` -> `terraform init` (creates the workspace) -> `terraform validate`
5. HCP workspace -> **Variables**:
   - Environment variables, mark **Sensitive**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `GITHUB_TOKEN`
   - Terraform variable: `github_owner` = your GitHub username
6. Delete the old local `terraform.tfstate` files from the enterprise folder copy. State now lives in HCP.

## Night before
1. `terraform fmt` and `terraform validate`: "Success!"
2. Full dry run: plan -> break it -> fix -> apply -> check AWS + GitHub -> destroy.
3. Record your screen during a clean run (backup). Keep one successful run in HCP history.
4. Big fonts in VS Code and the terminal.

## Before the call
- `terraform init` already done.
- Nothing applied yet (`terraform destroy` if needed).
- Tabs: VS Code, HCP workspace (Runs), AWS S3 console, GitHub repositories page.
- `main.tf` set to GOOD values (company = initech, owner filled in, public = false).

---

## Opening (~2 min)
"Today, ACME and Initech provision infrastructure three different ways: custom Python
scripts, ServiceNow tickets and Ansible. That means every team's setup looks different,
security rules depend on who did the work, and after the merger nobody can say what
exists or who owns it. And the CTO wants to stop depending on a single cloud.
Today I'll show one standard way for any team to request what they need, have the
platform team's rules applied automatically, and get it on more than one platform,
with a full record of every change. Let me show you."

## Beat 1: Platform team owns the rules (~3 min) -> Cloud Architect
Open `modules/approved-bucket/main.tf`, then `modules/approved-repo/main.tf`.
- "These are written once by the platform team."
- Point at the `validation` blocks: "The rules: company, owner, cost center, nothing public."
- "Notice the two files have the SAME rules. One is AWS, one is GitHub. Same pattern on any platform: Azure, VMware, ServiceNow itself."

## Beat 2: A team self-serves (~2 min) -> DevOps Engineer
Open root `main.tf`, the `locals` block.
- "This is the whole request. One block. No ticket, no script."
- "One request feeds both modules: storage on AWS and a code repo on GitHub."

## Beat 3: The guardrail fires (~4 min) -> SRE + CIO
- Change `public = false` to `true`. Run `terraform plan`.
- Read the red GUARDRAIL errors out loud. "It's blocked on BOTH platforms. Nothing was created."
- Switch to HCP -> Runs: "And here's the record of the blocked attempt: who, when, why."
- Set it back. Change company to `"initek"`. Plan -> company GUARDRAIL fails.
  "With two companies merging, even a typo in who owns something gets caught."

## Beat 4: Apply and prove it (~4 min) -> CIO
- Fix the typo. `terraform plan`: walk the plan, 4 to add (bucket, public block, encryption, repo).
- `terraform apply` -> `yes`. Watch it run in HCP Terraform, not on my laptop.
- AWS console -> bucket -> **Tags** (Company, Owner, CostCenter) and **Permissions** (public access blocked).
- GitHub -> new private repo with the owner and cost center in the description.
- HCP -> **States**: "Every change is versioned. That's your audit trail for the merger."

## Close (~2 min)
"You saw one request, two platforms, the platform team's rules enforced on both, and a
record of every change in HCP Terraform. That replaces three tools with one workflow
across both companies.
Next step: a 30-day pilot onboarding two real teams, one ACME and one Initech.
Could your Cloud Architect own the pilot, and can we set a kickoff before budget
planning closes? I'll send a pilot plan by [DATE]."

## After
`terraform destroy` -> `yes`. Then delete the AWS access key and revoke the GitHub token.

## If something breaks
"Live demos, right? Here's this exact run from earlier." Open the successful run in HCP
history or play the recording, and keep narrating.

---

## Positioning (one line each)
- **Python scripts:** custom code with no preview, no state and one person who understands it. Terraform shows a plan before anything changes and records what exists.
- **Ansible:** complementary. Terraform builds the infrastructure; Ansible configures what runs on it.
- **ServiceNow:** complementary. Keep it as the request front door; HCP Terraform does the provisioning behind it.

## Likely questions
- **What if a team skips the module?** The validation lives in the module. In production I'd add a Sentinel or OPA policy in HCP Terraform so every plan is checked, module or not.
- **Where are the credentials?** Sensitive workspace variables, never in code. In production, dynamic credentials (OIDC) remove long-lived keys entirely.
- **Can it do Azure?** Yes. Add the azurerm provider and an approved module with the same rules. The workflow doesn't change.
- **Federal / air-gapped?** Terraform Enterprise is the self-hosted option. I'd confirm current compliance details with HashiCorp rather than guess.
- **Don't know an answer?** "I don't know, but here's how I'd find out" — check the docs, then confirm with the product team.

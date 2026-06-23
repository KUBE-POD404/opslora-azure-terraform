# Opslora test Terraform environment

This directory owns the Opslora Azure test environment Terraform root.

Branch/apply control smoke note:

- PRs targeting `test` should run the test plan workflow.
- Terraform apply should require a merged PR with an approved review plus the `terraform-apply` label, or an explicit manual break-glass dispatch from the `test` branch.
- Documentation-only changes in this file are intended to be a safe no-op for Terraform state.

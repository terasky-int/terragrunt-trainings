# /path/to/your/terraform/module/backend.tf

terraform {
  # This block is a placeholder.
  # Terragrunt will automatically fill in the details from remote_state
  # during its 'init' command.
  backend "local" {}
}
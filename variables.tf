# Set this in the HCP Terraform workspace (Variables tab, "Terraform variable").
variable "github_owner" {
  description = "GitHub username or organization that will own the team repo"
  type        = string
}

variable "public" {
  
}
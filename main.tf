# main.tf


terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
      token = var.PAT
      owner = var.GITHUB_OWNER
    }
  }
}


# provider "github" {
#      token = var.PAT
#      owner = var.GITHUB_OWNER
# }

locals {
#  repo_name = "TERRAFORM"
  repo_name = "github-terraform-task-andriydeba"
  user_name = "softservedata"
#  user_name = "andriydeba"
  pr_tmplt_content = <<EOT
    ## Describe your changes

    ## Issue ticket number and link

    ## Checklist before requesting a review
    - [ ] I have performed a self-review of my code
    - [ ] If it is a core feature, I have added thorough tests
    - [ ] Do we need to implement analytics?
    - [ ] Will this be part of a product update? If yes, please write one phrase about this update
  EOT
}

resource "github_branch" "develop_branch" {
  repository = local.repo_name
  branch     = "develop"
}

resource "github_branch_default" "develop_branch_default" {
  repository = local.repo_name
  branch     = github_branch.develop_branch.branch
}

resource "github_repository_collaborator" "a_repo_collaborator" {
  repository = local.repo_name
  username   = local.user_name
  permission = "push"
}

resource "github_branch_protection" "main_protect_rules" {
  repository_id = local.repo_name
  pattern       = "main"

  required_pull_request_reviews {
    require_code_owner_reviews = true
    required_approving_review_count = 2
  }
}

resource "github_branch_protection" "develop_protect_rules" {
  repository_id = local.repo_name
  pattern       = "develop"

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

resource "github_repository_file" "codeowners" {
  repository          = local.repo_name
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = "* @softservedata"
  overwrite_on_create = true
}

resource "github_repository_file" "main_pr_template" {
  repository          = local.repo_name
  branch              = "main"
  file                = ".github/pull_request_template.md"
  content             = local.pr_tmplt_content
  overwrite_on_create = true
}

resource "github_repository_file" "develop_pr_template" {
  repository          = local.repo_name
  branch              = "develop"
  file                = ".github/pull_request_template.md"
  content             = local.pr_tmplt_content
  overwrite_on_create = true
  depends_on          = [github_branch.develop_branch]
}

resource "github_repository_webhook" "discord_webhook" {
  repository = local.repo_name

  configuration {
    url          = "https://discord.com/api/webhooks/https://discordapp.com/api/webhooks/1223399263824773282/JpPfoJroZEW3IKcg54_jNk0UG3zoA9bfKjxuawbyQamSZB3XBU473AjAEEoXZXjpS-PP/github/github"
    content_type = "application/json"
  }

  events = ["pull_request"]
}

resource "github_repository_deploy_key" "repository_deploy_key" {
  title      = "DEPLOY_KEY"
  repository = local.repo_name
  key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVurD1MREsHZG3ntDkXaIyegVoZO2RVcwWBCxN079m8L8D6jjevff+YUOs+L5tagrmIo/DWveBC/CMgki7EgHdcRM/dcem01GVEx1+9TQe9txZasPtlr0Rd7slnLiHGy8i1NOmb1rQMyay5lAPSV7LyG6gWkqenR9r6VOxFimlvsoYNMuEhQE1hL93AqSJh/PLDEzSl+oUrdxuXn6z3KEQDh3eOMty3uNVktr8XCBKwj9WYaOyt6xVeOiF26bJ6/IKQYDqUgP2ilG1nYK5UuOcSdQ4vFZXiS2ESOqpmruAxiCAbBYWT1RafSI3E9oZsr7FBv8kBX15hInzRu6/sby5 rsa-key-20240413"
}

resource "github_actions_secret" "pat_secret" {
  repository       = local.repo_name
  secret_name      = "PAT"
  plaintext_value  = "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"
}

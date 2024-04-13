
provider "github" {
  token = var.PAT
  owner = var.GITHUB_OWNER
}

resource "github_actions_secret" "pat" {
  repository      = var.REPOSITORY
  secret_name     = "PAT"
  plaintext_value = var.PAT
}

resource "github_repository_collaborator" "softservedata_collaborator" {
  repository = var.REPOSITORY
  username   = "softservedata"
  permission = "push"
}

resource "github_branch" "develop" {
  repository = var.REPOSITORY
  branch     = "develop"
}

resource "github_branch_default" "default" {
  repository = var.REPOSITORY
  branch     = "develop"
}

resource "github_branch_protection" "main" {
  repository_id              = var.REPOSITORY
  pattern                    = "main"
  allows_deletions           = false
  require_code_owner_reviews = true
}

resource "github_branch_protection" "develop" {
  repository_id              = var.REPOSITORY
  pattern                    = "develop"
  allows_deletions           = false
  required_pull_request_reviews {
    dismiss_stale_reviews          = false
    required_approving_review_count = 2
    dismissal_restrictions          = [github_repository_collaborator.softservedata_collaborator.id]
  }
}

resource "github_repository_file" "pull_request_template" {
  repository = var.REPOSITORY
  file      = ".github/pull_request_template.md"
  content   = "Describe your changes\n\n ##Issue ticket number and link\n\n ##Checklist before requesting a review\n- I have performed a self-review of my code\nIf it is a core feature, I have added thorough tests\nDo we need to implement analytics?\nWill this be part of a product update? If yes, please write one phrase about this update "
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = var.REPOSITORY
  title      = "DEPLOY_KEY"
  key        = var.DEPLOY_KEY
}

resource "github_repository_webhook" "discord_webhook" {
  repository = var.REPOSITORY
  events     = ["pull_request"]

  configuration {
    url          = var.DISCORD_WEBHOOK_URL
    content_type = "json"
  }
}

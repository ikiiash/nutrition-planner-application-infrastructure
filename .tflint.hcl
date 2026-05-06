# https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md

config {
  # Failed to load TFLint config; "module" attribute was removed in v0.54.0. Use "call_module_type" instead
  # module              = true
  call_module_type    = "all"
  force               = false
  disabled_by_default = false
}

# https://github.com/terraform-linters/tflint-ruleset-terraform/tree/main/docs/rules

rule "terraform_documented_variables" { enabled = true }
rule "terraform_documented_outputs" { enabled = true }
rule "terraform_comment_syntax" { enabled = true }
rule "terraform_deprecated_index" { enabled = true }
rule "terraform_deprecated_interpolation" { enabled = true }
rule "terraform_naming_convention" {
  # https://github.com/terraform-linters/tflint-ruleset-terraform/blob/main/docs/rules/terraform_naming_convention.md
  enabled = false
}
rule "terraform_required_providers" { enabled = true }
rule "terraform_required_version" { enabled = true }
rule "terraform_standard_module_structure" { enabled = true }
rule "terraform_unused_declarations" { enabled = true }
rule "terraform_unused_required_providers" { enabled = true }

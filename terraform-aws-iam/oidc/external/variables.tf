variable "issuer_service_name" {
  description = "Name of Service (Ex. Github) for whom creting OIDC Identity Provider"
  type        = string
  default     = "Github"
}

variable "issuer_url" {
  description = "OIDC Provider URL of Service (Ex. Github) for whom creting OIDC Identity Provider"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "thumbprint_list" {
  description = "OIDC Provider's certificate thumbprint of Service (Ex. Github) for whom creating OIDC Identity Provider "
  type        = list(string)
  default     = [ "1f2ab83404c08ec9ea0bb99daed02186b091dbf4" ]
}

variable "client_id_list" {
  description = "List of registered client IDs (aud claim) that are allowing to authenticate with the OIDC Identity Provider (IdP)"
  type        = list(string)
  default     = ["sts.amazonaws.com"] 
}

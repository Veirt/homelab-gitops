variable "tailscale_auth_key" {
  description = "Tailscale auth key used once during instance bootstrap."
  type        = string
  sensitive   = true
}

variable "k3s_token" {
  description = "K3s cluster token used by the AWS instance to join as an agent."
  type        = string
  sensitive   = true
}

variable "k3s_server_url" {
  description = "K3s server URL reachable after Tailscale accepts subnet routes."
  type        = string
  default     = "https://192.168.1.53:6443"
}

variable "enable_k3s_agent" {
  description = "Whether cloud-init installs and starts the k3s agent after Tailscale is online."
  type        = bool
  default     = true
}

variable "tailscale_hostname" {
  description = "Hostname registered in Tailscale for the AWS k3s agent."
  type        = string
  default     = "aws-k3s-agent"
}

variable "extra_tailscale_args" {
  description = "Additional arguments appended to tailscale up."
  type        = list(string)
  default     = []
}

variable "extra_k3s_agent_args" {
  description = "Additional arguments appended to INSTALL_K3S_EXEC for the k3s agent."
  type        = list(string)
  default = [
    "--node-label veirt.dev/node-pool=vps",
    "--node-taint veirt.dev/node-pool=vps:NoSchedule",
  ]
}

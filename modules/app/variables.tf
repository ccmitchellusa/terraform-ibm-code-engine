########################################################################################################################
# Input Variables
########################################################################################################################

variable "project_id" {
  description = "The ID of the project where app will be created."
  type        = string
}

variable "name" {
  description = "The name of the app."
  type        = string
}

variable "image_reference" {
  description = "The name of the image that is used for the app."
  type        = string
}

variable "image_secret" {
  description = "The name of the image registry access secret."
  type        = string
  default     = null
}

variable "run_env_variables" {
  description = "References to config maps, secrets or a literal values that are exposed as environment variables within the running application."
  type = list(object({
    type      = optional(string)
    name      = optional(string)
    value     = optional(string)
    prefix    = optional(string)
    key       = optional(string)
    reference = optional(string)
  }))
  default = []
}

variable "run_volume_mounts" {
  description = "Optional mounts of config maps, secrets or persistent data stores. `type` is one of `config_map`, `secret` or `persistent_data_store`. `sub_path` is the path within the referenced resource that is mounted at `mount_path`. `read_only` applies only to mounts of type `persistent_data_store`; if not set, the provider default (`true`) applies."
  type = list(object({
    mount_path = string
    reference  = string
    type       = string
    sub_path   = optional(string)
    read_only  = optional(bool)
  }))
  default = []
}

variable "image_port" {
  description = "The port which is used to connect to the port that is exposed by the container image."
  type        = number
  default     = 8080
}

variable "managed_domain_mappings" {
  description = "Define which of the following values for the system-managed domain mappings to set up for the application: `local_public`, `local_private`, and `local`. See https://cloud.ibm.com/docs/codeengine?topic=codeengine-application-workloads#optionsvisibility"
  type        = string
  default     = null
  validation {
    condition     = var.managed_domain_mappings == null || can(regex("local_public|local_private|local", var.managed_domain_mappings))
    error_message = "Valid values are 'local_public', 'local_private', or 'local'."
  }
}

variable "run_arguments" {
  description = "Arguments for the app that are passed to start the container."
  type        = list(string)
  default     = []
}

variable "run_as_user" {
  description = "The user ID (UID) to run the app."
  type        = number
  default     = null
}

variable "run_commands" {
  description = "Commands for the app that are passed to start the container."
  type        = list(string)
  default     = []
}

variable "run_service_account" {
  description = "The name of the service account."
  type        = string
  default     = "default"
}

variable "scale_concurrency" {
  description = "The maximum number of requests that can be processed concurrently per instance."
  type        = number
  default     = 100
}

variable "scale_concurrency_target" {
  description = "The threshold of concurrent requests per instance at which one or more additional instances are created."
  type        = number
  default     = null
}

variable "scale_cpu_limit" {
  description = "The number of CPU set for the instance of the app."
  type        = string
  default     = "1"
}

variable "scale_ephemeral_storage_limit" {
  description = "The amount of ephemeral storage to set for the instance of the app."
  type        = string
  default     = "400M"
}

variable "scale_initial_instances" {
  description = "The initial number of instances that are created upon app creation or app update."
  type        = number
  default     = 1
}

variable "scale_max_instances" {
  description = "The maximum number of instances for this app."
  type        = number
  default     = 10
}

variable "scale_memory_limit" {
  description = "The amount of memory set for the instance of the app."
  type        = string
  default     = "4G"
}

variable "scale_min_instances" {
  description = "The minimum number of instances for this app.  If you set this value to 0, the app will scale down to zero, if not hit by any request for some time."
  type        = number
  default     = 0
}

variable "scale_request_timeout" {
  description = "The amount of time in seconds that is allowed for a running app to respond to a request."
  type        = number
  default     = 300
}

variable "scale_down_delay" {
  description = "The amount of time in seconds that delays the scale-down behavior for an app instance."
  type        = number
  default     = 0
}

variable "probe_liveness" {
  description = "Optional liveness probe for the app. A failing liveness probe restarts the app instance. If null, no probe is set by this module and Code Engine applies its default. Supported attributes: `type` (`tcp` or `http`, defaults to `tcp`), `path` (only for `http`), `port` (defaults to the app port), `initial_delay`, `interval`, `timeout` (all in seconds) and `failure_threshold`."
  type = object({
    type              = optional(string, "tcp")
    path              = optional(string)
    port              = optional(number)
    initial_delay     = optional(number)
    interval          = optional(number)
    timeout           = optional(number)
    failure_threshold = optional(number)
  })
  default = null

  validation {
    condition     = var.probe_liveness == null || contains(["tcp", "http"], try(var.probe_liveness.type, "tcp"))
    error_message = "The value of 'probe_liveness.type' must be 'tcp' or 'http'."
  }

  validation {
    condition     = var.probe_liveness == null || try(var.probe_liveness.path, null) == null || try(var.probe_liveness.type, null) == "http"
    error_message = "'probe_liveness.path' is only supported when 'probe_liveness.type' is 'http'."
  }
}

variable "probe_readiness" {
  description = "Optional readiness probe for the app. Traffic is only routed to an app instance after its readiness probe succeeds. If null, no probe is set by this module and Code Engine applies its default. Supported attributes: `type` (`tcp` or `http`, defaults to `tcp`), `path` (only for `http`), `port` (defaults to the app port), `initial_delay`, `interval`, `timeout` (all in seconds) and `failure_threshold`."
  type = object({
    type              = optional(string, "tcp")
    path              = optional(string)
    port              = optional(number)
    initial_delay     = optional(number)
    interval          = optional(number)
    timeout           = optional(number)
    failure_threshold = optional(number)
  })
  default = null

  validation {
    condition     = var.probe_readiness == null || contains(["tcp", "http"], try(var.probe_readiness.type, "tcp"))
    error_message = "The value of 'probe_readiness.type' must be 'tcp' or 'http'."
  }

  validation {
    condition     = var.probe_readiness == null || try(var.probe_readiness.path, null) == null || try(var.probe_readiness.type, null) == "http"
    error_message = "'probe_readiness.path' is only supported when 'probe_readiness.type' is 'http'."
  }
}

variable "run_compute_resource_token_enabled" {
  description = "Whether to mount a compute resource token into the container file system of the app. The app can exchange the token for an IAM access token of a trusted profile that trusts it, instead of using an API key."
  type        = bool
  default     = false
  nullable    = false
}

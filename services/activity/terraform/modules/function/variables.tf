variable "project" {}

variable "region" {}

variable "function_name" {}

variable "function_entry_point" {}

variable "event_trigger" {
  type = object({
    trigger  = optional(string)
    trigger_region = optional(string)
    event_type = string
    event_filters = optional(object({
      attribute = string
      value = string
      operator = optional(string)
    }))
    pubsub_topic = optional(string)
    service_account_email = optional(string)
    retry_policy = optional(string)
  })
  default = null
}
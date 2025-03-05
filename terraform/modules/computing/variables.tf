variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3a.large"]
}

variable "node_desired_size" {
  type    = number
  default = 4
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "capacity_type" {
  type    = string
  default = "SPOT"  # Thêm biến để chọn loại capacity
}

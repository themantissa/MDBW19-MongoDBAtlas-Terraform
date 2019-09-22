#
# Example main.tf from MDBW 19 talk updated for new MongoDB Atlas Provider 
# Uses https://github.com/terraform-providers/terraform-provider-mongodbatlas
# https://www.terraform.io/docs/providers/mongodbatlas/index.html
#
#  Variables we need for this terraform run
#  Normally want to put them in their own variables.tf file or use Env variables
#

variable "mongodb_atlas_api_pub_key" { default = ""}
variable "mongodb_atlas_api_pri_key" { default = "" }

variable "mongodb_atlas_org_id" { default = ""}

variable "database_username" { default = "" }
variable "database_user_password" { default = "" }

variable "mongodb_atlas_whitelistip" { default = "" }

#
# Configure the MongoDB Atlas Provider
#
provider "mongodbatlas" {
  public_key = "${var.mongodb_atlas_api_pub_key}"
  private_key  = "${var.mongodb_atlas_api_pri_key}"
}

#
# Create a Project 
#
resource "mongodbatlas_project" "my_project" {
  name 			= "DemoProjectCreation"
  org_id		= "${var.mongodb_atlas_org_id}"
}

#
# Create a Cluster in 2 Regions
#
resource "mongodbatlas_cluster" "cluster" {
  name                  	= "DemoClusterCreation"
  project_id            	= "${mongodbatlas_project.my_project.id}"
  backup_enabled		= false
  auto_scaling_disk_gb_enabled	= false
  mongo_db_major_version 	= "4.0"
  cluster_type   		= "REPLICASET"

  provider_name         	= "AWS"
  disk_size_gb			= 100
  provider_disk_iops		= 320
  provider_instance_size_name   = "M40"
  provider_backup_enabled 	= true

  replication_specs {
    num_shards	    		= 1
    regions_config {
      region_name     		= "US_WEST_1"
      priority        		= 7
      read_only_nodes 		= 0
      analytics_nodes 		= 1
      electable_nodes 		= 3
    }
    regions_config {
    region_name       		= "US_EAST_1"
    priority        		= 6
    read_only_nodes 		= 1
    analytics_nodes 		= 0
    electable_nodes 		= 2 
    }
  }
}

#
# Create a Database User
#
resource "mongodbatlas_database_user" "test" {
  username 		= "${var.database_username}"
  password 	 	= "${var.database_user_password}"
  project_id            = "${mongodbatlas_project.my_project.id}"
  database_name	 	= "admin"

  roles {
    role_name     	= "readWriteAnyDatabase"
    database_name 	= "admin"
  }
}

#
# Create an IP Whitelist
#
resource "mongodbatlas_project_ip_whitelist" "test" {
  project_id            = "${mongodbatlas_project.my_project.id}"  
  whitelist {  
    ip_address 		= "${var.mongodb_atlas_whitelistip}"
    comment    		= "Added with Terraform"
  }
}

# Alibaba China Prisma Access Service deployment


This repository contains 3 seperate terraform scripts with the goal of automating the deoployment of a VM-Series firewall as a Prisma Access Service Connection in Alibaba.  It also leverages an Express Connect tunnel to facilitate the connectivity to another region that has access to the Prisma Access Cloud Service.  Below is an overview of the deployment:


</br>
<p align="center">
<img src="https://user-images.githubusercontent.com/21991161/77763937-d5ab2080-7009-11ea-83b1-e6dd6242d34e.jpg">
</p>


## Prerequistes 
* Familiarity with Terraform.  
* Alibaba credentials and console access

</br>

## How to Deploy
### 1. Create keys 
This is an optional step.  If keys are already created in the desired deployment regions they can be reused.  The script to create keys is located in the [**Create-Alibaba-ECS-keys**](https://github.com/djspears/Alibaba/tree/master/Create-Alibaba-ECS-keys) directory.

<p align="center">
<b>Insert Access and Secret Keys and adjust regions as desired.</b>
<img src="https://user-images.githubusercontent.com/21991161/77771733-1492a380-7015-11ea-8aa5-cea22062d585.jpg" width="75%" height="75%" >
</p>

### 2. Edit terraform.tfvars
Open terraform.tfvars and edit variables (lines 1-4) to match your Project ID, SSH Key (from step 1), and VM-Series type.

```
$ vi terraform.tfvars
```

<p align="center">
<b>Your terraform.tfvars should look like this before proceeding</b>
<img src="https://user-images.githubusercontent.com/21991161/77771733-1492a380-7015-11ea-8aa5-cea22062d585.jpg" width="75%" height="75%" >
</p>

### 3. Deploy Build
```
$ terraform init
$ terraform apply
```

</br>

## How to Destroy
Run the following to destroy the build and remove the SSH key created in step 1.
```
$ terraform destroy
$ rm ~/.ssh/gcp-demo*
```

For more specific Please see the [**Deployment Guide**](https://github.com/wwce/terraform/blob/master/gcp/adv_peering_2fw_2spoke_common/GUIDE.pdf) for more information.


</br>

## Support Policy
The guide in this directory and accompanied files are released under an as-is, best effort, support policy. These scripts should be seen as community supported and Palo Alto Networks will contribute our expertise as and when possible. We do not provide technical support or help in using or troubleshooting the components of the project through our normal support options such as Palo Alto Networks support teams, or ASC (Authorized Support Centers) partners and backline support options. The underlying product used (the VM-Series firewall) by the scripts or templates are still supported, but the support is only for the product functionality and not for help in deploying or using the template or script itself.
Unless explicitly tagged, all projects or work posted in our GitHub repository (at https://github.com/PaloAltoNetworks) or sites other than our official Downloads page on https://support.paloaltonetworks.com are provided under the best effort policy.

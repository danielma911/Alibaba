# Alibaba China Prisma Access Service deployment


This repository contains 3 seperate terraform scripts with the goal of automating the deoployment of a VM-Series firewall as a Prisma Access Service Connection in Alibaba.  It also leverages an Express Connect tunnel to facilitate the connectivity to another region that has access to the Prisma Access Cloud Service.  Below is an overview of the deployment:


</br>
<p align="center">
<img src="https://user-images.githubusercontent.com/21991161/77763937-d5ab2080-7009-11ea-83b1-e6dd6242d34e.jpg">
</p>


## Prerequistes 
* Familiarity with Terraform.  
* Alibaba credentials and console access
* Download or clone this repo

</br>

## How to Deploy
### 1. Create keys 
This is an optional step.  If keys are already created in the desired deployment regions they can be reused.  The script to create keys is located in the [**Create-Alibaba-ECS-keys**](https://github.com/djspears/Alibaba/tree/master/Create-Alibaba-ECS-keys) directory.  After modifying the variables section perform a Terraform Init, Plan, and Apply.

<p align="center">
<b>Insert Access and Secret Keys and adjust regions as desired.</b>
<img src="https://user-images.githubusercontent.com/21991161/77771733-1492a380-7015-11ea-8aa5-cea22062d585.jpg" width="75%" height="75%" >
</p>

### 2. Deploy the infrastructure and VM-Series
The scripts to deploy the infrastructure is located in the following directory:
[**Prisma-Access-Mobile-Users-China**](https://github.com/djspears/Alibaba/tree/master/Prisma-Access-Mobile-Users-China) There will be modifications needed to the [**variables.tf**](https://github.com/djspears/Alibaba/blob/master/Prisma-Access-Mobile-Users-China/variables.tf) file.  Specifically the addition of the keys and Primsa Access Service IP must be updated and other variables can be changed to accomodate specific deployments. Below is a list of variables in the file:
<p align="center">
<img src="https://user-images.githubusercontent.com/21991161/77773047-10678580-7017-11ea-9341-956cb561a3de.jpg" width="75%" height="100%" >
</p>

After the deployment there terraform output should look similiar to this:
<p align="center">
<img src="https://user-images.githubusercontent.com/21991161/77763935-d5ab2080-7009-11ea-930a-8bf401277b10.jpg" width="75%" height="75%" >
</p>

The MGMT IP can be used to access the firewall.  THe default username/password is admin/admin.  Please change that.  
### IMPORTANT
Terraform does not currently support inserting an EIP as a Secondary address to an ECS. THe Script creates an EIP that can be attached to the Untrust interface of the VM-Series.  This set must be done manually if there is a need for traffic to be directed to the internet directly from the VM-Series.

### 3. Configure the VM-Series
There is a third Terraform script that leverages the PANW Terraform Provider for configuring the VM-Series Firewall. That is located in the [**FW-Config-panw-terraform**](https://github.com/djspears/Alibaba/tree/master/FW-Config-panw-terraform) directory. This will connect to the VM-Series and configure the IPSec connection to Prisma Access.  The variables file will need to be modified.

<p align="center">
<b>Insert Add the Alibaba key information.</b>
<img src="https://user-images.githubusercontent.com/21991161/77782004-8f16ef80-7024-11ea-8038-e2cd0aac5f41.jpg" width="75%" height="75%" >
</p>
### Note
This Terraform configure is getting the firewall address via a terraform data call.  If there are other resources in the region, this may fail and the Firewall MGMT address will need to be added to the variables file.
</br>
<b>A successful deployment of this will result in an output similiar to this.</b>
<img src="https://user-images.githubusercontent.com/21991161/77763934-d5128a00-7009-11ea-9ca0-6630e6da0ae2.jpg" width="75%" height="75%" >
</p>
## Support Policy
The guide in this directory and accompanied files are released under an as-is, best effort, support policy. These scripts should be seen as community supported and Palo Alto Networks will contribute our expertise as and when possible. We do not provide technical support or help in using or troubleshooting the components of the project through our normal support options such as Palo Alto Networks support teams, or ASC (Authorized Support Centers) partners and backline support options. The underlying product used (the VM-Series firewall) by the scripts or templates are still supported, but the support is only for the product functionality and not for help in deploying or using the template or script itself.
Unless explicitly tagged, all projects or work posted in our GitHub repository (at https://github.com/PaloAltoNetworks) or sites other than our official Downloads page on https://support.paloaltonetworks.com are provided under the best effort policy.

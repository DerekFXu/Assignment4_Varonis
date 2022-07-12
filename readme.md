# Assignment 4
This terraform script creates a VM set with two instances and load balancer for the VM set. It is done in modules so that the creation code can be duplicated into other regions easily.
Below are the resource groups with the proper assets created in Azure.

![Resource Group 1](https://github.com/DerekFXu/Assignment4_Varonis/blob/main/images/rg1.PNG?raw=true)

![Resource Group 2](https://github.com/DerekFXu/Assignment4_Varonis/blob/main/images/rg3.PNG?raw=true)

Below here is the traffic manager that is created from this script.
Side note: I just realized the traffic manager in the picture has a weighted routing method but the assignment called for geographic. This has been changed in the code and it now uses the geographic routing method.

![Traffic Manager](https://github.com/DerekFXu/Assignment4_Varonis/blob/main/images/traffic_manager.PNG?raw=true)

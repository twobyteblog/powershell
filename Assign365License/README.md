# Assign365License

Assigns or unassigns a Microsoft 365 license against a security group.

WARNING: This script modifies the licenses assigned to a group of users. Throughly test and verify this script prior to running on production.

# Requirements

This script requires the Microsoft Graph module be installed. To install. run: ```Install-Module Microsoft.Graph.Intune -Scope CurrentUser```

# Use

To assign or unassign a license, perform the following steps:

1. Browse to Microsoft's [Licensing Service Plan Reference](https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference) and determine the SKU of the the license you would like added or removed.
2. Determine the security group which will have the license remove/added.

To add a license, run:

```.\Assign365License.ps1 -Group GROUPNAME -SKU SKU -add```

To remove a license, run:

```.\Assign365License.ps1 -Group GROUPNAME -SKU SKU -remove```


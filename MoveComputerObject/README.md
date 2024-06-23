# MoveComputerObject

Connects to a Domain Controller and moves a computer objects between two specified OUs.

## Requires

This script requires WinRM be enabled and accessible on the Domain Controller so a remote connection can be made.

## Execution

Looks for all computers named ```$LaptopNameContains``` and moves them to the OU specified by ```$DestinationLaptopOU```. The same actions are performed for workstations respectively.


# EnableBitLocker

Script which enables BitLocker on a PC. Note, this script assumes that a BitLocker GPO, outlining how BitLocker should be configured, has already been applied to the PC.

This script performs the following actions:

1. Installs the BitLocker feature if not installed on the PC.
2. Enables BitLocker on the C:\ drive.

This script skips BitLocker's Hardware Test when enabling BitLocker. Please ensure your PC is BitLocker compatible before deploying.
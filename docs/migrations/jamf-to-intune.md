# Migration Guide: Jamf Pro to Microsoft Intune (macOS)

Migrating macOS devices from Jamf Pro to Microsoft Intune is a multi-step process that requires un-enrolling from Jamf and re-enrolling into Intune. 

## The Challenge
macOS does not support being enrolled in two MDMs simultaneously. Furthermore, an MDM profile (`com.apple.mdm`) cannot be removed by a script if it was installed via Automated Device Enrollment (ADE / DEP) and marked as "non-removable".

## Migration Strategy

### Option 1: The Wipe and Reload (Recommended for ADE)
If the device is ADE-enrolled and the MDM profile is locked:
1. Re-assign the device in Apple Business Manager (ABM) from the Jamf server to the Intune server.
2. Send an `EraseDevice` command from Jamf.
3. The user goes through Setup Assistant, authenticates, and is enrolled directly into Intune.

### Option 2: Scripted Migration (BYOD / Removable Profiles)
If the MDM profile is removable, you can automate the switch:

1. **Deploy Intune Company Portal**: Push the Intune Company Portal app via Jamf.
2. **Remove Jamf Framework**: Run a script via Jamf to self-destruct the Jamf binary.
   ```bash
   # CAUTION: Running this removes Jamf control immediately.
   /usr/local/jamf/bin/jamf removeFramework
   ```
3. **User Action Required**: The user must open Company Portal, sign in, and manually download and approve the Intune Management Profile in System Settings.

## Repackaging Scripts for Intune
Scripts in this repository are designed to be MDM-agnostic. To move a script from Jamf to Intune:
- **Jamf**: Uses `$4` for parameters.
- **Intune**: Does not natively support script parameters in the portal. You must hardcode the variables (e.g., `EXPECTED_SHA256="xxx"`) in the script before uploading it to the Intune portal.

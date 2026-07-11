# Baseline Configuration Profiles

These profiles enforce foundational security policies that should be deployed to **all** managed macOS devices, regardless of which EDR or applications are installed.

## Profiles

| Profile | File | Description |
|---|---|---|
| **Automatic Software Updates** | [`software-updates.mobileconfig`](software-updates.mobileconfig) | Enforces automatic download and installation of macOS, app, and security updates. Prevents installation of macOS Betas. |
| **FileVault Escrow** | [`filevault-escrow.mobileconfig`](filevault-escrow.mobileconfig) | Enables FileVault 2 disk encryption and escrows the recovery key to your MDM. |
| **Screensaver Lock** | [`screensaver-lock.mobileconfig`](screensaver-lock.mobileconfig) | Sets an idle timeout and requires password after screensaver or display sleep activates. |
| **System Restrictions** | [`system-restrictions.mobileconfig`](system-restrictions.mobileconfig) | Enforces baseline system restrictions (e.g., Gatekeeper, SIP acknowledgment). |

## Deploy Order

Baseline profiles have **no dependency order** — deploy them all simultaneously or in any order.

## Important Notes

> ⚠️ **PayloadUUID**: You must regenerate `PayloadUUID` values with `uuidgen` before deploying to production. Never reuse the example UUIDs across organizations.

> ⚠️ **FileVault Escrow**: The FileVault escrow profile requires your MDM to support recovery key escrow. Test on a single device before deploying broadly.

## Tested On

- macOS 13 Ventura
- macOS 14 Sonoma
- macOS 15 Sequoia

## MDM Compatibility

| MDM | Notes |
|---|---|
| **Jamf Pro** | Upload as Configuration Profiles. FileVault escrow is natively supported. |
| **Microsoft Intune** | Upload as Custom Configuration Profiles (macOS). |
| **Kandji** | Use Library Profiles or upload as Custom Profiles. |
| **Mosyle** | Upload under Management → Profiles. |
| **JumpCloud** | Upload under Device Management → MDM Policies. |

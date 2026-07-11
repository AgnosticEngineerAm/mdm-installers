# Microsoft Defender Configuration Profiles

These macOS configuration profiles pre-approve the system-level permissions required by Microsoft Defender for Endpoint (MDE). **Deploy these profiles BEFORE running the install script** to achieve a fully silent, zero-touch installation.

## Profiles

| Profile | File | Payload Type | Description |
|---|---|---|---|
| **PPPC (Privacy Preferences)** | [`pppc.mobileconfig`](pppc.mobileconfig) | `com.apple.TCC.configuration-profile-policy` | Grants Full Disk Access to the Microsoft Defender agent. Required for real-time protection and scanning. |
| **System Extension** | [`system-extension.mobileconfig`](system-extension.mobileconfig) | `com.apple.system-extension-policy` | Pre-approves the Microsoft Defender Endpoint Security and Network system extensions (Team ID: `UBF8T346G9`). |

## Deploy Order

> 🔑 **Critical:** Profiles must be deployed and applied **before** Microsoft Defender is installed.

1. Deploy both profiles via MDM
2. Verify profiles are installed on target devices
3. Run the install script

## Bundle IDs

| Bundle ID | Component |
|---|---|
| `com.microsoft.wdav` | Microsoft Defender Application |
| `com.microsoft.wdav.epsext` | Endpoint Security System Extension |
| `com.microsoft.wdav.netext` | Network Extension |

## Team ID

- **`UBF8T346G9`** — Microsoft Corporation

## Important Notes

> ⚠️ **PayloadUUID**: Regenerate all `PayloadUUID` values with `uuidgen` before production deployment.

> ℹ️ **Intune Users**: If managing macOS via Microsoft Intune, Defender profiles can be deployed through the Intune Endpoint Security blade instead of uploading custom mobileconfig files.

## Tested On

- macOS 13 Ventura
- macOS 14 Sonoma
- macOS 15 Sequoia

## Vendor Documentation

- [Microsoft Defender for Endpoint on macOS](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-endpoint-mac)
- [Manual deployment for MDE on macOS](https://learn.microsoft.com/en-us/defender-endpoint/mac-install-manually)

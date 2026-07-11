# CrowdStrike Falcon Configuration Profiles

These macOS configuration profiles pre-approve the system-level permissions required by the CrowdStrike Falcon sensor. **Deploy these profiles BEFORE running the install script** to achieve a fully silent, zero-touch installation.

## Profiles

| Profile | File | Payload Type | Description |
|---|---|---|---|
| **PPPC (Privacy Preferences)** | [`pppc.mobileconfig`](pppc.mobileconfig) | `com.apple.TCC.configuration-profile-policy` | Grants Full Disk Access to the CrowdStrike Falcon agent. Required for endpoint visibility. |
| **System Extension** | [`system-extension.mobileconfig`](system-extension.mobileconfig) | `com.apple.system-extension-policy` | Pre-approves the CrowdStrike Falcon system extension (Team ID: `X9E956P446`). |
| **Network Extension** | [`network-extension.mobileconfig`](network-extension.mobileconfig) | `com.apple.webcontent-filter` | Pre-approves the CrowdStrike Falcon Content Filter for network traffic inspection. |

## Deploy Order

> 🔑 **Critical:** Profiles must be deployed and applied **before** the Falcon sensor is installed.

1. Deploy all 3 profiles via MDM
2. Verify profiles are installed on target devices
3. Run the install script

## Bundle IDs

| Bundle ID | Component |
|---|---|
| `com.crowdstrike.falcon.Agent` | CrowdStrike Falcon Agent |
| `com.crowdstrike.falcon.App` | CrowdStrike Falcon GUI Application |

## Team ID

- **`X9E956P446`** — CrowdStrike, Inc.

## Important Notes

> ⚠️ **PayloadUUID**: Regenerate all `PayloadUUID` values with `uuidgen` before production deployment.

## Tested On

- macOS 13 Ventura
- macOS 14 Sonoma
- macOS 15 Sequoia

## Vendor Documentation

- [CrowdStrike macOS Sensor Deployment Guide](https://falcon.crowdstrike.com/documentation/)
- [CrowdStrike KB: macOS Configuration Profiles](https://falcon.crowdstrike.com/documentation/)

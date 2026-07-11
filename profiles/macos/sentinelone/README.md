# SentinelOne Configuration Profiles

These macOS configuration profiles pre-approve the system-level permissions required by the SentinelOne Singularity agent. **Deploy these profiles BEFORE running the install script** to achieve a fully silent, zero-touch installation.

## Profiles

| Profile | File | Payload Type | Description |
|---|---|---|---|
| **PPPC (Privacy Preferences)** | [`pppc.mobileconfig`](pppc.mobileconfig) | `com.apple.TCC.configuration-profile-policy` | Grants Full Disk Access to the SentinelOne agent daemon and GUI app. Required for filesystem scanning. |
| **System Extension** | [`system-extension.mobileconfig`](system-extension.mobileconfig) | `com.apple.system-extension-policy` | Pre-approves the SentinelOne Endpoint Security system extension (Team ID: `4QXE9H42T`). |
| **Network Extension** | [`network-extension.mobileconfig`](network-extension.mobileconfig) | `com.apple.webcontent-filter` | Pre-approves the SentinelOne Content Filter for network traffic inspection. |
| **Notifications** | [`notifications.mobileconfig`](notifications.mobileconfig) | `com.apple.notificationsettings` | Pre-configures notification preferences to prevent the "Allow Notifications" user prompt. |

## Deploy Order

> 🔑 **Critical:** Profiles must be deployed and applied **before** the SentinelOne agent is installed.

1. Deploy all 4 profiles via MDM
2. Verify profiles are installed on target devices (MDM console or `profiles show` on device)
3. Run the install script

## Bundle IDs

| Bundle ID | Component |
|---|---|
| `com.sentinelone.sentineld` | SentinelOne Agent Daemon |
| `com.sentinelone.sentineld-helper` | SentinelOne Helper Daemon |
| `com.sentinelone.sentinel-agent` | SentinelOne GUI Application |

## Team ID

- **`4QXE9H42T`** — SentinelOne, Inc.

## Important Notes

> ⚠️ **PayloadUUID**: Regenerate all `PayloadUUID` values with `uuidgen` before production deployment.

## Tested On

- macOS 13 Ventura
- macOS 14 Sonoma
- macOS 15 Sequoia

## Vendor Documentation

- [SentinelOne macOS System Requirements](https://support.sentinelone.com/)
- [SentinelOne KB: macOS Configuration Profiles](https://support.sentinelone.com/)

# Migration Guide: CrowdStrike Falcon to SentinelOne

Migrating from one EDR to another on macOS and Windows is historically difficult because EDRs are designed to resist being uninstalled (Tamper Protection).

This guide provides a high-level MDM strategy for migrating from CrowdStrike Falcon to SentinelOne.

## 1. Disable Tamper Protection (CrowdStrike)
Before any uninstall scripts can run, you **must** disable Tamper Protection in the CrowdStrike Falcon console.
1. Create a Host Group in CrowdStrike for "Migration Targets".
2. Assign a Sensor Update Policy to this group with Tamper Protection **disabled**.
3. Move endpoints into this group and wait for them to check in.

## 2. Deploy SentinelOne Profiles (macOS)
Before deploying the SentinelOne agent, you must deploy its Configuration Profiles to prevent user prompts.
See the [SentinelOne Profiles README](../../profiles/macos/sentinelone/README.md).

## 3. Run the CrowdStrike Uninstall Script
Deploy the [macOS CrowdStrike uninstall script](../../scripts/macos/crowdstrike/uninstall.sh) and [Windows CrowdStrike uninstall script](../../scripts/windows/crowdstrike/uninstall.ps1) to the migration targets via your MDM.
*Note: Our Windows uninstall script requires passing the `CS_MAINTENANCE_TOKEN` if Tamper Protection is enabled. If you disabled it via policy in Step 1, you can leave it blank.*

## 4. Run the SentinelOne Install Script
Once the MDM verifies CrowdStrike is removed, trigger the SentinelOne install script:
- [macOS Install Script](../../scripts/macos/sentinelone/install.sh)
- [Windows Install Script](../../scripts/windows/sentinelone/install.ps1)

## 5. Verify and Clean Up
- Verify the endpoints appear in the SentinelOne console.
- Remove the endpoints from the CrowdStrike console.
- Remove the old CrowdStrike Configuration Profiles from macOS via MDM.

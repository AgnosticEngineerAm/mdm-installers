# Secret Management in MDM Scripts

When writing installation scripts for MDM, you frequently need to handle secrets such as:
- EDR Site Tokens (SentinelOne)
- Customer IDs (CrowdStrike)
- API Keys (JumpCloud)
- Local Administrator Passwords (LAPS)

This guide outlines best practices for handling secrets in the `mdm-installers` repository.

## 1. Never Hardcode Secrets in the Repository
All scripts in this repository use placeholder values, for example:
`S1_SITE_TOKEN="PASTE_YOUR_SITE_TOKEN_HERE"`

You must replace these placeholders in your MDM console, but **do not commit your real tokens back to version control**.

## 2. Using Script Variables (Parameters)
Most modern MDMs (Jamf Pro, Kandji, Intune) allow you to pass parameters to scripts at runtime.

### Jamf Pro Example
Instead of hardcoding the token in the script, use Jamf's `$4` parameter:
```bash
S1_SITE_TOKEN="$4"
```
You then define `$4` securely in the Jamf Policy GUI.

### Intune Example
Intune does not support script arguments natively for shell scripts in the same way, so you often have to rely on Environment Variables or deploying a hidden configuration file beforehand.

## 3. Masking Output
When writing logs (e.g., to `/var/log/mdm-install.log`), ensure you never echo the secret.
**Bad**:
```bash
log "Registering with token $S1_SITE_TOKEN" # DON'T DO THIS
```
**Good**:
```bash
log "Registering agent (token is masked)..."
```

## 4. Configuration Profiles as Secret Delivery
For applications that support Managed Preferences (macOS), the most secure way to deliver a token is via a Configuration Profile (`.mobileconfig`). The profile is installed securely by the OS, and the app reads it from `NSUserDefaults`, completely bypassing the need to have the token in the bash script at all.

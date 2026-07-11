# Configuration Profile Deployment Order

When deploying complex agents (especially security tools like EDRs or VPNs) via MDM on macOS, **the order of operations is critical**. 

If a `.pkg` is installed before its required `.mobileconfig` profiles are present, the user will be bombarded with system prompts ("System Extension Blocked", "Full Disk Access Required"). Even worse, if the user clicks "Deny", the MDM often cannot override that user choice without physical intervention in Recovery Mode.

## The Golden Rule of macOS MDM

> **Always deploy Configuration Profiles BEFORE deploying the application binaries.**

## Recommended Deployment Order

When building your MDM deployment pipeline (e.g., Jamf Policies, Kandji Blueprints, or Intune Apps/Profiles), enforce the following order:

### Phase 1: Security & Permissions Profiles
Deploy these immediately upon enrollment. Do not proceed to Phase 2 until the MDM confirms these profiles are installed.
1. **System Extension Policy (`com.apple.system-extension-policy`)**: Pre-approves Team IDs (e.g., SentinelOne, CrowdStrike).
2. **Privacy Preferences Policy Control (PPPC)**: Grants Full Disk Access, Accessibility, or Screen Recording permissions.
3. **Web Content Filter / Network Extension (`com.apple.webcontent-filter`)**: Allows network monitoring tools to run without prompting.
4. **Notifications (`com.apple.notificationsettings`)**: Suppresses annoying "App added to background items" notifications (macOS 13+).

### Phase 2: Application Configuration (Managed Preferences)
1. **Custom Plists**: Deploy any `.plist` files required for application configuration (e.g., license keys, default settings).
2. **Onboarding Payloads**: Deploy custom JSON onboarding files if required (e.g., Microsoft Defender `mdatp` onboarding blob).

### Phase 3: Application Binaries
Only after Phase 1 and 2 are confirmed:
1. Run the `.pkg`, `.sh`, or `.dmg` installer scripts.
2. Because the profiles (Phase 1) and configuration (Phase 2) are already present, the binary will silently install, load its extensions, and read its config without ever alerting the user.

## Troubleshooting Order of Operations
If users report seeing "System Extension Blocked" prompts:
1. Your MDM may be pushing apps and profiles asynchronously. 
2. **Fix**: In Jamf, ensure profiles are scoped to a Smart Group, and the App policy requires membership in that Smart Group. In Intune, use App Dependencies.

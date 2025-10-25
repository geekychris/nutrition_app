# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated building and testing of the Nutrition Tracker iOS app.

## Workflows

### CI Build (`ci.yml`)

**Trigger**: Push or pull request to `main` or `develop` branches

**Purpose**: Continuous integration - validates that code changes build successfully

**What it does**:
- Checks out the code
- Builds the app for iOS Simulator (iPhone 14, 15, 16, 17, and 18)
- Runs unit tests on all devices (if available)
- Runs SwiftLint (if configured)

**Requirements**: None - runs on GitHub's macOS runners

**Note**: Uses a matrix strategy to test against multiple iPhone models in parallel

### Release Build (`release.yml`)

**Trigger**: 
- Push of version tags (e.g., `v1.0.0`, `v2.1.3`)
- Manual dispatch from GitHub Actions UI

**Purpose**: Creates distributable builds for TestFlight or Ad Hoc distribution

**What it does**:
- Checks out the code
- Increments build number
- Imports code signing certificates (if configured)
- Archives the app for Release
- Exports IPA file (if certificates available)
- Uploads build artifacts
- Creates GitHub release (for tag pushes)

**Requirements**: Optional secrets for code signing (see below)

## Setup

### For CI Builds

No setup required - CI builds work out of the box without code signing.

### For Release Builds (with Code Signing)

To enable full release builds with IPA export, configure these GitHub repository secrets:

1. **BUILD_CERTIFICATE_BASE64**
   - Your iOS Distribution certificate in base64 format
   - Export from Keychain as .p12, then encode:
     ```bash
     base64 -i certificate.p12 | pbcopy
     ```

2. **P12_PASSWORD**
   - Password for the .p12 certificate file

3. **PROVISIONING_PROFILE_BASE64**
   - Your provisioning profile in base64 format
   - Encode your .mobileprovision file:
     ```bash
     base64 -i profile.mobileprovision | pbcopy
     ```

4. **TEAM_ID**
   - Your Apple Developer Team ID
   - Find in Apple Developer Portal → Membership

5. **KEYCHAIN_PASSWORD**
   - A temporary password for the build keychain
   - Can be any secure random string

### Adding Secrets

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with the exact names listed above

## Usage

### Running CI Build

CI builds run automatically on:
- Push to `main` or `develop` branches
- Pull requests targeting `main` or `develop`

### Creating a Release

#### Option 1: Tag-based Release (Recommended)

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This will:
- Trigger the release workflow
- Build and archive the app
- Create a GitHub release with the version number

#### Option 2: Manual Release

1. Go to GitHub → Actions tab
2. Select "Release Build" workflow
3. Click "Run workflow"
4. Optionally specify a version number
5. Click "Run workflow" button

### Downloading Build Artifacts

After a successful release build:

1. Go to GitHub → Actions tab
2. Click on the completed workflow run
3. Scroll to "Artifacts" section
4. Download:
   - **Archive** - For uploading to TestFlight via Xcode Organizer
   - **IPA** - For Ad Hoc distribution to devices (if code signing is configured)

## Build Configurations

### Without Code Signing

Without code signing secrets, the workflow will:
- ✅ Build and archive the app
- ✅ Upload the .xcarchive artifact
- ❌ Cannot export IPA file
- ℹ️ Archive can be manually distributed via Xcode Organizer

### With Code Signing

With all secrets configured, the workflow will:
- ✅ Build and archive the app
- ✅ Export signed IPA file
- ✅ Upload both archive and IPA artifacts
- ✅ Attach IPA to GitHub release (for tag builds)

## Troubleshooting

### Build Fails on Simulator

Check the Xcode version and iOS Simulator version in `ci.yml`:
```yaml
- name: Select Xcode version
  run: sudo xcode-select -s /Applications/Xcode_15.2.app/Contents/Developer
```

Available Xcode versions on GitHub runners: https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md

### Code Signing Issues

1. Verify all required secrets are set in repository settings
2. Check that certificate is valid and not expired
3. Ensure provisioning profile matches the certificate
4. Verify Team ID is correct

### Archive Succeeds but IPA Export Fails

- Check that the provisioning profile is Ad Hoc or App Store distribution
- Verify the profile includes the app's bundle identifier
- Ensure the certificate matches the profile's distribution type

## Customization

### Changing Build Configurations

Edit the workflow files to customize:

- **Xcode version**: Update the `xcode-select` path
- **iOS version**: Modify the `-destination` parameter
- **Build configuration**: Change `-configuration Release` to `Debug`
- **Branches**: Update the `on.push.branches` and `on.pull_request.branches`

### Adding Additional Steps

You can add steps for:
- Running additional tests
- Code quality checks (SwiftLint, SwiftFormat)
- Uploading to TestFlight automatically via fastlane
- Sending notifications (Slack, email, etc.)

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)

# Firestore Security Handoff: Compromised eMudhra Intermediate CA

_Written Nov 3, 2026, from a Firebase dependency audit of this repo, after Firebase's Nov 3, 2026 notice. Firebase guide: https://firebase.google.com/support/guides/compromised-emudhra-intermediate-ca (dated Oct 22, 2026)._

## Summary
Some eMudhra intermediate CA certificates were compromised. The Apple (iOS) Firestore SDK compiles its TLS root certificate bundle into the app binary, so older builds may trust forged certificates. That opens them to man-in-the-middle attacks on Firestore traffic.

- **Fixed versions:** Apple FirebaseFirestore **13.1.1+** (recommended), or **12.19.3**. CocoaPods tops out at **12.19.3** because Firebase 12 is the last major release on CocoaPods.
- **OS and server updates don't fix installed builds.** The app has to be rebuilt with a patched SDK, republished to the App Store, and users prompted to update.
- **Not affected:** Web, Android, and server SDKs.

## What's affected in this repo
- Firebase project `half-plus-seven`, bundle ID `com.Daniel.Half-Plus-Seven`
- `Podfile` (platform :ios, '15.0') includes unpinned `pod 'Firebase/Auth'`, `pod 'Firebase/Firestore'`, `pod 'GoogleSignIn'`
- `Podfile.lock`: **FirebaseFirestore 11.15.0** (Firebase 11.15.0), `COCOAPODS: 1.17.0`. **Vulnerable.**
- Firestore is used in `Half Plus Seven/AddViewController.m`, `ResultsViewController.m`, `AnswerViewController.m`, `NamesViewController.m`, `UserViewController.m`, `AppDelegate.m`, and `LogInViewController.m`.
- At the time of the audit, the latest commit was Build 6 (`ea05cad`).

**Target:** FirebaseFirestore **12.19.3** (the highest version on CocoaPods). This is a **major jump from 11 to 12**.

## Steps
1. Review the Firebase 12 breaking changes in the release notes linked below. Check the minimum iOS deployment target: the Podfile and app target use 15.0, and some project-level settings still say 8.1. Raise the deployment target if Firebase 12 requires it.
2. Run `pod repo update`.
3. Optional: pin in `Podfile`, e.g. `pod 'Firebase/Firestore', '~> 12.19.3'` (and the same for Auth).
4. Run `pod update Firebase FirebaseFirestore` (GoogleSignIn may also need to be updated for compatibility).
5. Confirm that `Podfile.lock` lists `FirebaseFirestore (12.19.3)`.
6. Open `Half Plus Seven.xcworkspace`, then clean and build. Fix any API changes.
7. Device test: sign-in (including Sign in with Apple), Firestore reads and writes, and account deletion.
8. Ship it in Build 6 if Build 6 hasn't been submitted yet, otherwise in Build 7. Bump the build number and submit.
9. Prompt users to update.

## Verification checklist
- [x] `Podfile.lock` shows FirebaseFirestore 12.19.3 (or higher)
- [x] App builds cleanly
- [x] Firestore reads and writes work on a real device
- [ ] New build submitted and approved on the App Store (Build 7 `1.02 (7)` uploaded to App Store Connect)
- [ ] Users prompted to update

## Links
- Firebase guide: https://firebase.google.com/support/guides/compromised-emudhra-intermediate-ca
- Firebase iOS SDK releases: https://github.com/firebase/firebase-ios-sdk/releases
- Firebase Apple release notes: https://firebase.google.com/support/release-notes/ios

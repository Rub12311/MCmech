# MCmech

## iPhone app

Open `ios/MCmech.xcodeproj` in Xcode.

- `ios/MCmech/`: SwiftUI app source and assets.
- `ios/MCmechTests/`: Swift unit tests.
- `ios/MCmechUITests/`: UI tests.

The iOS app implements Phase 1: VIN validation, live NHTSA lookup, review before saving, and persistent on-device vehicle storage. It connects directly to NHTSA over HTTPS; no Mac server is required. Saved vehicles are stored atomically as JSON in the app’s Application Support directory and are independent of the web garage. Unknown engine information remains unknown; no repair procedure is matched.

Select your iPhone in Xcode and press Run to install. Use Product > Test to run the Swift tests. Lookup requires internet; saved vehicles can be viewed offline. Deleting the app may remove its local garage.

The repository root holds Git configuration and documentation. Keep the Xcode project, app source, and test folders together inside `ios/`; their paths are relative to each other. Personal Xcode UI settings and build outputs are excluded from Git.

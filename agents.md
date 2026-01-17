# Project: Android Toolset Utility App (Flutter)

## Overview
Build a production-grade Android utility toolbox in Flutter (Dart) with system-level features implemented via Platform Channels (Kotlin) where needed. Core modules include File Finder, Cleanup, Process Insights (policy-safe), and Battery Info with optional history tracking. The app is monetized via AdMob banner ads with GDPR consent using the User Messaging Platform. There are no forced popups, and optional full-screen ads are only shown via explicit user opt-in.

## Current Phase
Architecture and dependency selection finalized, implementation pending.

## Project Structure

### Core Application Files
- lib/app.dart - Application bootstrap, routing configuration, and theme setup
- lib/core/ - Shared utilities, error models, and permission helpers
- lib/features/files/ - File Finder user interface and domain logic
- lib/features/cleanup/ - Cleanup scanning, review, and deletion flows
- lib/features/process/ - Usage insights and system shortcuts
- lib/features/battery/ - Live metrics and history charts
- lib/features/settings/ - Privacy controls, consent management, ads toggles, and diagnostics
- lib/services/platform/ - MethodChannel wrappers for storage, battery, and usage stats
- lib/services/ads/ads_manager.dart - Banner ads plus optional opt-in interstitial and rewarded ads
- lib/services/storage/storage_repo.dart - MediaStore and Storage Access Framework abstractions
- lib/services/telemetry/ - Optional crash reporting (disabled by default)
- lib/core/platform_errors.dart - Standardized error handling for platform channel operations
- android/app/src/main/kotlin/ - Native bridges for SAF/MediaStore and UMP helpers
- README.md - Setup instructions, policies, and limitations
- privacy-policy.md - GDPR and advertising disclosure (source for hosted HTML version)

## Architecture Decisions

### Flutter and Native Integration
Flutter-first user interface with native Kotlin implementations via Platform Channels for system-level operations including:

**Scoped Storage and Storage Access Framework**
- Tree access for deep directory browsing
- Delete requests with system confirmation dialogs

**MediaStore Queries**
- Fast metadata search across media collections
- Optimized pagination for large result sets

**BatteryManager Advanced Properties**
- Current flow measurements (current_now)
- Charge counter readings
- Device-dependent field availability

**UsageStatsManager Integration**
- Opt-in usage access permission
- Application foreground time tracking
- Last used timestamps

**Google User Messaging Platform Consent**
- Reliable GDPR compliance flow
- Consent state persistence
- Consent expiration handling

### Policy-Safe Process Feature Set
The process insights feature is designed to comply with Google Play Store policies by avoiding deceptive claims and respecting system boundaries:

**Prohibited Actions**
- No claims about RAM boost or memory optimization
- No force-killing of applications
- No background process manipulation

**Permitted Features**
- Memory usage insights (device RAM and available memory)
- Application usage statistics with proper permission
- Deep links to system application settings screens
- Direct shortcuts to battery optimization and notification settings

### User-Controlled Cleanup System
Cleanup operations follow a strict user-controlled workflow to prevent accidental data loss:

**Cleanup Flow**
1. Scan for candidate files (large files, downloads, screenshots, duplicates)
2. Present review screen with file details and previews
3. Require explicit user selection and confirmation
4. Execute deletion with system-level confirmation dialogs
5. Handle deletion failures gracefully with UI feedback

**Safety Measures**
- No background automatic deletion
- No cleanup without explicit user action
- Protection against system and protected file deletion
- Warning dialogs for bulk operations (more than 100 files)

### Monetization Strategy
The application uses a transparent, user-friendly monetization approach:

**Banner Advertisements**
- Enabled by default
- Positioned at bottom of screen
- Collapses automatically on load failure
- 60-second auto-refresh (AdMob default)
- Test ad units in debug builds

**Optional Full-Screen Advertisements**
- Disabled by default
- Requires explicit user opt-in
- Frequency cap of 1 per hour maximum
- Shown after cleanup scan completion (when opted in)
- Preloaded on app start for instant display

**Consent Management**
- UMP consent shown on first launch
- Re-prompt when consent expires (12 months)
- Manage Consent option in Settings screen
- Full compliance with GDPR requirements

## Dependencies and Libraries

### State Management
**Primary Choice: Riverpod**
- flutter_riverpod - Reactive state management
- riverpod - Core dependency

Riverpod is selected over BLoC for this project because it provides better async operation handling (critical for file scanning and MediaStore queries), requires less boilerplate for simple state like battery readings, and offers easier testing of business logic.

### Routing and Navigation
- go_router - Declarative routing with deep linking support

### Data Persistence
- shared_preferences - Simple key-value storage for settings, consent state, and ad frequency caps
- isar - High-performance database for battery history time-series data
- hive - Fast key-value storage for file scan cache

### Permissions and File Operations
- permission_handler - Android 13+ media permissions support
- file_picker - Fallback file selection
- share_plus - File sharing functionality
- open_filex - File opening with system applications
- path_provider - Access to cache and temporary directories

### User Interface Components
- flutter_svg - Scalable vector graphics
- material_symbols_icons - Material Design icon library
- flutter_slidable - Multi-action swipe gestures
- pull_to_refresh - Pull-to-refresh functionality (optional)
- flutter_native_splash - Professional startup experience

### Device Information and Battery
- battery_plus - Basic battery state and level
- device_info_plus - Device and Android version information
- package_info_plus - App version and build information

### Data Visualization
- fl_chart - Battery percentage and temperature history charts

### Advertising and Consent
- google_mobile_ads - AdMob integration for banner, interstitial, and rewarded ads
- Custom Platform Channel for User Messaging Platform (UMP) consent flow implemented in Kotlin

### Background Tasks
- workmanager - Android WorkManager integration for periodic battery history snapshots

Note: WorkManager has strict constraints on Android 12+ devices. Battery history is opt-in with clear disclaimers about reliability. A manual "Log Now" button provides fallback functionality.

### Utilities
- logger - Structured logging for debugging
- url_launcher - Opening privacy policy links and Play Store pages
- intl and flutter_localizations - Internationalization support

### Optional Features
Crash reporting is intentionally excluded from initial release. Google Play Console provides automatic crash reporting without SDK overhead. Sentry Flutter can be added after reaching 10,000+ installs if needed.

## Feature Specifications

### File Finder

**Search and Filtering**
- Fast name-based search using MediaStore queries
- File type filters (images, videos, audio, downloads, documents)
- Sorting options (size, date, name)
- Pagination with 100 items per page for performance

**Data Sources**
- MediaStore-backed results for images, videos, audio, downloads, and files
- SAF folder mode allowing user to select directory trees for deep browsing
- Sort by date descending for faster recent files access
- MIME type indexing for category filters

**File Operations**
- Multi-select capability with visual feedback
- Share selected files via system share sheet
- Open files with associated applications
- Move and copy operations
- Delete via MediaStore or SAF intents with system confirmation

### Cleanup

**Scan Categories**
- Large files (configurable size threshold, default 100MB+)
- Downloads folder contents
- Screenshots and screen recordings
- Duplicate files (optional feature)

**Duplicate Detection**
File hashing using crypto package in Dart isolates with MD5 or SHA256 algorithms. Files larger than 10MB are hashed in chunks with progress indication. Hash results are cached in Isar database with file path and modified date for performance. Perceptual hashing for images is excluded due to complexity.

**Safe Mode Application Cache**
Instead of directly clearing application caches, provide deep links to system App Info screens where users can manually manage cache. This ensures policy compliance and prevents unintended data loss.

**Deletion Workflow**
1. Present files grouped by category
2. Allow user selection with select all option
3. Show total size to be freed
4. Require explicit confirmation dialog
5. Execute MediaStore or SAF delete requests
6. Collapse UI on delete failure with error message
7. Show success summary with actual space freed

**File Operation Safety**
Blocked paths include /system, /data/app, /Android/data, and /.thumbnails to prevent deletion of system or protected files. Bulk delete operations affecting more than 100 files trigger additional warning dialogs.

### Process Insights

**Memory Overview**
- Total device RAM
- Available memory
- Per-application memory usage (when Usage Access permission granted)

**Usage Statistics (Opt-in)**
Requires Usage Access permission with clear explanation dialog. Features include:
- Last used timestamp for each application
- Total foreground time
- Usage patterns visualization

**Application Actions**
- Open App Info screen (system settings)
- Uninstall application (system uninstall flow)
- Battery optimization settings
- Notification settings
- Data usage details

**Permission Flow for Usage Access**
Triggered by "Enable Insights" button in Process screen. Deep link to Usage Access settings with instructional overlay showing where to enable permission. Graceful handling of permission denial with feature explanation.

### Battery Information

**Live Metrics**
- Battery percentage
- Charging status (charging, discharging, full, not charging)
- Temperature (Celsius and Fahrenheit)
- Voltage
- Current flow (current_now, device-dependent)
- Health status (good, overheat, dead, over voltage, when available)

**Device Variance Handling**
Explanatory text for unsupported fields noting that availability depends on device hardware and manufacturer implementation. Fallback to "Not available" with information icon.

**Opt-in History Tracking**
Periodic snapshots via WorkManager with user opt-in and clear disclaimers about background task reliability. Manual "Log Now" button for immediate data point capture. Charts display battery percentage and temperature trends over time using fl_chart. Data stored in Isar database with timestamp indexing.

**History Management**
Users can delete all history data from Settings screen. Clear indication of last snapshot time and total data points collected.

## Permissions Strategy

### First Launch Flow
1. Request INTERNET permission (required for advertisements)
2. Display UMP consent dialog
3. Complete consent flow before showing main interface

### File Finder Permissions
Requested on first use of File Finder feature:

**Android 13 and Above**
- READ_MEDIA_IMAGES
- READ_MEDIA_VIDEO
- READ_MEDIA_AUDIO

**Android 12 and Below**
- READ_EXTERNAL_STORAGE

Permission request includes explanation dialog describing why access is needed and what features it enables.

### Storage Access Framework
Triggered by "Browse Folder" button. No special permission needed as user grants access per folder through system SAF picker.

### Usage Statistics Permission
Triggered by "Enable Insights" button in Process screen. Deep link to Settings with instructional overlay showing permission location. Feature gracefully disabled if permission not granted.

### Battery History Background Tasks
No special permission required. WorkManager permission declared in AndroidManifest.xml. User must opt-in through Settings before background snapshots begin.

## Error Handling

### Platform Channel Error Standardization
All platform channel operations use standardized error codes and error model:

**Error Codes**
- PERMISSION_DENIED - User denied required permission
- OPERATION_FAILED - Operation could not complete
- UNSUPPORTED_DEVICE - Device does not support requested feature
- INVALID_ARGUMENT - Invalid parameters passed to native code
- RESOURCE_NOT_FOUND - Requested file or resource not found

**Error Model**
```dart
class PlatformChannelException implements Exception {
  final String code;
  final String? message;
  final dynamic details;
  
  PlatformChannelException(this.code, [this.message, this.details]);
}
```

All platform channel calls wrapped in try-catch blocks with user-friendly error messages. Errors logged with logger package for debugging while showing simplified messages to users.

## Data Storage Plan

### Storage Allocation

**Shared Preferences**
- Consent state (boolean flag)
- Ad frequency caps (timestamp map)
- User settings (JSON serialized)
- Feature toggles (boolean flags)

**Isar Database**
- Battery history records with timestamp indexing
- Time-series queries for chart generation
- Efficient storage with automatic compression

**Hive Database**
- File scan cache (file metadata)
- Fast key-value lookups
- Duplicate detection hash cache

## Advertising Implementation Details

### Ad Unit Configuration

**Banner Advertisements**
- Position: Bottom of screen, persistent across navigation
- Size: Adaptive banner based on screen width
- Refresh: 60 seconds (AdMob automatic)
- Error handling: Collapse banner on load failure, retry after 30 seconds
- Test mode: Separate test ad units for debug builds

**Optional Full-Screen Advertisements**
- Types: Interstitial and rewarded video
- Frequency cap: Maximum 1 per hour per ad type
- Trigger: Post-cleanup scan completion (when opted in)
- Preloading: Load on app start and after display for instant availability
- Error handling: Silent failure, no retry to avoid user annoyance

### Consent Flow

**Initial Consent**
- Show UMP dialog on first app launch
- Block ad loading until consent obtained
- Store consent state in shared preferences

**Consent Expiration**
- Re-prompt after 12 months
- Check consent status on app start
- Update required message in Settings

**Consent Management**
- "Manage Consent" button in Settings screen
- Ability to review and change choices
- Clear explanation of data usage

## Privacy Policy

### Policy Hosting
Privacy policy source maintained in privacy-policy.md for version control. Generated HTML version hosted at https://yourdomain.com/privacy-policy.html. URL referenced in Play Store listing and accessible via Settings screen link using url_launcher.

### Required Disclosures
- Data collection practices (file metadata, battery history)
- AdMob integration and advertising identifiers
- GDPR compliance for EEA users
- User rights (data deletion, consent withdrawal)
- Contact information for privacy inquiries
- Third-party service disclosures (Google AdMob, analytics if added)

## Testing Strategy

### Unit Tests
- Business logic (file filtering algorithms, size calculations, duplicate detection)
- Data models (serialization, validation)
- Repository methods (mock platform channels)

### Widget Tests
- Critical user flows (cleanup review, file selection, multi-select)
- Error state rendering
- Empty state handling
- Loading indicators

### Integration Tests
- Platform channel mocks for end-to-end flows
- Navigation scenarios
- State persistence across app restarts

### Manual Testing Requirements
Test on minimum 5 physical devices covering:
- Android 11, 12, 13, 14
- OEM variations (Samsung, Pixel, Xiaomi, OnePlus)
- Different screen sizes and densities
- Various battery and storage configurations

### Policy Compliance Checklist
Pre-release audit covering:
- No deceptive claims in UI text
- Proper permission request explanations
- Consent flow completeness
- Privacy policy accuracy
- Ad placement compliance
- Data deletion functionality

## Localization

### Priority Languages
If targeting international markets, implement translations for:
- English (default, en-US)
- Spanish (es-ES) - High Android market share
- French (fr-FR) - European market
- German (de-DE) - European market
- Portuguese (pt-BR) - Brazilian market

### Implementation
- Use flutter_localizations package
- ARB files for translation strings
- intl package for date, number, currency formatting
- RTL layout support for future Arabic/Hebrew localization

## Performance Considerations

### MediaStore Query Optimization
- Pagination with 100 items per page
- Projection limiting to required columns only
- Sort by date descending for recent files view
- MIME type filtering at database level
- Background thread execution for heavy queries

### File Operations
- Isolate spawning for CPU-intensive tasks (hashing, image processing)
- Chunked reading for large files (>10MB)
- Progress indicators for long-running operations
- Cancellation support for user-initiated stops

### Battery History
- Limit stored data points to 1000 maximum
- Automatic cleanup of entries older than 30 days
- Efficient Isar queries with timestamp indexing
- Chart rendering optimization with data point sampling

## Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
1. Scaffold Flutter project with go_router
2. Implement app shell with bottom navigation
3. Create platform channel skeleton contracts
4. Set up Riverpod state management architecture
5. Implement error handling framework

### Phase 2: Consent and Advertising (Week 2-3)
1. Implement UMP consent platform channel (Kotlin)
2. Integrate google_mobile_ads package
3. Create ads_manager.dart service
4. Add banner ad to app shell with collapse behavior
5. Test consent flow with test devices in EEA

### Phase 3: File Finder MVP (Week 3-4)
1. Implement MediaStore platform channel (Kotlin)
2. Create file repository with pagination
3. Build file list UI with search and filters
4. Add multi-select and file operations
5. Test with various file types and sizes

### Phase 4: Cleanup Feature (Week 4-5)
1. Implement cleanup scan logic
2. Create category detection algorithms
3. Build review screen UI
4. Implement delete flow with confirmations
5. Add safety checks and blocked paths

### Phase 5: Battery Information (Week 5-6)
1. Implement BatteryManager platform channel
2. Create live metrics display
3. Build opt-in history tracking
4. Implement WorkManager background task
5. Add fl_chart visualizations

### Phase 6: Process Insights (Week 6-7)
1. Implement UsageStatsManager platform channel
2. Create memory overview display
3. Build app list with actions
4. Implement deep links to system settings
5. Add usage access permission flow

### Phase 7: Settings and Polish (Week 7-8)
1. Build Settings screen with all toggles
2. Implement data deletion functionality
3. Add privacy policy viewer
4. Create diagnostics and about screens
5. Implement full-screen ad opt-in (if desired)

### Phase 8: Testing and Release (Week 8-10)
1. Comprehensive manual testing on 5+ devices
2. Policy compliance audit
3. Play Store listing preparation
4. Beta testing via internal track
5. Production release

## Risk Mitigation

### Device Fragmentation
- Graceful degradation for unsupported features
- Clear messaging about device limitations
- Extensive testing on various OEMs

### Permission Denials
- Feature-specific graceful disabling
- Clear explanations of permission purposes
- No app-breaking permission requirements

### Background Task Reliability
- WorkManager constraints on Android 12+
- Manual fallback options
- Clear user expectations

### Policy Compliance
- Conservative feature set avoiding prohibited claims
- Legal review of UI text
- Regular policy documentation checks

## Success Metrics

### User Engagement
- Daily active users
- Session duration
- Feature adoption rates
- Cleanup scans performed

### Monetization
- Ad impression rates
- Click-through rates
- Effective CPM
- Opt-in rate for full-screen ads

### Quality
- Crash-free rate target: 99.5%
- Average rating target: 4.0+
- Uninstall rate monitoring
- User feedback analysis

## Conclusion

This specification provides a comprehensive blueprint for building a policy-compliant, user-friendly Android utility toolbox. The architecture balances Flutter's rapid development capabilities with native Android integration where necessary. The monetization strategy respects user experience while generating revenue through transparent advertising practices. By focusing on genuine utility and avoiding deceptive claims, the application aims to provide lasting value to users while maintaining compliance with Google Play Store policies.
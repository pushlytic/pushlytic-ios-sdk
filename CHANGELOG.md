# Changelog
All notable changes to the Pushlytic iOS SDK will be documented in this file.

## [0.1.2] - 2025-02-08
### Added
- **Metadata Support for Initial Connection**
  - Added ability to include metadata when opening a connection via `openStream(metadata:)`

## [0.1.1] - 2025-02-02
### Changed
- **Enabled TLS** for all gRPC connections by default
    - Added `configuration.tlsConfiguration` with `.makeClientConfigurationBackedByNIOSSL(...)`

## [0.1.0] - 2024-02-24
### Beta Release
First beta release of Pushlytic iOS SDK! 🎉

### Added
- Initial SDK release with core functionality
- Real-time bidirectional gRPC communication
- User targeting system with IDs, tags, and metadata
- Customizable push notifications with dynamic templates
- Message parsing utilities for type-safe message handling
- Swift Package Manager support
- iOS 13.0+ compatibility

### Developer Experience
- Complete documentation with usage examples
- Type-safe message parsing API
- Thread-safe message handling
- Automatic reconnection handling
- Example app with common implementation patterns

> Note: This is a beta release. Minor version updates (0.x.0) may include breaking changes as we refine the API based on developer feedback.

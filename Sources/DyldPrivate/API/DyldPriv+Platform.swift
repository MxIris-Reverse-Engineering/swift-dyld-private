#if canImport(Darwin)
import Darwin

extension DyldPriv {
    public typealias GetActivePlatformFunction = @convention(c) () -> dyld_platform_t

    private static let getActivePlatformFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivPlatformSymbols.$getActivePlatform,
        as: GetActivePlatformFunction.self
    )

    /// Returns the active platform identifier for the current process.
    ///
    /// The value is a `dyld_platform_t` (UInt32). On a macOS process this is
    /// typically `PLATFORM_MACOS` (1). A non-zero value is expected on any
    /// Apple platform.
    public static func getActivePlatform() -> dyld_platform_t? {
        guard let function = getActivePlatformFunction else { return nil }
        return function()
    }
}
#endif

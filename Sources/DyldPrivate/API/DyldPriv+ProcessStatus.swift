#if canImport(Darwin)
import Darwin

extension DyldPriv {
    public typealias SharedCacheSomeImageOverriddenFunction = @convention(c) () -> Bool
    public typealias ProcessIsRestrictedFunction = @convention(c) () -> Bool

    private static let sharedCacheSomeImageOverriddenFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivProcessStatusSymbols.$sharedCacheSomeImageOverridden,
        as: SharedCacheSomeImageOverriddenFunction.self
    )

    private static let processIsRestrictedFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivProcessStatusSymbols.$processIsRestricted,
        as: ProcessIsRestrictedFunction.self
    )

    /// Returns whether any image in the dyld shared cache has been overridden
    /// by a file on disk (e.g. via root filesystem injection or cache invalidation).
    public static func sharedCacheSomeImageOverridden() -> Bool? {
        guard let function = sharedCacheSomeImageOverriddenFunction else { return nil }
        return function()
    }

    /// Returns whether the current process is running in a restricted environment
    /// (e.g. setuid, entitlements that disable library injection).
    public static func processIsRestricted() -> Bool? {
        guard let function = processIsRestrictedFunction else { return nil }
        return function()
    }
}
#endif

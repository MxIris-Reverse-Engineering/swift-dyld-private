#if canImport(Darwin)
import Darwin

// MARK: - DyldSharedCacheHandle

/// A handle to a dyld_shared_cache_t obtained from the dyld introspection API.
/// The handle is valid only for the lifetime of the enclosing block invocation unless the cache
/// has been pinned via pinMapping().
public struct DyldSharedCacheHandle: @unchecked Sendable {
    /// The raw opaque pointer to the underlying dyld_shared_cache_t.
    public let rawValue: OpaquePointer

    public init(rawValue: OpaquePointer) {
        self.rawValue = rawValue
    }
}
#endif

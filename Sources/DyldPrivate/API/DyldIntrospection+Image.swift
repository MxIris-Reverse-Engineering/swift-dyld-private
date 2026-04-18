#if canImport(Darwin)
import Darwin

// MARK: - DyldImageHandle

/// A handle to a dyld_image_t passed as a block parameter from the dyld introspection API.
/// The handle is only valid for the lifetime of the block invocation unless the backing shared
/// cache is pinned via pinMapping().
public struct DyldImageHandle: @unchecked Sendable {
    /// The raw opaque pointer to the underlying dyld_image_t.
    public let rawValue: OpaquePointer

    public init(rawValue: OpaquePointer) {
        self.rawValue = rawValue
    }
}
#endif

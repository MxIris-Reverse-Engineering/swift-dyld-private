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

// MARK: - Function 12: dyld_for_each_installed_shared_cache

extension DyldIntrospection {
    public typealias ForEachInstalledSharedCacheFunction = @convention(c) (
        @convention(block) (OpaquePointer?) -> Void
    ) -> Void

    private static let forEachInstalledSharedCacheFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldIntrospectionSymbols.$forEachInstalledSharedCache,
        as: ForEachInstalledSharedCacheFunction.self
    )

    /// Iterates over each shared cache provided by the operating system (equivalent to calling
    /// forEachInstalledSharedCache(withSystemPath: "/", …)).
    ///
    /// - Parameter body: Called for each installed shared cache with a `DyldSharedCacheHandle`.
    ///   The handle is valid only for the lifetime of the block.
    public static func forEachInstalledSharedCache(
        _ body: @escaping (_ cache: DyldSharedCacheHandle) -> Void
    ) {
        guard let function = forEachInstalledSharedCacheFunction else {
            return
        }
        let block: @convention(block) (OpaquePointer?) -> Void = { cachePointer in
            guard let cachePointer else { return }
            body(DyldSharedCacheHandle(rawValue: cachePointer))
        }
        function(block)
    }
}

// MARK: - Function 13: dyld_for_each_installed_shared_cache_with_system_path

extension DyldIntrospection {
    public typealias ForEachInstalledSharedCacheWithSystemPathFunction = @convention(c) (
        UnsafePointer<CChar>?,
        @convention(block) (OpaquePointer?) -> Void
    ) -> Void

    private static let forEachInstalledSharedCacheWithSystemPathFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldIntrospectionSymbols.$forEachInstalledSharedCacheWithSystemPath,
        as: ForEachInstalledSharedCacheWithSystemPathFunction.self
    )

    /// Iterates over each shared cache installed at the given root path.
    ///
    /// - Parameters:
    ///   - rootPath: The root path of the system installation (e.g. "/").
    ///   - body: Called for each installed shared cache with a `DyldSharedCacheHandle`.
    ///     The handle is valid only for the lifetime of the block.
    public static func forEachInstalledSharedCache(
        withSystemPath rootPath: String,
        _ body: @escaping (_ cache: DyldSharedCacheHandle) -> Void
    ) {
        guard let function = forEachInstalledSharedCacheWithSystemPathFunction else {
            return
        }
        let block: @convention(block) (OpaquePointer?) -> Void = { cachePointer in
            guard let cachePointer else { return }
            body(DyldSharedCacheHandle(rawValue: cachePointer))
        }
        rootPath.withCString { function($0, block) }
    }
}
#endif

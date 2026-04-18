#if canImport(Darwin)
import Darwin

extension DyldPriv {
    public typealias RegisterForImageLoadsFunction = @convention(c) (
        (@convention(c) (UnsafePointer<mach_header>?, UnsafePointer<CChar>?, Bool) -> Void)?
    ) -> Void

    private static let registerForImageLoadsFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivRegistrationSymbols.$registerForImageLoads,
        as: RegisterForImageLoadsFunction.self
    )

    /// Registers a C function pointer to be called each time an image is loaded.
    ///
    /// During the call to this function, the callback is invoked once for each
    /// currently loaded image. For every subsequent `dlopen`, the callback is
    /// invoked once for each newly loaded image.
    ///
    /// - Parameter callback: A C function pointer called with the image's `mach_header`,
    ///   its file path, and whether the image may be unloaded later.
    ///
    /// WARNING: The callback is called on dyld's internal thread. Registering persistent
    /// callbacks affects the whole process for its lifetime.
    public static func registerForImageLoads(
        _ callback: @convention(c) (UnsafePointer<mach_header>?, UnsafePointer<CChar>?, Bool) -> Void
    ) {
        guard let function = registerForImageLoadsFunction else { return }
        function(callback)
    }

    public typealias RegisterForBulkImageLoadsFunction = @convention(c) (
        (@convention(c) (UInt32, UnsafePointer<UnsafePointer<mach_header>?>?, UnsafePointer<UnsafePointer<CChar>?>?) -> Void)?
    ) -> Void

    private static let registerForBulkImageLoadsFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivRegistrationSymbols.$registerForBulkImageLoads,
        as: RegisterForBulkImageLoadsFunction.self
    )

    /// Registers a C function pointer to be called with bulk notifications of loaded images.
    ///
    /// During the call to this function, the callback is invoked once with all currently
    /// loaded images. For every subsequent `dlopen`, the callback is invoked once with all
    /// newly loaded images in that batch.
    ///
    /// - Parameter callback: A C function pointer called with the image count, an array of
    ///   `mach_header` pointers, and an array of file path strings.
    ///
    /// WARNING: Registering persistent callbacks affects the whole process for its lifetime.
    public static func registerForBulkImageLoads(
        _ callback: @convention(c) (UInt32, UnsafePointer<UnsafePointer<mach_header>?>?, UnsafePointer<UnsafePointer<CChar>?>?) -> Void
    ) {
        guard let function = registerForBulkImageLoadsFunction else { return }
        function(callback)
    }

    public typealias RegisterDriverkitMainFunction = @convention(c) (
        (@convention(c) () -> Void)?
    ) -> Void

    private static let registerDriverkitMainFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivRegistrationSymbols.$registerDriverkitMain,
        as: RegisterDriverkitMainFunction.self
    )

    /// Registers the DriverKit main entry point function.
    ///
    /// DriverKit main executables do not have an LC_MAIN load command. Instead,
    /// DriverKit.framework's initializer calls this function with a pointer that dyld
    /// should invoke instead of using LC_MAIN.
    ///
    /// - Parameter mainCallback: The C function pointer to use as the DriverKit entry point.
    ///
    /// WARNING: This function is specific to DriverKit executables. Calling it from a
    /// non-DriverKit context is unsupported and may cause undefined behavior.
    public static func registerDriverkitMain(
        _ mainCallback: @convention(c) () -> Void
    ) {
        guard let function = registerDriverkitMainFunction else { return }
        function(mainCallback)
    }
}

#endif

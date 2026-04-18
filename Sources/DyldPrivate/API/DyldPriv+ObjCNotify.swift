#if canImport(Darwin)
import Darwin

extension DyldPriv {
    // MARK: - ObjC notify type aliases (v1 signatures from _dyld_objc_notify_register)

    /// The "mapped" callback type used by `_dyld_objc_notify_register`.
    /// Called with the count of newly mapped images, their file paths, and their mach headers.
    public typealias ObjCNotifyMappedFunction = @convention(c) (
        UInt32,
        UnsafePointer<UnsafePointer<CChar>?>?,
        UnsafePointer<UnsafePointer<mach_header>?>?
    ) -> Void

    /// The "init" callback type used by `_dyld_objc_notify_register`.
    /// Called when dyld is about to call initializers for an image.
    public typealias ObjCNotifyInitFunction = @convention(c) (
        UnsafePointer<CChar>?,
        UnsafePointer<mach_header>?
    ) -> Void

    /// The "unmapped" callback type used by `_dyld_objc_notify_register`.
    /// Called when an image is unmapped. Same signature as the init callback.
    public typealias ObjCNotifyUnmappedFunction = @convention(c) (
        UnsafePointer<CChar>?,
        UnsafePointer<mach_header>?
    ) -> Void

    /// The function pointer type for `_dyld_objc_notify_register`.
    public typealias ObjCNotifyRegisterFunction = @convention(c) (
        ObjCNotifyMappedFunction?,
        ObjCNotifyInitFunction?,
        ObjCNotifyUnmappedFunction?
    ) -> Void

    private static let objcNotifyRegisterFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivObjCNotifySymbols.$objcNotifyRegister,
        as: ObjCNotifyRegisterFunction.self
    )

    /// Registers handlers to be called when ObjC images are mapped, initialized, and unmapped.
    ///
    /// - Parameters:
    ///   - mapped: Called with an array of newly-mapped ObjC images.
    ///   - initialize: Called just before dyld calls initializers for an image.
    ///   - unmapped: Called when an image is about to be unmapped.
    ///
    /// WARNING: This is an ObjC-runtime-internal API. Calling it with bogus callbacks
    /// will cause undefined behavior in the ObjC runtime. Only intended for use by the
    /// ObjC runtime itself.
    public static func registerObjCNotify(
        mapped: ObjCNotifyMappedFunction?,
        initialize: ObjCNotifyInitFunction?,
        unmapped: ObjCNotifyUnmappedFunction?
    ) {
        guard let function = objcNotifyRegisterFunction else { return }
        function(mapped, initialize, unmapped)
    }

    // MARK: - _dyld_objc_register_callbacks (versioned struct API)

    /// The function pointer type for `_dyld_objc_register_callbacks`.
    public typealias ObjCRegisterCallbacksFunction = @convention(c) (
        UnsafePointer<_dyld_objc_callbacks>?
    ) -> Void

    private static let objcRegisterCallbacksFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivObjCNotifySymbols.$objcRegisterCallbacks,
        as: ObjCRegisterCallbacksFunction.self
    )

    /// Registers versioned ObjC callbacks using the `_dyld_objc_callbacks` struct.
    ///
    /// The callbacks struct carries a `version` field (2, 3, or 4) that determines
    /// which additional fields are valid. Only the ObjC runtime should call this.
    ///
    /// - Parameter callbacks: A pointer to a versioned `_dyld_objc_callbacks` struct.
    ///
    /// WARNING: This is an ObjC-runtime-internal API. Available in macOS 13+, iOS 16+.
    public static func registerObjCCallbacks(_ callbacks: UnsafePointer<_dyld_objc_callbacks>?) {
        guard let function = objcRegisterCallbacksFunction else { return }
        function(callbacks)
    }
}

#endif

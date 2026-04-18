#if canImport(Darwin)
import Darwin

extension DyldPriv {
    public typealias ImageHeaderContainingAddressFunction = @convention(c) (UnsafeRawPointer?) -> UnsafeRawPointer?
    public typealias ImagePathContainingAddressFunction = @convention(c) (UnsafeRawPointer?) -> UnsafePointer<CChar>?

    private static let imageHeaderContainingAddressFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldSymbols.$imageHeaderContainingAddress,
        as: ImageHeaderContainingAddressFunction.self
    )

    private static let imagePathContainingAddressFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldSymbols.$imagePathContainingAddress,
        as: ImagePathContainingAddressFunction.self
    )

    public static func imageHeader(containing address: UnsafeRawPointer) -> UnsafeRawPointer? {
        guard let function = imageHeaderContainingAddressFunction else {
            return nil
        }
        return function(address)
    }

    public static func imagePath(containing address: UnsafeRawPointer) -> String? {
        guard let function = imagePathContainingAddressFunction,
              let pointer = function(address)
        else {
            return nil
        }
        return String(cString: pointer)
    }

    // MARK: - Image info (7 new functions)

    public typealias LookupSectionInfoFunction = @convention(c) (
        UnsafePointer<mach_header>?,
        _dyld_section_location_info_t?,
        _dyld_section_location_kind
    ) -> _dyld_section_info_result

    public typealias GetImageSlideFunction = @convention(c) (UnsafePointer<mach_header>?) -> Int

    public typealias FindUnwindSectionsFunction = @convention(c) (
        UnsafeMutableRawPointer?,
        UnsafeMutablePointer<dyld_unwind_sections>?
    ) -> Bool

    public typealias GetProgImageHeaderFunction = @convention(c) () -> UnsafePointer<mach_header>?

    public typealias GetDlopenImageHeaderFunction = @convention(c) (UnsafeMutableRawPointer?) -> UnsafePointer<mach_header>?

    public typealias GetImageUUIDFunction = @convention(c) (UnsafePointer<mach_header>?, UnsafeMutablePointer<UInt8>?) -> Bool

    public typealias ImagesForAddressesFunction = @convention(c) (
        UInt32,
        UnsafePointer<UnsafeRawPointer?>?,
        UnsafeMutablePointer<dyld_image_uuid_offset>?
    ) -> Void

    private static let lookupSectionInfoFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivImageSymbols.$lookupSectionInfo,
        as: LookupSectionInfoFunction.self
    )

    private static let getImageSlideFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivImageSymbols.$getImageSlide,
        as: GetImageSlideFunction.self
    )

    private static let findUnwindSectionsFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivImageSymbols.$findUnwindSections,
        as: FindUnwindSectionsFunction.self
    )

    private static let getProgImageHeaderFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivImageSymbols.$getProgImageHeader,
        as: GetProgImageHeaderFunction.self
    )

    private static let getDlopenImageHeaderFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivImageSymbols.$getDlopenImageHeader,
        as: GetDlopenImageHeaderFunction.self
    )

    private static let getImageUUIDFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivImageSymbols.$getImageUUID,
        as: GetImageUUIDFunction.self
    )

    private static let imagesForAddressesFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivImageSymbols.$imagesForAddresses,
        as: ImagesForAddressesFunction.self
    )

    /// Looks up section information for the given Mach-O image, location handle, and section kind.
    ///
    /// - Parameters:
    ///   - header: A pointer to the `mach_header` of the image to query.
    ///   - locationHandle: An opaque handle encoding the section location metadata.
    ///   - kind: The kind of section to look up (one of the `_dyld_section_location_kind` constants).
    /// - Returns: A `_dyld_section_info_result` containing the buffer pointer and size, or `nil`
    ///   if the symbol could not be resolved.
    public static func sectionInfo(
        of header: UnsafePointer<mach_header>,
        locationHandle: _dyld_section_location_info_t?,
        kind: _dyld_section_location_kind
    ) -> _dyld_section_info_result? {
        guard let function = lookupSectionInfoFunction else { return nil }
        return function(header, locationHandle, kind)
    }

    /// Returns the ASLR slide applied to the given Mach-O image.
    ///
    /// - Parameter header: A pointer to the `mach_header` of the image.
    /// - Returns: The slide as a signed integer (may be 0 on a non-ASLR binary),
    ///   or `nil` if the symbol could not be resolved.
    public static func imageSlide(of header: UnsafePointer<mach_header>) -> Int? {
        guard let function = getImageSlideFunction else { return nil }
        return function(header)
    }

    /// Locates the unwind sections for the image containing `address`.
    ///
    /// - Parameters:
    ///   - address: Any address within the image to query (e.g. a code pointer).
    ///   - info: On return, filled with pointers to the DWARF and compact-unwind sections
    ///     if the function returns `true`.
    /// - Returns: `true` if unwind sections were found, `false` if the address is unknown,
    ///   or `nil` if the symbol could not be resolved.
    public static func unwindSections(at address: UnsafeMutableRawPointer, info: inout dyld_unwind_sections) -> Bool? {
        guard let function = findUnwindSectionsFunction else { return nil }
        return withUnsafeMutablePointer(to: &info) { infoPointer in
            function(address, infoPointer)
        }
    }

    /// Returns the `mach_header` of the main executable.
    ///
    /// - Returns: A pointer to the process image header, or `nil` if the symbol could not
    ///   be resolved.
    @available(macOS 11.0, *)
    public static func programImageHeader() -> UnsafePointer<mach_header>? {
        guard let function = getProgImageHeaderFunction else { return nil }
        return function()
    }

    /// Returns the `mach_header` for the image opened by `dlopen`.
    ///
    /// - Parameter handle: The opaque handle returned by `dlopen`.
    /// - Returns: A pointer to the image's Mach-O header, or `nil` if the symbol could not
    ///   be resolved or the handle is invalid.
    @available(macOS 13.0, *)
    public static func dlopenImageHeader(handle: UnsafeMutableRawPointer) -> UnsafePointer<mach_header>? {
        guard let function = getDlopenImageHeaderFunction else { return nil }
        return function(handle)
    }

    /// Retrieves the UUID of the given Mach-O image.
    ///
    /// - Parameters:
    ///   - header: A pointer to the `mach_header` of the image.
    ///   - uuidBuffer: A 16-byte buffer that receives the UUID on success.
    /// - Returns: `true` if the UUID was written into `uuidBuffer`, `false` if the image has no UUID,
    ///   or `nil` if the symbol could not be resolved.
    public static func imageUUID(of header: UnsafePointer<mach_header>, into uuidBuffer: inout uuid_t) -> Bool? {
        guard let function = getImageUUIDFunction else { return nil }
        return withUnsafeMutableBytes(of: &uuidBuffer) { rawBuffer in
            function(header, rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self))
        }
    }

    /// Returns image information (UUID, load address, offset) for each of the given addresses.
    ///
    /// Common usage is with an array of addresses from a stack backtrace.
    /// For each address, dyld fills in the `dyld_image_uuid_offset` with the UUID of the
    /// containing image, the offset within that image, and the image's `mach_header` pointer.
    /// If an address is unknown, all fields are zeroed.
    ///
    /// - Parameters:
    ///   - addresses: An array of raw addresses to query.
    /// - Returns: An array of `dyld_image_uuid_offset` structs in the same order as `addresses`,
    ///   or an empty array if the symbol could not be resolved.
    public static func imagesInfo(forAddresses addresses: [UnsafeRawPointer?]) -> [dyld_image_uuid_offset] {
        guard let function = imagesForAddressesFunction, !addresses.isEmpty else { return [] }
        var results = [dyld_image_uuid_offset](repeating: dyld_image_uuid_offset(), count: addresses.count)
        addresses.withUnsafeBufferPointer { addressBuffer in
            results.withUnsafeMutableBufferPointer { resultBuffer in
                function(UInt32(addresses.count), addressBuffer.baseAddress, resultBuffer.baseAddress)
            }
        }
        return results
    }
}
#endif

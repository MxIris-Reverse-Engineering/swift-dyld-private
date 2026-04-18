#if canImport(Darwin)
import Darwin
import Testing
@testable import DyldPrivate

// Helper: obtain a mach_header* for a well-known loaded image (the image containing dlsym).
private func knownImageHeader() -> UnsafePointer<mach_header>? {
    let rtldDefault = UnsafeMutableRawPointer(bitPattern: -2)
    guard let symbolPointer = dlsym(rtldDefault, "dlsym") else {
        return nil
    }
    guard let rawHeader = DyldPriv.imageHeader(containing: UnsafeRawPointer(symbolPointer)) else {
        return nil
    }
    return rawHeader.assumingMemoryBound(to: mach_header.self)
}

@Test
func sectionInfoResolves() {
    guard let machHeader = knownImageHeader() else {
        Issue.record("could not obtain mach_header for testing")
        return
    }
    // Pass nil locationHandle and a known section kind. Accept either a valid result or an
    // "unknown section" marker {nullptr, -1} / "not in dylib" marker {nullptr, 0}.
    // We only require the symbol resolved (function is non-nil internally).
    let result = DyldPriv.sectionInfo(
        of: machHeader,
        locationHandle: nil,
        kind: _dyld_section_location_text_swift5_protos
    )
    #expect(result != nil)
}

@Test
func imageSlideResolves() {
    guard let machHeader = knownImageHeader() else {
        Issue.record("could not obtain mach_header for testing")
        return
    }
    // Slide is a signed integer; may be 0 for a non-ASLR process, but the call must succeed.
    let slideValue = DyldPriv.imageSlide(of: machHeader)
    #expect(slideValue != nil)
}

@Test
func unwindSectionsResolves() {
    // Use the address of a known function (dlsym itself) as the query address.
    let rtldDefault = UnsafeMutableRawPointer(bitPattern: -2)
    guard let functionAddress = dlsym(rtldDefault, "dlsym") else {
        Issue.record("could not obtain address of dlsym for testing")
        return
    }
    var unwindInfo = dyld_unwind_sections()
    let foundResult = DyldPriv.unwindSections(
        at: functionAddress,
        info: &unwindInfo
    )
    // Accept either true or false — some images may not have unwind sections.
    #expect(foundResult != nil)
}

@Test
func programImageHeaderResolves() {
    let headerPointer = DyldPriv.programImageHeader()
    #expect(headerPointer != nil)
}

@Test
func dlopenImageHeaderResolves() {
    // Open a well-known system library and query its header.
    guard let libraryHandle = dlopen("/usr/lib/libSystem.B.dylib", RTLD_LAZY | RTLD_LOCAL) else {
        Issue.record("could not dlopen /usr/lib/libSystem.B.dylib")
        return
    }
    defer { dlclose(libraryHandle) }
    let headerPointer = DyldPriv.dlopenImageHeader(handle: libraryHandle)
    #expect(headerPointer != nil)
}

@Test
func imageUUIDResolves() {
    guard let machHeader = knownImageHeader() else {
        Issue.record("could not obtain mach_header for testing")
        return
    }
    var uuidBuffer = uuid_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    let successFlag = DyldPriv.imageUUID(of: machHeader, into: &uuidBuffer)
    #expect(successFlag != nil)
    // For a real system dylib the UUID should be nonzero.
    if let successFlag, successFlag {
        let uuidBytes = [
            uuidBuffer.0, uuidBuffer.1, uuidBuffer.2, uuidBuffer.3,
            uuidBuffer.4, uuidBuffer.5, uuidBuffer.6, uuidBuffer.7,
            uuidBuffer.8, uuidBuffer.9, uuidBuffer.10, uuidBuffer.11,
            uuidBuffer.12, uuidBuffer.13, uuidBuffer.14, uuidBuffer.15,
        ]
        let isAllZero = uuidBytes.allSatisfy { $0 == 0 }
        #expect(!isAllZero)
    }
}

@Test
func imagesInfoForAddressesResolves() {
    let rtldDefault = UnsafeMutableRawPointer(bitPattern: -2)
    guard let functionAddress = dlsym(rtldDefault, "dlsym") else {
        Issue.record("could not obtain address of dlsym for testing")
        return
    }
    // Query a single address and verify we get one result back.
    let addressArray: [UnsafeRawPointer?] = [UnsafeRawPointer(functionAddress)]
    let infoResults = DyldPriv.imagesInfo(forAddresses: addressArray)
    #expect(infoResults.count == 1)
    // The image pointer should be non-nil for a known address.
    if let firstResult = infoResults.first {
        #expect(firstResult.image != nil)
    }
}
#endif

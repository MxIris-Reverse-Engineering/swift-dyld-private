#if canImport(Darwin)
import Darwin
import Testing
@testable import DyldPrivate

private func knownSymbolProbe() -> UnsafeRawPointer? {
    let rtldDefault = UnsafeMutableRawPointer(bitPattern: -2)
    guard let pointer = dlsym(rtldDefault, "malloc") else {
        return nil
    }
    return UnsafeRawPointer(pointer)
}

@Test
func sharedCacheFilePathResolves() {
    let path = DyldPriv.sharedCacheFilePath()
    #expect(path != nil)
    #expect(path?.isEmpty == false)
}

@Test
func sharedCacheRangeResolves() {
    let range = DyldPriv.sharedCacheRange()
    #expect(range != nil)
    #expect(range?.size ?? 0 > 0)
}

@Test
func imageHeaderContainingAddressResolves() throws {
    let probe = try #require(knownSymbolProbe())
    let header = DyldPriv.imageHeader(containing: probe)
    #expect(header != nil)
}

@Test
func imagePathContainingAddressResolves() throws {
    let probe = try #require(knownSymbolProbe())
    let path = DyldPriv.imagePath(containing: probe)
    #expect(path != nil)
    #expect(path?.isEmpty == false)
}
#endif

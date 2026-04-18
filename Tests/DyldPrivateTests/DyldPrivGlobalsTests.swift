#if canImport(Darwin)
import Testing
@testable import DyldPrivate

@Test
func nxArgcResolves() {
    // Live-invoke: NXArgc is a libc global; it is always ≥ 1 for a launched process.
    let argumentCount = DyldPriv.nxArgc
    #expect(argumentCount != nil)
    if let argumentCount {
        #expect(argumentCount >= 1)
    }
}
#endif

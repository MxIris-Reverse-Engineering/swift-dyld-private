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

@Test
func nxArgvResolves() {
    // Live-invoke: NXArgv[0] should be a non-null pointer to the program path.
    let argumentVector = DyldPriv.nxArgv
    #expect(argumentVector != nil)
    if let argumentVector {
        // argv[0] (program name) must be non-nil for any normally launched process.
        #expect(argumentVector[0] != nil)
    }
}
#endif

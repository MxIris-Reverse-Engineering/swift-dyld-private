#if canImport(Darwin)
import Testing
@testable import DyldPrivate

@Test
func objcNotifyRegisterResolves() {
    // Resolution-only: calling _dyld_objc_notify_register with bogus callbacks
    // causes undefined behavior in the ObjC runtime.
    let probe = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivObjCNotifySymbols.$objcNotifyRegister,
        as: DyldPriv.ObjCNotifyRegisterFunction.self
    )
    #expect(probe != nil)
}

#endif

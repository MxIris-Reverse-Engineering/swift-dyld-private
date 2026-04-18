#if canImport(Darwin)
import Testing
@testable import DyldPrivate

@Test
func dyldDynamicInterposeResolves() {
    let probe = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivInterposeSymbols.$dynamicInterpose,
        as: DyldPriv.DynamicInterposeFunction.self
    )
    #expect(probe != nil)
}

#endif

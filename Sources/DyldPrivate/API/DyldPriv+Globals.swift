#if canImport(Darwin)
import Darwin

extension DyldPriv {
    /// Returns the process argument count (`argc`).
    ///
    /// This value is loaded from the `NXArgc` libc global variable via `dlsym`.
    /// It equals the number of command-line arguments passed to the process,
    /// including the program name, and is always ≥ 1 for a normally launched process.
    public static var nxArgc: Int32? {
        DyldSymbolResolver.resolveData(
            symbol: ObfuscatedDyldPrivGlobalsSymbols.$nxArgc,
            as: Int32.self
        )?.pointee
    }
}
#endif

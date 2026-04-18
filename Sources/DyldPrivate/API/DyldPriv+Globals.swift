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

    /// Returns the process argument vector (`argv`).
    ///
    /// `NXArgv` is the libc `char**` variable holding the argument array.
    /// `dlsym` returns the address of the `char**` variable (i.e. `char***`);
    /// this property dereferences once to expose the `char**` argv pointer.
    /// Each element at index `i` where `0 <= i < nxArgc` is a null-terminated
    /// C string. Element 0 is the program path.
    public static var nxArgv: UnsafePointer<UnsafeMutablePointer<CChar>?>? {
        guard let triplePointer = DyldSymbolResolver.resolveData(
            symbol: ObfuscatedDyldPrivGlobalsSymbols.$nxArgv,
            as: UnsafeMutablePointer<CChar>?.self
        ) else {
            return nil
        }
        return UnsafePointer(triplePointer)
    }

    /// Returns the process environment variable array (`envp`).
    ///
    /// Loads the POSIX `environ` libc global (`char**` variable holding the environment array)
    /// via `dlsym`. `dlsym` returns the address of the `char**` variable (i.e. `char***`);
    /// this property dereferences once to expose the `char**` pointer.
    /// The array is null-terminated; each entry is a `"KEY=VALUE"` C string.
    public static var processEnv: UnsafePointer<UnsafeMutablePointer<CChar>?>? {
        guard let triplePointer = DyldSymbolResolver.resolveData(
            symbol: ObfuscatedDyldPrivGlobalsSymbols.$processEnvironment,
            as: UnsafeMutablePointer<CChar>?.self
        ) else {
            return nil
        }
        return UnsafePointer(triplePointer)
    }

    /// Returns the program name (basename of `argv[0]`).
    ///
    /// `__progname` is a libc `const char*` variable.
    /// `dlsym` returns the address of the `const char*` (i.e. `const char**`);
    /// this property dereferences once and converts to a Swift `String`.
    public static var progname: String? {
        guard let doublePointer = DyldSymbolResolver.resolveData(
            symbol: ObfuscatedDyldPrivGlobalsSymbols.$progname,
            as: UnsafePointer<CChar>.self
        ) else {
            return nil
        }
        return String(cString: doublePointer.pointee)
    }

    /// Returns the dyld build version string for the current dyld installation.
    ///
    /// The underlying symbol is `dyldVersionString`, exported by dyld as a `const char*`
    /// whose address IS the first byte of the version data (i.e. `dlsym` returns a `char*`
    /// directly, not a `char**`). This property reads the bytes at that address.
    /// Example value: `"@(#)PROGRAM:dyld  PROJECT:dyld-1376.6"`.
    public static var dyldBuildInfo: String? {
        guard let charPointer = DyldSymbolResolver.resolveData(
            symbol: ObfuscatedDyldPrivGlobalsSymbols.$dyldBuildVersionString,
            as: CChar.self
        ) else {
            return nil
        }
        return String(cString: charPointer)
    }
}
#endif

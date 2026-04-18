#if canImport(Darwin)
import Darwin

extension DyldPriv {
    public typealias DynamicInterposeFunction = @convention(c) (
        UnsafePointer<mach_header>?,
        UnsafePointer<dyld_interpose_tuple>?,
        Int
    ) -> Void

    private static let dynamicInterposeFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldPrivInterposeSymbols.$dynamicInterpose,
        as: DynamicInterposeFunction.self
    )

    /// Dynamically interposes functions within the given Mach-O image.
    ///
    /// - Parameters:
    ///   - header: The Mach-O image in which to apply the interpositions.
    ///   - tuples: An array of `dyld_interpose_tuple` values, each specifying a
    ///     `replacee` (original function) and a `replacement` (new function).
    ///
    /// WARNING: This function modifies the runtime behavior of the target image at a low level.
    /// It is intended for use by debugging and profiling tools only. Incorrect use may cause
    /// crashes or undefined behavior.
    public static func dynamicInterpose(
        in header: UnsafePointer<mach_header>,
        tuples: [dyld_interpose_tuple]
    ) {
        guard let function = dynamicInterposeFunction, !tuples.isEmpty else { return }
        tuples.withUnsafeBufferPointer { tupleBuffer in
            function(header, tupleBuffer.baseAddress, tuples.count)
        }
    }
}

#endif

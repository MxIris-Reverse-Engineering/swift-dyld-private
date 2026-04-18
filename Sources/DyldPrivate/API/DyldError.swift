#if canImport(Darwin)
import Darwin

/// Errors that can be returned by DyldPrivate wrapper functions.
public enum DyldError: Error, Sendable {
    /// The requested dyld symbol could not be resolved at runtime.
    case symbolUnavailable(String)
    /// The underlying Mach call failed with the given kern_return_t code.
    case mach(kern_return_t)
    /// The symbol was resolved but the C function returned NULL/0 without setting a kern_return_t.
    /// The associated value is the obfuscated symbol name.
    case operationFailed(String)
}
#endif

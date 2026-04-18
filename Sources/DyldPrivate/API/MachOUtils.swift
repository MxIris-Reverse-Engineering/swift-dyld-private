#if canImport(Darwin)
import Darwin

// MARK: - MachOUtils namespace

/// Swift wrappers for the private mach-o/utils_priv.h functions.
/// All symbol resolution is performed via obfuscated dlsym lookups so that
/// the raw C symbol strings never appear as literals in the compiled object files.
public enum MachOUtils {}

// MARK: - Function 1: macho_dylib_install_name

extension MachOUtils {
    public typealias InstallNameFunction = @convention(c) (UnsafePointer<mach_header>?) -> UnsafePointer<CChar>?

    private static let installNameFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedMachOUtilsSymbols.$machoDylibInstallName,
        as: InstallNameFunction.self
    )

    /// Returns the install name of a dylib image, or nil if the image has no install name
    /// or the underlying function could not be resolved.
    public static func installName(of header: UnsafePointer<mach_header>) -> String? {
        guard let function = installNameFunction,
              let pointer = function(header)
        else {
            return nil
        }
        return String(cString: pointer)
    }
}

// MARK: - Function 2: macho_for_each_dependent_dylib

extension MachOUtils {
    public typealias ForEachDependentDylibFunction = @convention(c) (
        UnsafePointer<mach_header>?,
        Int,
        @convention(block) (UnsafePointer<CChar>?, UnsafePointer<CChar>?, UnsafeMutablePointer<Bool>?) -> Void
    ) -> CInt

    private static let forEachDependentDylibFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedMachOUtilsSymbols.$machoForEachDependentDylib,
        as: ForEachDependentDylibFunction.self
    )

    /// Iterates over all dependent dylibs of an image.
    /// - Parameters:
    ///   - header: The mach header of the image to inspect.
    ///   - mappedSize: Pass 0 when the image is already loaded by dyld.
    ///   - body: Called for each dependent dylib with its load path, attributes string,
    ///           and a stop flag. Set `stop` to `true` to halt iteration.
    /// - Returns: The C function's return code, or -1 if the symbol could not be resolved.
    @discardableResult
    public static func forEachDependentDylib(
        of header: UnsafePointer<mach_header>,
        mappedSize: Int,
        _ body: @escaping (_ loadPath: String, _ attributes: String, _ stop: inout Bool) -> Void
    ) -> CInt {
        guard let function = forEachDependentDylibFunction else {
            return -1
        }
        let block: @convention(block) (UnsafePointer<CChar>?, UnsafePointer<CChar>?, UnsafeMutablePointer<Bool>?) -> Void = { loadPath, attributes, stop in
            guard let loadPath, let attributes, let stop else { return }
            var localStop = stop.pointee
            body(String(cString: loadPath), String(cString: attributes), &localStop)
            stop.pointee = localStop
        }
        return function(header, mappedSize, block)
    }
}
#endif

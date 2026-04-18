#if canImport(Darwin)
import Darwin

// MARK: - DyldProcessInfoHandle

/// A non-owning handle to a dyld_process_info object obtained from _dyld_process_info_create.
/// Callers are responsible for calling release() when done.
public struct DyldProcessInfoHandle: @unchecked Sendable {
    /// The raw dyld_process_info pointer (opaque const pointer).
    public let rawValue: UnsafeRawPointer

    init(rawValue: UnsafeRawPointer) {
        self.rawValue = rawValue
    }
}

// MARK: - DyldProcessInfoNotifyHandle

/// A non-owning handle to a dyld_process_info_notify object obtained from _dyld_process_info_notify.
/// Callers are responsible for calling release() when done.
public struct DyldProcessInfoNotifyHandle: @unchecked Sendable {
    /// The raw dyld_process_info_notify pointer (opaque const pointer).
    public let rawValue: UnsafeRawPointer

    init(rawValue: UnsafeRawPointer) {
        self.rawValue = rawValue
    }
}

// MARK: - DyldProcessInfo namespace

/// Swift wrappers for the private mach-o/dyld_process_info.h functions.
/// All symbol resolution is performed via obfuscated dlsym lookups so that
/// the raw C symbol strings never appear as literals in the compiled object files.
public enum DyldProcessInfo {}

// MARK: - Function 1: _dyld_process_info_create

extension DyldProcessInfo {
    public typealias ProcessInfoCreateFunction = @convention(c) (
        task_t,
        UInt64,
        UnsafeMutablePointer<kern_return_t>?
    ) -> UnsafeRawPointer?

    private static let processInfoCreateFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldProcessInfoSymbols.$processInfoCreate,
        as: ProcessInfoCreateFunction.self
    )

    /// Creates a dyld_process_info snapshot for the specified Mach task.
    ///
    /// - Parameters:
    ///   - task: The Mach task port of the target process.
    ///   - timestamp: Pass 0 to always gather full info. Pass a prior timestamp to skip
    ///                if the image list has not changed since then (returns nil on success).
    /// - Returns: A `.success` containing a `DyldProcessInfoHandle`, or `.failure` with a
    ///            `DyldError` if the symbol could not be resolved or the Mach call failed.
    public static func create(
        task: task_t,
        timestamp: UInt64
    ) -> Result<DyldProcessInfoHandle, DyldError> {
        // Use the obfuscated symbol string as the error description so that the
        // raw C symbol name never appears as a literal in the compiled object file.
        let symbolName = ObfuscatedDyldProcessInfoSymbols.$processInfoCreate
        guard let function = processInfoCreateFunction else {
            return .failure(.symbolUnavailable(symbolName))
        }
        var machError: kern_return_t = KERN_SUCCESS
        let rawHandle = withUnsafeMutablePointer(to: &machError) { pointerToError in
            function(task, timestamp, pointerToError)
        }
        if machError != KERN_SUCCESS {
            return .failure(.mach(machError))
        }
        guard let rawHandle else {
            return .failure(.symbolUnavailable(symbolName))
        }
        return .success(.init(rawValue: rawHandle))
    }
}
#endif

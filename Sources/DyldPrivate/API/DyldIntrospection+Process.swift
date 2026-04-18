#if canImport(Darwin)
import Darwin

// MARK: - DyldProcessHandle

/// A handle to a dyld_process_t obtained from dyld_process_create_for_current_task or
/// dyld_process_create_for_task. The caller is responsible for calling dispose() when done.
public struct DyldProcessHandle: @unchecked Sendable {
    /// The raw opaque pointer to the underlying dyld_process_t.
    public let rawValue: OpaquePointer

    public init(rawValue: OpaquePointer) {
        self.rawValue = rawValue
    }
}

// MARK: - DyldProcessSnapshotHandle

/// A handle to a dyld_process_snapshot_t obtained from dyld_process_snapshot_create_for_process
/// or dyld_process_snapshot_create_from_data. The caller is responsible for calling dispose()
/// when done.
public struct DyldProcessSnapshotHandle: @unchecked Sendable {
    /// The raw opaque pointer to the underlying dyld_process_snapshot_t.
    public let rawValue: OpaquePointer

    public init(rawValue: OpaquePointer) {
        self.rawValue = rawValue
    }
}

// MARK: - DyldIntrospection namespace

/// Swift wrappers for the mach-o/dyld_introspection.h functions.
/// All symbol resolution is performed via obfuscated dlsym lookups so that the raw C symbol
/// strings never appear as literals in the compiled object files.
public enum DyldIntrospection {}

// MARK: - Function 1: dyld_process_create_for_current_task

extension DyldIntrospection {
    public typealias ProcessCreateForCurrentTaskFunction = @convention(c) () -> OpaquePointer?

    private static let processCreateForCurrentTaskFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldIntrospectionSymbols.$processCreateForCurrentTask,
        as: ProcessCreateForCurrentTaskFunction.self
    )

    /// Creates a dyld_process_t for the current process.
    ///
    /// - Returns: A `DyldProcessHandle` wrapping the new process object, or nil if the symbol
    ///   could not be resolved or the call returned NULL.
    public static func createProcessForCurrentTask() -> DyldProcessHandle? {
        guard let function = processCreateForCurrentTaskFunction else {
            return nil
        }
        guard let rawPointer = function() else {
            return nil
        }
        return DyldProcessHandle(rawValue: rawPointer)
    }
}
#endif

#if canImport(Darwin)
import Darwin
import Testing
@testable import DyldPrivate

// MARK: - Helpers

/// Creates a DyldProcessInfoHandle for the current process and returns it.
/// The caller is responsible for calling handle.release() via a defer block.
private func makeCurrentProcessHandle() -> DyldProcessInfoHandle? {
    let result = DyldProcessInfo.create(task: mach_task_self_, timestamp: 0)
    guard case .success(let handle) = result else {
        return nil
    }
    return handle
}

// MARK: - Function 1: _dyld_process_info_create

@Test
func processInfoCreateResolves() {
    let result = DyldProcessInfo.create(task: mach_task_self_, timestamp: 0)
    // The function must resolve and succeed for the current process.
    // Note: release() will be available after wrapping _dyld_process_info_release in the next commit.
    switch result {
    case .success:
        #expect(true, "processInfoCreate resolved and returned a valid handle")
    case .failure(let error):
        Issue.record("processInfoCreate failed: \(error)")
    }
}
#endif

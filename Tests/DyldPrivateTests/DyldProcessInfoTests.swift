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
    switch result {
    case .success(let handle):
        defer { handle.release() }
        #expect(true, "processInfoCreate resolved and returned a valid handle")
    case .failure(let error):
        Issue.record("processInfoCreate failed: \(error)")
    }
}

// MARK: - Function 2: _dyld_process_info_release

@Test
func processInfoReleaseResolves() {
    // Verify that release() can be called without crashing.
    // We create a handle and immediately release it to test the function pointer.
    let result = DyldProcessInfo.create(task: mach_task_self_, timestamp: 0)
    guard case .success(let handle) = result else {
        Issue.record("Could not create processInfo handle for release test")
        return
    }
    // Calling release() is the test — it must not crash.
    handle.release()
    #expect(true, "processInfoRelease resolved and completed without crash")
}

// MARK: - Function 3: _dyld_process_info_retain

@Test
func processInfoRetainResolves() {
    // Verify that retain() can be called without crashing, then balance with release.
    let result = DyldProcessInfo.create(task: mach_task_self_, timestamp: 0)
    guard case .success(let handle) = result else {
        Issue.record("Could not create processInfo handle for retain test")
        return
    }
    // Retain once, then release twice to balance (create + retain = 2 retains).
    handle.retain()
    handle.release()
    handle.release()
    #expect(true, "processInfoRetain resolved and completed without crash")
}
#endif

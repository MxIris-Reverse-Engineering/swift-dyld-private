#if canImport(Darwin)
import Darwin
import Dispatch
import Testing
@testable import DyldPrivate

// MARK: - Function 1: dyld_process_create_for_current_task

@Test
func processCreateForCurrentTaskResolves() {
    let processHandle = DyldIntrospection.createProcessForCurrentTask()
    #expect(processHandle != nil, "createProcessForCurrentTask must resolve and return a valid handle")
    // Note: dispose() will be added to DyldProcessHandle in the dyld_process_dispose commit.
    // The process object is intentionally not disposed here; the test process cleans up on exit.
}
#endif

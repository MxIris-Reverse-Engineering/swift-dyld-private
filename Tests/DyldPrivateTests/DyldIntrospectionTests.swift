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

// MARK: - Function 2: dyld_process_create_for_task

@Test
func processCreateForTaskResolves() {
    // Use mach_task_self_ as the target task (the current task) to verify resolution.
    let result = DyldIntrospection.createProcess(forTask: mach_task_self_)
    switch result {
    case .success:
        #expect(Bool(true), "createProcess(forTask:) resolved and returned a valid handle")
    case .failure(let error):
        Issue.record("createProcess(forTask:) failed: \(error)")
    }
}
#endif

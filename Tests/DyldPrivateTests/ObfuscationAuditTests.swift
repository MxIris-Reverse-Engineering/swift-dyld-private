#if canImport(Darwin)
import Foundation
import Testing

@Test
func noForbiddenSymbolsInBuiltObjects() throws {
    let buildDirectory = try #require(ProcessInfo.processInfo.environment["BUILT_PRODUCTS_DIR"]
        ?? findBuildDirectory())
    let objectPaths = try objectFilePaths(in: buildDirectory)
    #expect(!objectPaths.isEmpty, "no .o files found under \(buildDirectory)")

    for objectPath in objectPaths {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: objectPath))
        for forbidden in ForbiddenSymbolList.names {
            #expect(
                !fileData.contains(Data(forbidden.utf8)),
                "forbidden literal \(forbidden) found in \(objectPath)"
            )
        }
    }
}

private func findBuildDirectory() -> String? {
    let fileManager = FileManager.default
    let workingDirectory = fileManager.currentDirectoryPath
    let candidate = "\(workingDirectory)/.build/arm64-apple-macosx/debug/DyldPrivate.build"
    return fileManager.fileExists(atPath: candidate) ? candidate : nil
}

private func objectFilePaths(in directory: String) throws -> [String] {
    let enumerator = FileManager.default.enumerator(atPath: directory)
    var results: [String] = []
    while let relativePath = enumerator?.nextObject() as? String {
        guard relativePath.hasSuffix(".o") else { continue }
        results.append("\(directory)/\(relativePath)")
    }
    return results
}
#endif

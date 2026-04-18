#if canImport(Darwin)
import Foundation
import Testing

@Test
func noForbiddenSymbolsInBuiltObjects() throws {
    // Resolve build directories: honour BUILT_PRODUCTS_DIR env override first,
    // then fall back to scanning all existing candidate paths (debug + release).
    let buildDirectories: [String]
    if let envOverride = ProcessInfo.processInfo.environment["BUILT_PRODUCTS_DIR"] {
        buildDirectories = [envOverride]
    } else {
        buildDirectories = findBuildDirectories()
    }
    try #require(!buildDirectories.isEmpty, "no DyldPrivate.build directory found")

    var totalObjectsScanned = 0
    for buildDirectory in buildDirectories {
        let objectPaths = try objectFilePaths(in: buildDirectory)
        totalObjectsScanned += objectPaths.count
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
    #expect(totalObjectsScanned > 0, "no .o files found under \(buildDirectories)")
}

// Returns all existing DyldPrivate.build directories (debug first, then release).
private func findBuildDirectories() -> [String] {
    let fileManager = FileManager.default
    let workingDirectory = fileManager.currentDirectoryPath
    let candidates = [
        "\(workingDirectory)/.build/arm64-apple-macosx/debug/DyldPrivate.build",
        "\(workingDirectory)/.build/arm64-apple-macosx/release/DyldPrivate.build",
    ]
    return candidates.filter { fileManager.fileExists(atPath: $0) }
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

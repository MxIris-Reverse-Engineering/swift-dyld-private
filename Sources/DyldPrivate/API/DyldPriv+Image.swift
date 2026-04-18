#if canImport(Darwin)
import Darwin

extension DyldPriv {
    public typealias ImageHeaderContainingAddressFunction = @convention(c) (UnsafeRawPointer?) -> UnsafeRawPointer?
    public typealias ImagePathContainingAddressFunction = @convention(c) (UnsafeRawPointer?) -> UnsafePointer<CChar>?

    private static let imageHeaderContainingAddressFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldSymbols.$imageHeaderContainingAddress,
        as: ImageHeaderContainingAddressFunction.self
    )

    private static let imagePathContainingAddressFunction = DyldSymbolResolver.resolve(
        symbol: ObfuscatedDyldSymbols.$imagePathContainingAddress,
        as: ImagePathContainingAddressFunction.self
    )

    public static func imageHeader(containing address: UnsafeRawPointer) -> UnsafeRawPointer? {
        guard let function = imageHeaderContainingAddressFunction else {
            return nil
        }
        return function(address)
    }

    public static func imagePath(containing address: UnsafeRawPointer) -> String? {
        guard let function = imagePathContainingAddressFunction,
              let pointer = function(address)
        else {
            return nil
        }
        return String(cString: pointer)
    }
}
#endif

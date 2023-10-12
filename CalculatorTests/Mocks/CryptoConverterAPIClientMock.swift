import Foundation
@testable import Calculator
@testable import CryptocurrencyNetworking

final class CryptoConverterAPIClientMock: APIClientProtocol {
    let usdFromBitcoinResult = 26481.3
    func getUSDFromBitcoin() async -> Result<Double, APIError> {
        .success(usdFromBitcoinResult)
    }
}

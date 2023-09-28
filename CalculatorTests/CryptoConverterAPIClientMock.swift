import Foundation
@testable import Calculator

final class CryptoConverterAPIClientMock: APIClient {
    let usdFromBitcoinResult = 26481.3
    func getUSDFromBitcoin() async -> Result<Double, Calculator.APIError> {
        .success(usdFromBitcoinResult)
    }
}

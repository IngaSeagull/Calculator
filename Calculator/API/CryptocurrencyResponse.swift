import Foundation

struct CryptocurrencyResponse: Codable {
    let usd: Double // TODO: rename and do Key
    let btc: Double

    enum CodingKeys: String, CodingKey {
        case usd = "USD"
        case btc = "BTC"
    }
}

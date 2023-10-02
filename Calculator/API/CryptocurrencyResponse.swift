import Foundation

struct CryptocurrencyResponse: Decodable {
    let usd: Double

    enum CodingKeys: String, CodingKey {
        case usd = "USD"
    }
}

enum Cryptocurrency: String {
    case usd = "USD"
    case btc = "BTC"
}

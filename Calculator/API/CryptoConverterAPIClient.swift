import Foundation

protocol APIClient {
    func getUSDFromBitcoin() async -> Result<Double, APIError>
}

final class CryptoConverterAPIClient: APIClient {
    private let session: URLSession
    
    private enum Constants {
        static let endpoint = "https://min-api.cryptocompare.com/data/price"
    }
    
    init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }
    
    func getUSDFromBitcoin() async -> Result<Double, APIError> {
        do {
            return .success(try await getCryptocurrency(Cryptocurrency.btc.rawValue, from: Cryptocurrency.usd.rawValue).usd)
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError(error))
            }
        }
    }
    
    private func getCryptocurrency(_ fsym: String, from tsym: String) async throws -> CryptocurrencyResponse {
        
        guard let url = URL(string: Constants.endpoint) else {
            throw APIError(reason: .invalidURL)
        }
        
        guard let request = CryptocurrencyNetworkProvider.convert(fromCurrency: fsym, toCurrency: tsym, url: url).request else {
            throw APIError(reason: .invalidRequest)
        }
        
        return try await fetchData(request: request)
    }
    
    private func fetchData<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError(reason: .invalidResponse)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError(reason: .invalidData)
        }
    }
}

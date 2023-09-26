import Foundation


protocol NetworkProvider {
    var url: URL { get }
    var params: [URLQueryItem]? { get }
    var headers: [String: String] { get }
    var method: RequestType { get }
}

public enum RequestType: String {
    case get = "GET"
}

extension NetworkProvider {
    var urlComponent: URLComponents {
        guard let params = params, var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return URLComponents()
        }
        components.queryItems = params
        return components
    }
    
    var request: URLRequest? {
        guard let url = urlComponent.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
}

enum DefaultNetworkProvider {
    case search(query: String, url: URL)
}

extension DefaultNetworkProvider: NetworkProvider {
    var url: URL {
        switch self {
        case .search(_, let url):
            return url
        }
    }
    
    var headers: [String : String] {
        ["Accept": "application/vnd.github+json"]
    }
    
    var params: [URLQueryItem]? {
        switch self {
        case .search(let query, _):
            return [URLQueryItem(name: "q", value: query)]
        }
    }
    
    var method: RequestType {
        .get
    }
}

struct APIError: Error {
    enum Reason {
        case connectionFailed
        case invalidRequest
        case invalidResponse
        case invalidURL
        case invalidData
        case unknown
    }
    
    let reason: Reason
    let underlying: Error?
    
    init(reason: Reason, _ underlying: Error? = nil) {
        self.reason = reason
        self.underlying = underlying
    }
    
    init(_ underlying: Error) {
        switch underlying {
        case is APIError:
            self = underlying as! APIError
        case is URLError:
            self.init(reason: .connectionFailed, underlying)
        case is EncodingError:
            self.init(reason: .invalidRequest, underlying)
        case is DecodingError:
            self.init(reason: .invalidResponse, underlying)
        default:
            self.init(reason: .unknown, underlying)
        }
    }
    
    var humanReadableDescription: String {
        switch reason {
        case .connectionFailed:
            return "Looks like connection failed. Please try again later."
        case .invalidResponse:
            return "Response was invalid."
        default:
            return "Something went wrong. Please try again later."
        }
    }
}

final class CryptocompareAPIClient {
    
    private let session: URLSession
    private let endpoint = "https://min-api.cryptocompare.com/data/price"
    
    init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }
    
//    private func get(path: String, query: [String: String] = [:], headers: [String: String] = [:]) async -> Result<Data, APIError> {
//        guard let url = URL(path: path, relativeTo: apiBaseUrl, query: defaultRequestQueryItems.appending(elementsOf: query)) else { return .failure(APIError(reason: .invalidRequest)) }
//        return await get(url: url, headers: headers)
//    }
    
    //{"USD":25802.87}
    func getUSDFromBitcoin() async throws -> CryptoResponse {
        guard let url = URL(string: "https://min-api.cryptocompare.com/data/price") else {
            throw APIError(reason: .invalidURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError(reason: .invalidResponse)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(CryptoResponse.self, from: data)
        } catch {
            throw APIError(reason: .invalidData)
        }
    }
}

struct CryptoResponse: Codable {
    let USD: String
}

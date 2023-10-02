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

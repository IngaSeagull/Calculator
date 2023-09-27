import Foundation

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
            return "Response is invalid."
        case .invalidRequest:
            return "Request is invalid."
        case .invalidURL:
            return "URL is invalid."
        case .invalidData:
            return "Data is invalid."
        case .unknown:
            return "Something went wrong. Please try again later."
        }
    }
}

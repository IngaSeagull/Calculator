import Foundation

enum CryptocurrencyNetworkProvider {
    case convert(fromCurrency: String, toCurrency: String, url: URL)
}

extension CryptocurrencyNetworkProvider: NetworkProvider {
    
    private enum Constants {
        static let fsymParamKey = "fsym"
        static let tsymParamKey = "tsyms"
    }
    
    var url: URL {
        switch self {
        case .convert(_, _, let url):
            return url
        }
    }
    
    var headers: [String : String] {
        [:]
    }
    
    var params: [URLQueryItem]? {
        switch self {
        case .convert(let fsym, let tsym, _):
            return [
                URLQueryItem(name: Constants.fsymParamKey, value: fsym),
                URLQueryItem(name: Constants.tsymParamKey, value: tsym)
            ]
        }
    }
    
    var method: RequestType {
        .get
    }
}

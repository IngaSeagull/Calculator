import Foundation

extension String {
    var double: Double {
        Double(self) ?? 0
    }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(_ args: CVarArg...) -> String {
        String(format: localized, args)
    }
}

import Foundation

extension String {
    var double: Double {
        Double(self) ?? 0
    }
    
//    func localized() -> String.LocalizationValue {
//        String(localized: self)
//    }
}

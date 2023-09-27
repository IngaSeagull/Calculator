import Foundation

extension String {
    var double: Double {
        Double(self) ?? 0
    }
}

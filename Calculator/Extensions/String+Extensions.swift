import Foundation

extension String {
    func toDouble() -> Double {
        Double(self) ?? 0
    }
}

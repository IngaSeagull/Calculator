import Foundation

final class CalculatorOperations {
    
    func performCos(_ degrees: Double) -> Double {
        cos(degrees * .pi / 180.0)
    }
    
    func performSin(_ degrees: Double) -> Double {
        sin(degrees * .pi / 180.0)
    }
    
    func add(_ firstOperand: Double, to secondOperand: Double) -> Double {
        firstOperand + secondOperand
    }
    
    func subtract(_ secondOperand: Double, from firstOperand: Double) -> Double {
        firstOperand - secondOperand
    }
    
    
    func multiply(_ firstOperand: Double, by secondOperand: Double) -> Double {
        firstOperand * secondOperand
    }
    
    func divide(_ firstOperand: Double, by secondOperand: Double) -> Double {
        firstOperand / secondOperand
    }
}

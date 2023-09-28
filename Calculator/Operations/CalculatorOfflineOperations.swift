import Foundation

enum OperationType {
    case add
    case subtract
    case multiply
    case divide
}

protocol CalculatorOfflineOperationsProtocol {
    func perform(operation: OperationType, firstOperand: Double, secondOperand: Double) -> Double
    func performCos(_ degrees: Double) -> Double
    func performSin(_ degrees: Double) -> Double
}

final class CalculatorOfflineOperations: CalculatorOfflineOperationsProtocol {
    
    func perform(operation: OperationType, firstOperand: Double, secondOperand: Double) -> Double {
        switch operation {
        case .add:
            return add(firstOperand, to: secondOperand)
        case .subtract:
            return subtract(secondOperand, from: firstOperand)
        case .multiply:
            return multiply(secondOperand, by: firstOperand)
        case .divide:
            return divide(firstOperand, by: secondOperand)
        }
    }
    
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

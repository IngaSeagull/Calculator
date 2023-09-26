import Foundation

enum OperationType {
    case add
    case subtract
    case multiply
    case divide
}

enum CalculatorButtonType: String {
    case addition = "+"
    case subtraction = "-"
    case multiplication = "*"
    case division = "/"
    case sin
    case cos
    
    case bitcoin = "₿"
    
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    
    case decimal = "."
    
    case equal = "="
    
    case clear = "C"
    case negative = "+/-"
    case delete = "del"
}

extension CalculatorButtonType {
    var operation: OperationType? {
        switch self {
        case .addition:
            return .add
        case .subtraction:
            return .subtract
        case .multiplication:
            return .multiply
        case .division:
            return .divide
        default:
            return nil
        }
    }
    
    var isVisibleInSettings: Bool {
        switch self {
        case .addition, .subtraction, .multiplication, .division, .sin, .cos, .bitcoin:
            return true
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .decimal, .equal, .clear, .negative, .delete:
            return false
        }
    }
}

struct CalculatorButton: Identifiable, Hashable {
    let id = UUID() //?
    let type: CalculatorButtonType
    var isVisible: Bool
    var name: String {
        type.rawValue
    }
}

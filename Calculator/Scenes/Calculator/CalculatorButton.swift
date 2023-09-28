import Foundation

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

enum ButtonDisplayType {
    case dynamic
    case fixed
    case flexible
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
    
    var displayType: ButtonDisplayType {
        switch self {
        case .addition, .subtraction, .multiplication, .division, .sin, .cos, .bitcoin:
            return .dynamic
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .decimal, .equal:
            return .fixed
        case .clear, .negative, .delete:
            return .flexible
        }
    }
    
    var isVisibleInSettings: Bool {
        displayType == .dynamic
    }
}

struct CalculatorButton: Identifiable, Hashable {
    var id: CalculatorButtonType { type }
    let type: CalculatorButtonType
    var isVisible: Bool
    var name: String {
        type.rawValue
    }
}

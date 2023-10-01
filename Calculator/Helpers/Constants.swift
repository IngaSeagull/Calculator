import UIKit

enum Constants {
    static let isDeviceIPhone = UIDevice.current.userInterfaceIdiom == .phone
    static let isDeviceIPad = UIDevice.current.userInterfaceIdiom == .pad
}

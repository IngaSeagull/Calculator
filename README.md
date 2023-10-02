# Calculator

### Author
Inga S

## ℹ️ Description
This project is a calculator with basic operations: addition, subtraction, multiplication, division, sin(degrees), cos(degrees) and an additional operation Bitcoin (Given a bitcoin value, obtain the current dollar value), which requires online connectivity and a call to the Cryptocompare API: https://min-api.cryptocompare.com
This app also has settings, where users can enable or disable operations visibility in UI and also change the color palette of the app. 
The interface works on iPhones and iPads. Both landscape and portrait orientation are supported.
Error handling: All errors display with a simple message to the user and print to the console for debugging purposes.
Internet connectivity: NWPathMonitor (Does not work correctly on the simulator. Test only on the real device)
All user settings are saved via UserDefaults.

## 📲 Tech Stack
SwiftUI + Combine

## Architecture
MVVM + modularity by design

## Structure
### Calculator
    - Helpers: Modifiers, global constants, app builder.
    - Scenes: The source code files for a specific screen.
    - Components: Include reusable UI components
    - Operations: Files related to offline calculator operations.
    - Extensions
    - Internet: Files related to monitoring reachability.
    - API: Files related to communicating with an external API. This could include code for making HTTP requests to a web server, parsing responses, and handling any errors that may occur.
    - Resources: Include image assets, localization files, color assets and Color extension file.

### CalculatorTests
The project includes Unit tests written using the built-in framework XCTest and Mocks

## Design


## Getting started
1. Make sure you have the Xcode version 14.0 or above installed on your computer.
2. Download the Hello World project files from the repository.
3. Run the active scheme.


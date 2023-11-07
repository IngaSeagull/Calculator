# Calculator

### Author
Inga S

## Description
This assignment is made to show my understanding on iOS development, maintenance and architectural decisions.

### Challenges of Assignment

- Basic operations: addition, subtraction, multiplication, division, sin(degrees), cos(degrees)
- Additional operation Bitcoin (Given a bitcoin value, obtain the current dollar value), which requires online connectivity and a call to the [Cryptocompare API](https://min-api.cryptocompare.com)
- Settings, where users can enable or disable operations visibility in UI and also change the color palette of the app. 
- The interface works on iPhones and iPads. Both landscape and portrait orientation are supported.
- Error handling: All errors are displayed with a simple message to the user and printed to the console for debugging.
- Internet connectivity: NWPathMonitor (Does not work correctly on the simulator. Test only on the real device)
- User settings are saved via UserDefaults.
- Min SDK version of iOS15
- Time of completion: ~8 hours

## Tech Stack
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
![IMG_1549](https://github.com/IngaSeagull/Calculator/assets/16067642/a6e1f57d-b1d9-4818-8270-16568e86bdec)


![IMG_1550](https://github.com/IngaSeagull/Calculator/assets/16067642/ce7ffe9d-aab8-4ac7-aa9a-9ede660833ce)


![IMG_1548](https://github.com/IngaSeagull/Calculator/assets/16067642/a15459d4-6e74-4393-9a85-8db34d06d479)


## Getting started
1. Make sure you have the Xcode version 14.0 or above installed on your computer.
2. Download the Hello World project files from the repository.
3. Run the active scheme.


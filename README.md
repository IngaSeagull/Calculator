# Calculator

### Author
Inga S

## ℹ️ Description
This projest is a calculator with a basic operations: addition, subtraction, multiplication, division, sin(degrees), cos(degrees) and an  additional operation Bitcoin (Given a bitcoin value, obtain the current dollar value), which requires online connectivity and a call to the Cryptocompare API: https://min-api.cryptocompare.com
This app also has settings, where user can enable or disable oparations visibility in UI and also change the color palete of the app.
The interface works on iPhones and iPads. Both landscape and portrair orientation are supported.
Error handling: All the errors are displaying with the simple message to the user and printing to the console for debugging purpouses.
Internet Monitoring
Database: UserDefaults

## 📲 Tech Stack

SwiftUI + Combine

## Architecture

 For UI & logic -> MVVM + modularity by design

## Structure
###Calculator
    - Common: Files or resources that are shared across multiple parts of the project. Such as utility classes, global constants, or reusable UI elements.
    - Scenes: The source code files for a specific screen.
    - Components: Include reusable UI components
    - Operations: Files related to offline calculator operations.
    - Extensions
    - Resources: Include image assets, localization files, color assets and Color extension file.
    - Internet: Files related to monitoring reachability.
    - API: Files related to communicating with an external API. This could include code for making HTTP requests to a web server, parsing responses, and handling any errors that may occur.

### CalculatorTests
Include Unit tests written using the built-in framework XCTest and Mocks

## Design


## Getting started
1. Make sure you have the Xcode version 14.0 or above installed on your computer.
2. Download the Hello World project files from the repository.
3. Run the active scheme.


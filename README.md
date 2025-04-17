# N26 Bitcoin Rates Test App

Simple iOS app that shows the current and historical Bitcoin exchange rates using SwiftUI, Combine, and MVVM.

## Features

- Bitcoin prices for the last 14 days (EUR)
- Detail screen with EUR, USD, and GBP for each day
- Auto-updates every 60 seconds
- Loading and error handling
- Unit tests

## Technologies

- SwiftUI
- Combine
- MVVM architecture

## How to Run

1. Open the project in Xcode
2. Run on iOS 16+ device or simulator

## To Run Tests

1. Open the project in Xcode
2. Press Cmd+U

## Notes

- Dates are normalized to UTC to avoid timezone issues
- One average price per day is calculated from multiple values
- Due to lack of time, I chose to use an API I was already familiar with. While this allowed for faster implementation, it may result in slightly less accurate data because of inconsistencies between different endpoints

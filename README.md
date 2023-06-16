<p align="center">
    <a href="https://github.com/pEEcor/swiftui-pager/actions/workflows/ci.yml">
        <img src="https://github.com/pEEcor/swiftui-pager/actions/workflows/ci.yml/badge.svg?branch=main"
    </a>
    <a href="https://github.com/pEEcor/swiftui-pager/tags">
        <img alt="GitHub tag (latest SemVer)"
             src="https://img.shields.io/github/v/tag/pEEcor/swiftui-pager?label=version">
    </a>
    <img src="https://img.shields.io/badge/Swift-5.7-red"
         alt="Swift: 5.7">
    <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-red"
        alt="Platforms: iOS, macOS">
    <a href="https://github.com/pEEcor/swiftui-pager/blob/main/LICENSE">
        <img alt="GitHub" 
             src="https://img.shields.io/github/license/pEEcor/swiftui-pager">
    </a>
</p>

# swiftui-pager

swiftui-pager is a Swift Package that provides a Pager Component written in pure SwiftUI. It comes
with the following features:

- Scrubbing while draging on the page indicator
- Scrolling of dots inside page indicator when too small
- Full freedom to customize the appearance of the page indicator

## Installation via SPM

Add the following to your dependencies:
```Swift
.package(url: "https://github.com/pEEcor/swiftui-pager", from: "0.1.1")
```

## Usage

 ```swift
struct Test: View {
    let numbers = (0 ..< 20)

    var body: some View {
        PagerView(numbers, id: \.self) { number in
            ZStack {
                Color.random
                Text("\(number)")
            }
        }
        .indicator(location: .bottom) { index in
            IndicatorView(count: self.numbers.count, index: index)
                .padding(8)
                .background(Capsule())
                .padding(.top, 8)
        }
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
```

The `indicator` can be attached anywhere in the view hierachy. If a PagerView is embedded in the 
view hierarchy somewhere, it will use this indicator specification.

## Documentation

Either build the docs youself with Xcode `Product -> Build Documentation` or insepct the 
documentation of the `main` branch right [here](https://peecor.github.io/swiftui-pager/main/documentation/swiftuipager/).

# swiftui-pager

swiftui-pager is a Swift Package that provides a Pager Component written in pure SwiftUI. It comes
with the following features:

- Scrubbing while draging on the page indicator
- Scrolling of page indicator when too small
- Full freedom to customize the appearance of the page indicator

## Installation via SPM

Add the following to your dependencies:
```Swift
.package(url: "https://git.xcor.org/pEEcor/swiftui-pager", from: "0.1.0")
```

## Usage

```Swift
struct StyledView: View {
    let data = (0 ..< 10).map { Item(number: $0) }
    
    var body: some View {
        VStack {
            PagerView(data) { element in
                Color.random
            }
            .indicator { indicator in
                indicator
                    .padding(8)
                    .background(Capsule())
                    .padding(.top, 8)
            }
        }
    }
}
```

The `indicator` can be attached anywhere in the view hierachy. If a PagerView is embedded in the 
view hierarchy somewhere, it will use this indicator specification.

## Documentation

Either build the docs youself with Xcode `Product -> Build Documentation` or insepct the online
right here.

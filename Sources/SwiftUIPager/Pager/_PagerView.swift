//
//  PagerView.swift
//
//  Copyright © 2023 Paavo Becker.
//

import SwiftUI

// MARK: - PagerView

/// A container view that shows multiple pages by horizontal scrolling between them.
///
/// The PagerView can scroll arbitrary content. It is initialized with a data collection and a view
/// builder closure that is responsibile for constructing a view for each element of the data
/// collection.
///
/// The PagerView's intrinsic content size is infinite in horizontal direction. In vertical
/// direction the PagerViews just wraps around the content of that is provided by the view builder
/// closure. If that closure constructs views of different height for the elements, then the
/// PagerView presents it's content with a hight of the tallest element.
///
/// The following example shows an example where a Pager with 20 randomly colored Pages is setup.
/// ```swift
/// struct Test: View {
///     let numbers = (0 ..< 20)
///     var body: some View {
///         PagerView(numbers, id: \.self) { number in
///             ZStack {
///                 Color.random
///                 Text("\(number)")
///             }
///         }
///         .indicator(location: .bottom) { index in
///             IndicatorView(count: self.numbers.count, index: index)
///         }
///     }
/// }
///
/// extension Color {
///     static var random: Color {
///         return Color(
///             red: .random(in: 0...1),
///             green: .random(in: 0...1),
///             blue: .random(in: 0...1)
///         )
///     }
///}
/// ```
///
/// - Tip: The use of ``indicator(location:content:)`` enables the possibility to attach a custom
/// page indicator to the pager.
public struct PagerView<
    Data: RandomAccessCollection,
    ID: Hashable,
    EachContent: View
>: View where Data.Element: Identifiable, ID == Data.Element.ID, Data.Index == Int {
    private let internalIndex: State<Int> = State(initialValue: 0)
    private let index: Binding<Int>?

    private let data: Data
    private let configuration: Configuration
    private let content: (Data.Element) -> EachContent
    
    private init(
        _ data: Data,
        selection: Binding<Int>? = nil,
        configuration: Configuration = .default,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent
    )  {
        self.data = data
        self.index = selection
        self.configuration = configuration
        self.content = content
    }
    
    /// Creates a PagerView from a collection of identifiable data
    ///
    /// The PagerView builds a view for each element in the data collection. And allows scrolling
    /// through the pages.
    ///
    /// - Important: All Pages are built up front. There is no lazy initialization of pages.
    ///
    /// - Parameters:
    ///   - data: Source data with identifiable elements.
    ///   - configuration: Configuration options for the PagerView.
    ///   - content: ViewBuilder closure that builds a page given a single element.
    public init(
        _ data: Data,
        selection: Binding<Data.Element>,
        configuration: Configuration = .default,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent
    ) {
        self.init(
            data,
            selection: Binding(
                get: {
                    let selectedIndex = data.firstIndex(where: { selection.id == $0.id }) ?? 0
                    return selectedIndex
                },
                set: {
                    if 0 <= $0 && $0 < data.count {
                        selection.wrappedValue = data[$0]
                    }
                }
            ),
            configuration: configuration,
            content: content
        )
    }
    
    public init(
        _ data: Data,
        configuration: Configuration = .default,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent
    ) {
        self.init(data, selection: nil, configuration: configuration, content: content)
    }
    
    public var body: some View {
        _PagerView(
            data,
            selection: self.index ?? self.internalIndex.projectedValue,
            configuration: configuration,
            content: content
        )
    }
}

private struct _PagerView<
    Data: RandomAccessCollection,
    ID: Hashable,
    EachContent: View
>: View where Data.Element: Identifiable, ID == Data.Element.ID, Data.Index == Int {
    private var index: Binding<Int>

    private let data: Data
    private let configuration: PagerView<Data, ID, EachContent>.Configuration
    private let content: ForEach<Data, ID, EachContent>
    
    init(
        _ data: Data,
        selection: Binding<Int>,
        configuration: PagerView<Data, ID, EachContent>.Configuration = .default,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent
    ) {
        self.data = data
        self.index = selection
        self.configuration = configuration
        self.content = ForEach(data) { content($0) }
    }

    var body: some View {
        IndicatorWrapper(index: self.index, count: self.data.count) {
            Pager(index: self.index, count: self.data.count, axis: self.configuration.axis) {
                self.content
            }
            .contentShape(Rectangle())
            .clipped()
        }
    }
}

private struct IndicatorWrapper<Content: View>: View {
    @Environment(\.indicator)
    private var indicator

    private let index: Binding<Int>
    private let count: Int
    private let content: Content

    init(
        index: Binding<Int>,
        count: Int,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.index = index
        self.count = count
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            if let indicator, indicator.location == .top {
                Indicator(index: self.index, count: self.count, environment: indicator)
            }

            self.content

            if let indicator, indicator.location == .bottom {
                Indicator(index: self.index, count: self.count, environment: indicator)
            }
        }
    }

    private struct Indicator: View {
        let index: Binding<Int>
        let count: Int
        let environment: IndicatorEnvironment

        var body: some View {
            self.environment.builder(
                Binding(
                    get: {
                        self.index.wrappedValue
                    },
                    set: { index, _ in
                        if index >= 0 && index < self.count {
                            self.index.wrappedValue = index
                        }
                    }
                )
            )
        }
    }
}

#if DEBUG
struct PagerView_Previews: PreviewProvider {
    static var previews: some View {
        Content()
    }
    
    struct Content: View {
        let data = [Item(number: 1), Item(number: 2)]
        
        struct Item: Identifiable, Hashable {
            var id: Int { self.number }
            let number: Int
        }
        
        @State var selection: Item = Item(number: 1)
        
        var body: some View {
            VStack {
                Picker(selection: $selection) {
                    ForEach(data) { selection in
                        Text("\(selection.number)")
                            .tag(selection)
                    }
                } label: {
                    Text("Elements")
                }

                content1
                content2
            }
        }
        
        var content1: some View {
            PagerView(data, selection: $selection) { element in
                switch element.number {
                case 1:
                    Color.blue
                case 2:
                    Color.red
                default:
                    Color.green
                }
            }
        }
        
        var content2: some View {
            PagerView(data) { element in
                switch element.number {
                case 1:
                    Color.blue
                case 2:
                    Color.red
                default:
                    Color.green
                }
            }
        }
    }
}
#endif

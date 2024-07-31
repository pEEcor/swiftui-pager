//
//  PagerView.swift
//
//  Copyright © 2023 Paavo Becker.
//

import SwiftUI

// MARK: - PagerView

/// A container view that shows multiple pages by scrolling between them.
///
/// The PagerView can scroll arbitrary content. It is initialized with a data collection and a view
/// builder closure that is responsibile for constructing a view for each element of the data
/// collection.
///
/// ## Sizing behavior
///
/// The PagerView's intrinsic content size is infinite in the scroll direction. In the other
/// direction, the pager takes the size of the largest view which is provided by the viewbuilder
/// for each element.
///
/// ## Example
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
/// }
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
    ) {
        self.data = data
        self.index = selection
        self.configuration = configuration
        self.content = content
    }

    /// Creates a PagerView from a collection of identifiable data.
    ///
    /// The PagerView builds a view for each element in the data collection. And allows scrolling
    /// through the pages.
    ///
    /// - Important: All Pages are built up front. There is no lazy initialization of pages.
    ///
    /// - Parameters:
    ///   - data: Source data with identifiable elements.
    ///   - selection: Binding to the currently selected element.
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
                    if $0 >= 0 && $0 < data.count {
                        selection.wrappedValue = data[$0]
                    }
                }
            ),
            configuration: configuration,
            content: content
        )
    }

    /// Creates a PagerView from a collection of identifiable data.
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
        configuration: Configuration = .default,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent
    ) {
        self.init(data, selection: nil, configuration: configuration, content: content)
    }

    public var body: some View {
        InternalPagerView(
            self.data,
            selection: self.index ?? self.internalIndex.projectedValue,
            configuration: self.configuration,
            content: self.content
        )
    }
}

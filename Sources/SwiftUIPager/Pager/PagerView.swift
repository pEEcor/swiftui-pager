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
/// struct Item: Identifiable {
///     var id: Int { self.number }
///     let number: Int
/// }
///
/// struct Test: View {
///     let data = (0 ..< 20).map { Item(number: $0) }
///
///     var body: some View {
///         PagerView(data) { element {
///             Color.ramdom
///         }
///         .indicator() // Adds default indicator below pager
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
/// - Tip: An indicator can be added and styled using ``indicator(location:style:content:)``.
/// Additionally,
/// the use of ``indicator(location:content:)`` enables the possibility to attach a custom indicator
/// to the pager.
public struct PagerView<
    Data: RandomAccessCollection,
    EachContent: View
>: View where Data.Element: Identifiable {
    @State
    private var index = 0

    private let data: Data
    private let content: ForEach<Data, Data.Element.ID, EachContent>

    /// Creates a PagerView that allows scrolling through a collection
    ///
    /// The PagerView builds a view for each element in the data collection. And allows scrolling
    /// through the pages.
    ///
    /// - Important: All Pages will be built up front. There is no lazy initialization of pages.
    ///
    /// - Parameters:
    ///   - data: Source Data with identifiable elements
    ///   - content: ViewBuilder closure that builds a Page for a single element
    public init(
        _ data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent
    ) where Data.Element: Identifiable {
        self.data = data
        self.content = ForEach(data) { content($0) }
    }

    public var body: some View {
        IndicatorWrapper(index: self.$index, count: self.data.count) {
            Pager(index: self.$index, count: self.data.count) {
                self.content
            }
            .contentShape(Rectangle())
            .clipped()
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
                if case .top = self.indicator.location {
                    Indicator(index: self.index, count: self.count, environment: self.indicator)
                }

                self.content

                if case .bottom = self.indicator.location {
                    Indicator(index: self.index, count: self.count, environment: self.indicator)
                }
            }
        }

        private struct Indicator: View {
            let index: Binding<Int>
            let count: Int
            let environment: IndicatorEnvironment

            var body: some View {
                switch self.environment.kind {
                case let .some(.styled(style, background)):
                    background(
                        IndicatorView(
                            count: self.count,
                            index: self.index,
                            style: style
                        )
                    )
                case let .some(.custom(indicatorBuilder)):
                    indicatorBuilder(
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
                case .none:
                    EmptyView()
                }
            }
        }
    }
}

#if DEBUG
struct PagerView_Previews: PreviewProvider {
    struct Item: Identifiable {
        var id: Int { self.number }
        let number: Int
    }

    static let data = [Item(number: 1), Item(number: 2)]

    static var previews: some View {
        ContentView1()
    }

    struct ContentView1: View {
        var body: some View {
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

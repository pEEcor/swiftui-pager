import SwiftUI

/// A Pager that shows multiple Pages with horizontal scrolling between them
public struct PagerView<
    Data: RandomAccessCollection,
    EachContent: View,
    Footer: View,
    IndicatorTrailingItem: View
>: View where Data.Element: Identifiable {
    @State private var index: Int = 0
    
    @Environment(\.pageIndicator) private var pageIndicator

    private let data: Data
    private let content: ForEach<Data, Data.Element.ID, EachContent>
    private let footer: (Binding<Int>) -> Footer
    private let indicatorTrailingItem: (Binding<Int>) -> IndicatorTrailingItem

    /// Creates a PagerView
    ///
    /// - Important: All Pages will be built up front. There is no lazy initialization of pages
    ///
    /// - Parameters:
    ///   - data: Source Data. A View is built for each element using the content closure
    ///   - content: ViewBuilder closure that builds a Page for a single element
    public init(
        _ data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent,
        @ViewBuilder footer: @escaping (Binding<Int>) -> Footer = { _ in EmptyView() },
        @ViewBuilder indicatorTrailingItem: @escaping (Binding<Int>) -> IndicatorTrailingItem =
            { _ in EmptyView() }
    ) where Data.Element: Identifiable {
        self.data = data
        self.content = ForEach(data) { content($0) }
        self.footer = footer
        self.indicatorTrailingItem = indicatorTrailingItem
    }

    public var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                if case .top = self.pageIndicator.location {
                    self.pageIndicator(width: proxy.size.width)
                }
                
                Pager(pageCount: self.data.count, currentIndex: self.$index) {
                    self.content
                }
                .clipped()
                .contentShape(Rectangle())
                
                if case .bottom = self.pageIndicator.location {
                    self.pageIndicator(width: proxy.size.width)
                }
                
                Spacer(minLength: 0)
                
                self.footer(self.$index)
            }
        }
    }

    @ViewBuilder
    private func pageIndicator(
        width: CGFloat
    ) -> some View {
        switch self.pageIndicator.kind {
        case .default(let style):
            PageIndicatorView(
                count: self.data.count,
                index: self.$index,
                style: style,
                width: width
            ) { index in
                self.indicatorTrailingItem(index)
            }
        case .custom(let pageIndicatorBuilder):
            pageIndicatorBuilder(self.$index)
        }
    }
}



#if DEBUG
    struct Pager_Previews: PreviewProvider {
        struct Item: Identifiable {
            var id: Int { self.number }
            let number: Int
        }

        static let data = [Item(number: 1), Item(number: 2)]

        static var previews: some View {
            ContentView1()
            ContentView2()
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
                } footer: { $index in
                    Text("\(index)")
                } indicatorTrailingItem: { _ in
                    Text("Next")
                }
                .pageIndicator(location: .top)
            }
        }

        struct ContentView2: View {
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
                } footer: { index in
                    Text("\(index.wrappedValue)")
                } indicatorTrailingItem: { $index in
                    Button("Next") {
                        index += 1
                    }
                }
            }
        }
    }
#endif

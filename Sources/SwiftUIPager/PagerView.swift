import SwiftUI

/// A Pager that shows multiple Pages with horizontal scrolling between them
public struct PagerView<
    Data: RandomAccessCollection,
    EachContent: View
>: View where Data.Element: Identifiable {
    @State private var index: Int = 0

    private let data: Data
    private let content: ForEach<Data, Data.Element.ID, EachContent>

    /// Creates a PagerView
    ///
    /// For customization of the PagerView have a look into ``pageIndicator(location:style:)`` and
    /// ``pageIndicator(location:content:)``.
    ///
    /// - Important: All Pages will be built up front. There is no lazy initialization of pages
    ///
    /// - Parameters:
    ///   - data: Source Data. A View is built for each element using the content closure
    ///   - content: ViewBuilder closure that builds a Page for a single element
    public init(
        _ data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent
    ) where Data.Element: Identifiable {
        self.data = data
        self.content = ForEach(data) { content($0) }
    }

    public var body: some View {
        PageIndicatorWrapper(index: self.$index, count: self.data.count) {
            Pager(index: self.$index, count: self.data.count) {
                self.content
            }
            .clipped()
            .contentShape(Rectangle())
            .background(Color.red)
        }
    }
    
    private struct PageIndicatorWrapper<Content: View>: View {
        @Environment(\.pageIndicator) private var pageIndicatorEnvironment
        
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
                if case .top = self.pageIndicatorEnvironment.location {
                    self.pageIndicator
                }
                
                self.content
                
                if case .bottom = self.pageIndicatorEnvironment.location {
                    self.pageIndicator
                }
            }
        }
        
        @ViewBuilder
        private var pageIndicator: some View {
            switch self.pageIndicatorEnvironment.kind {
            case .default(let style):
                PageIndicatorView(
                    count: self.count,
                    index: self.index,
                    style: style
                )
                .padding(.vertical, 8)
            case .custom(let pageIndicatorBuilder):
                pageIndicatorBuilder(self.index)
            }
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
                }
            }
        }
    }
#endif

import SwiftUI

/// The PagerView is a container view that shows multiple pages by horizontal scrolling between them
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
/// ```
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
///     }
/// }
///
/// extension UIColor {
///     static var random: UIColor {
///         return UIColor(
///             red: .random(in: 0...1),
///             green: .random(in: 0...1),
///             blue: .random(in: 0...1),
///             alpha: 1
///         )
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
public struct PagerView<
    Data: RandomAccessCollection,
    EachContent: View
>: View where Data.Element: Identifiable {
    @State private var index: Int = 0

    private let data: Data
    private let content: ForEach<Data, Data.Element.ID, EachContent>

    /// A PagerView that allows scrolling through a collection
    ///
    /// The PagerView builds a view for each element in the data collection. And allows scrolling
    /// through the pages.
    ///
    /// For customization of the PagerView have a look into ``pageIndicator(location:style:)`` and
    /// ``pageIndicator(location:content:)``.
    ///
    /// - Important: All Pages will be built up front. There is no lazy initialization of pages
    ///
    /// - Parameters:
    ///   - data: Source Data with identifiable elements.
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

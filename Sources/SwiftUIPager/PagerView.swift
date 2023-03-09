import SwiftUI

/// Ein Pager, der es ermöglicht mehrere Views in mehreren, horizontal scrollbaren, Pages darzustellen
public struct PagerView<
    Data: RandomAccessCollection,
    EachContent: View,
    Footer: View,
    IndicatorTrailingItem: View
>: View where Data.Element: Identifiable {
    @State private var index: Int = 0

    private let data: Data
    private let content: ForEach<Data, Data.Element.ID, EachContent>
    private let footer: (Binding<Int>) -> Footer
    private let indicatorLocation: IndicatorLocation?
    private let indicatorStyle: PageIndicatorStyle
    private let indicatorTrailingItem: (Binding<Int>) -> IndicatorTrailingItem

    /// Erzeugt einen Pager
    ///
    /// Alle Pages werden initial gebaut. Lazy initialization der einzelnen Pages ist nicht implementiert.
    ///
    /// - Parameters:
    ///   - data: Die Datencollection für die für jedes item eine Page erstellt wird
    ///   - indicator: Position des Pages indicator. Kein Page indicator wenn nil
    ///   - content: ViewBuilder closure welches anhand eines übergebenen Items dessen View baut
    ///   - footer: Ein optionaler Footer der unterhalb des Pagers angezeigt wird. Das ViewBuilder closure erhält ein binding auf
    ///   den Index des Pagers um dieses gegebenenfalls manipulieren zu können.
    public init(
        _ data: Data,
        indicator: IndicatorLocation? = nil,
        indicatorStyle: PageIndicatorStyle = .default,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent,
        @ViewBuilder footer: @escaping (Binding<Int>) -> Footer = { _ in EmptyView() },
        @ViewBuilder indicatorTrailingItem: @escaping (Binding<Int>) -> IndicatorTrailingItem =
            { _ in EmptyView() }
    ) where Data.Element: Identifiable {
        self.data = data
        self.content = ForEach(data) { content($0) }
        self.indicatorLocation = indicator
        self.indicatorStyle = indicatorStyle
        self.footer = footer
        self.indicatorTrailingItem = indicatorTrailingItem
    }

    public var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 8) {
                if case .top = self.indicatorLocation {
                    self.pageIndicator(style: self.indicatorStyle, width: proxy.size.width)
                }
                
                Pager(pageCount: self.data.count, currentIndex: self.$index) {
                    self.content
                }
                .clipped()
                .contentShape(Rectangle())
                
                if case .bottom = self.indicatorLocation {
                    self.pageIndicator(style: self.indicatorStyle, width: proxy.size.width)
                }
                
                Spacer(minLength: 0)
                
                self.footer(self.$index)
            }
        }
    }

    @ViewBuilder
    func pageIndicator(
        style: PageIndicatorStyle,
        width: CGFloat
    ) -> some View {
        PageIndicatorView(
            count: self.data.count,
            index: self.$index,
            style: style,
            width: width
        ) { index in
            self.indicatorTrailingItem(index)
        }
    }
}

public extension PagerView {
    enum IndicatorLocation {
        case top
        case bottom
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
                PagerView(data, indicator: .top) { element in
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
            }
        }

        struct ContentView2: View {
            var body: some View {
                PagerView(data, indicator: .bottom) { element in
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

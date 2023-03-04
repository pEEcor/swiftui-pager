import SwiftUI

struct Pager<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content
    @GestureState private var translation: CGFloat = 0
    
    /// Nicht selbst Verwenden! Verwende stattdessen ``PagerView``
    ///
    /// Baut den tatsächlichen Pager
    ///
    /// - Parameters:
    ///   - pageCount: Anzahl der Seiten
    ///   - currentIndex: Binding des aktuellen indexes
    ///   - content: ViewBuilder closure welches ALLE Page baut
    init(
        pageCount: Int,
        currentIndex: Binding<Int>,
        @ViewBuilder content: () -> Content
    ) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
            .offset(x: self.translation)
            .animation(.interactiveSpring(), value: currentIndex)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture()
                    .updating(self.$translation) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let offset = value.translation.width / geometry.size.width
                        let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                        self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
                    }
            )
        }
    }
}

struct PagerView_Builder_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
    
    struct ContentView: View {
        struct Item: Identifiable {
            var id: Int { self.number }
            let number: Int
        }
        
        let data = [Item(number: 1), Item(number: 2)]
        
        @State private var index = 0
        
        var body: some View {
            Pager(pageCount: data.count, currentIndex: $index) {
                ForEach(data) { element in
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
}

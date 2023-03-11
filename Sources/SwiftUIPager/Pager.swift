import SwiftUI

struct Pager<Content: View>: View {
    @Binding var index: Int
    @GestureState private var translation: CGFloat = 0
    
    let count: Int
    let content: Content
    
    /// Builds the actual pager
    ///
    /// - Parameters:
    ///   - index: Binding des aktuellen indexes
    ///   - count: Anzahl der Seiten
    ///   - content: ViewBuilder closure welches ALLE Page baut
    init(
        index: Binding<Int>,
        count: Int,
        @ViewBuilder content: () -> Content
    ) {
        self.count = count
        self._index = index
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.index) * geometry.size.width)
            .offset(x: self.translation)
            .animation(.interactiveSpring(), value: index)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture()
                    .updating(self.$translation) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let offset = value.translation.width / geometry.size.width
                        let newIndex = (CGFloat(self.index) - offset).rounded()
                        self.index = min(max(Int(newIndex), 0), self.count - 1)
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
            Pager(index: $index, count: data.count) {
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

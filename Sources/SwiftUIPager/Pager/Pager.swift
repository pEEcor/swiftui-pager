//
//  Pager.swift
//
//  Copyright © 2023 Paavo Becker.
//

import SwiftUI

// MARK: - Pager

struct Pager<Content: View>: View {
    @Binding
    var index: Int
    @GestureState
    private var translation: CGFloat = 0

    @State
    private var size: CGSize = .zero

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
        ZStack {
            self.sizeReader
            self.pager
        }
        .onPreferenceChange(PagerSizePreferenceKey.self) { size in
            self.size = size
        }
    }

    @ViewBuilder
    private var sizeReader: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .zero)
            .readSize(key: PagerSizePreferenceKey.self)
    }

    @ViewBuilder
    private var pager: some View {
        HStack(spacing: 0) {
            self.content.frame(width: self.size.width)
        }
        .frame(width: self.size.width, alignment: .leading)
        .offset(x: -CGFloat(self.index) * self.size.width)
        .offset(x: self.translation)
        .animation(.interactiveSpring(), value: self.index)
        .animation(.interactiveSpring(), value: self.translation)
        .gesture(
            DragGesture()
                .updating(self.$translation) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    let offset = value.translation.width / self.size.width
                    let newIndex = (CGFloat(self.index) - offset).rounded()
                    self.index = min(max(Int(newIndex), 0), self.count - 1)
                }
        )
    }
}

// MARK: - PagerSizePreferenceKey

private struct PagerSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
}

#if DEBUG
struct Pager_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }

    struct ContentView: View {
        struct Item: Identifiable {
            var id: Int { self.number }
            let number: Int
        }

        let data = [Item(number: 1), Item(number: 2)]

        @State
        private var index = 0

        var body: some View {
            Pager(index: self.$index, count: self.data.count) {
                ForEach(self.data) { element in
                    switch element.number {
                    case 1:
                        Color.blue
                            .frame(height: 200)
                    case 2:
                        Color.red
                            .frame(height: 400)
                    default:
                        Color.green
                    }
                }
            }
        }
    }
}
#endif

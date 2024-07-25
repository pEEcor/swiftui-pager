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

    private let count: Int
    private let content: Content
    private let axis: Axis

    /// Builds the actual pager.
    ///
    /// - Parameters:
    ///   - index: Binding to the currently selected index.
    ///   - count: Number of pages.
    ///   - axis: The axis along which scrolling should be possible.
    ///   - content: ViewBuilder that builds each page of the pager.
    init(
        index: Binding<Int>,
        count: Int,
        axis: Axis,
        @ViewBuilder content: () -> Content
    ) {
        self.count = count
        self._index = index
        self.content = content()
        self.axis = axis
    }

    var body: some View {
        ZStack {
            self.sizeReader
            self.pager
        }
        .onPreferenceChange(PagerSizePreferenceKey.self) { size in
            print("size: \(size)")
            self.size = size
        }
    }

    @ViewBuilder
    private var sizeReader: some View {
        switch self.axis {
        case .horizontal:
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .zero)
                .readSize(key: PagerSizePreferenceKey.self)
        case .vertical:
            Color.clear
                .frame(maxWidth: .zero, maxHeight: .infinity)
                .readSize(key: PagerSizePreferenceKey.self)
        }
    }

    @ViewBuilder
    private var pager: some View {
        self.container
            .offset(self.offset)
            .animation(.interactiveSpring(), value: self.index)
            .animation(.interactiveSpring(), value: self.translation)
            .gesture(
                DragGesture()
                    .updating(self.$translation) { value, state, _ in
                        state = switch self.axis {
                            case .horizontal:
                                value.translation.width
                            case .vertical:
                                value.translation.height
                        }
                    }
                    .onEnded { value in
                        let offset = switch self.axis {
                        case .horizontal:
                            value.translation.width / self.size.width
                        case .vertical:
                            value.translation.height / self.size.height
                        }
                        
                        let newIndex = (CGFloat(self.index) - offset).rounded()
                        self.index = min(max(Int(newIndex), 0), self.count - 1)
                    }
            )
    }
    
    @ViewBuilder
    private var container: some View {
        switch axis {
        case .horizontal:
            HStack(spacing: 0) {
                self.content
                    .frame(width: self.size.width)
            }
            .frame(width: self.size.width, alignment: .leading)
        case .vertical:
            VStack(spacing: 0) {
                self.content
                    .frame(height: self.size.height)
            }
            .frame(height: self.size.height, alignment: .top)
        }
    }
    
    var offset: CGSize {
        switch self.axis {
        case .horizontal:
            let x = (-CGFloat(self.index) * self.size.width) + self.translation
            return CGSize(width: x, height: 0)
        case .vertical:
            let y = (-CGFloat(self.index) * self.size.height) + self.translation
            return CGSize(width: 0, height: y)
        }
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
        HorizontalPagerView()
        VerticalPagerView()
    }

    struct HorizontalPagerView: View {
        struct Item: Identifiable {
            var id: Int { self.number }
            let number: Int
        }

        let data = [Item(number: 1), Item(number: 2)]

        @State
        private var index = 0

        var body: some View {
            Pager(index: self.$index, count: self.data.count, axis: .horizontal) {
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
    
    struct VerticalPagerView: View {
        struct Item: Identifiable {
            var id: Int { self.number }
            let number: Int
        }

        let data = [Item(number: 1), Item(number: 2), Item(number: 3)]

        @State
        private var index = 0

        var body: some View {
            Pager(index: self.$index, count: self.data.count, axis: .vertical) {
                ForEach(self.data) { element in
                    switch element.number {
                    case 1:
                        Color.blue
                            .frame(width: 200)
                    case 2:
                        Color.red
                            .frame(width: 300)
                    default:
                        Color.green
                    }
                }
            }
        }
    }
}
#endif

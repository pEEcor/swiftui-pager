import SwiftUI

/// PageIndicatorView welcher den index der aktuellen Page mit einem Punkt hervorhebt
///
/// Der Indicator erlaubt Drag Geste auf dem Indicator wodurch automatisch diejenige Index selektiert wird welcher durch die Geste mit
/// dem Finger focussiert wird. Sollte Der PageIndicatorView für alle Indices zu klein sein, wird dieser automatisch die Elemente scrollen
/// wenn die Drag Geste an den Rand des PageIndicators gelangt.
public struct PageIndicatorView: View {

    /// ViewModel für den PageIndicator. Durch die Nutzung von StateObject wird dieses nur 1x beim ersten initialisieren
    /// dieses Views instanziert. Daher sind einige zusäzliche Synchronisationsmechanismen notwendig, für den Fall, dass
    /// dieser View im body einer anderen View mit veränderten Werten erneut aufgerufen wird.
    @StateObject private var viewModel: PageIndicatorViewModel

    private let count: Int
    private let index: Binding<Int>
    private let style: PageIndicatorStyle

    /// A Pageindicator. You probably don't want to use this directly. The PageIndicator of a PagerView is customizable using
    /// dedicated view modifiers. See ``PagerView``. However, the PageIndicator may be decorated with other Views and than
    /// injected into the PagerView as a custom PageIndicator.
    ///
    /// - Parameters:
    ///   - count: Total count of pages
    ///   - index: Binding to index of currently focused page
    ///   - style: Style of the page indicator
    ///   - width: The width that is available to the page indicator
    public init(
        count: Int,
        index: Binding<Int>,
        style: PageIndicatorStyle = .default
    ) {
        self._viewModel = StateObject(
            wrappedValue: PageIndicatorViewModel(
                initialCount: count,
                style: style
            )
        )
        self.count = count
        self.index = index
        self.style = style
    }

    public var body: some View {
        HStack {
            self.pageIndicator()
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.clear
                .readSize(key: PageIndicatorSizePreferenceKey.self)
        )
        .onPreferenceChange(PageIndicatorSizePreferenceKey.self) {
            viewModel.setWidth($0.width)
        }
        // Propagate specific changes to view model manually since it's held in a state object
        .onChange(of: self.count, perform: self.viewModel.setCount(_:))
        .onChange(of: self.style, perform: self.viewModel.setStyle(_:))
    }

    @ViewBuilder
    private func pageIndicator() -> some View {
        HStack(spacing: 10) {
            HStack(spacing: self.viewModel.style.spacing) {
                ForEach(0 ..< self.viewModel.count, id: \.self) { index in
                    Indicator(style: self.style(for: index)) {
                        self.viewModel.setIndex(index)
                    }
                    .foregroundColor(self.foregroundColor(for: index))
                }
            }
            .readSize(key: PageIndicatorCollectionSizePreferenceKey.self)
            .offset(
                CGSize(
                    width: self.viewModel.baseOffset + self.viewModel.offset,
                    height: 0
                )
            )
        }
        .onPreferenceChange(PageIndicatorCollectionSizePreferenceKey.self) { size in
            self.viewModel.setCollectionSize(size: size)
        }
        // Propagiere Index Änderungen von ViewModel über Binding zum Parent View
        .onReceive(self.viewModel.$index) { index in
            self.index.wrappedValue = index
        }
        // Propagiere Index Änderungen von Binding ans ViewModel
        .onChange(of: self.index.wrappedValue, perform: self.viewModel.setIndex(_:))
        .frame(width: self.viewModel.indicatorWidth)
        .contentShape(Capsule())
        .clipped()
        .gesture(
            DragGesture(minimumDistance: 1)
                .onChanged() { value in
                    // Process gesture
                    self.viewModel.handleTranslation(
                        startLocation: value.startLocation,
                        translation: value.translation
                    )
                }
                .onEnded { _ in
                    self.viewModel.handleDragEnding()
                }
        )
    }

    private func foregroundColor(for index: Int) -> Color {
        if index == self.viewModel.index {
            return self.viewModel.style.focused.color
        } else {
            return self.viewModel.style.plain.color
        }
    }
    
    private func style(for index: Int) -> PageIndicatorDotStyle {
        if index == self.viewModel.index {
            return self.viewModel.style.focused
        } else {
            return self.viewModel.style.plain
        }
    }
    
    struct Indicator: View {
        let style: PageIndicatorDotStyle
        let onTap: () -> Void
        
        init(
            style: PageIndicatorDotStyle,
            onTap: @escaping () -> Void
        ) {
            self.style = style
            self.onTap = onTap
        }
        
        var body: some View {
            switch self.style.shape {
            case .circle(radius: let radius):
                Circle()
                    .frame(
                        width: radius,
                        height: radius
                    )
                    .onTapGesture(perform: self.onTap)
            case .rect(size: let size):
                Rectangle()
                    .frame(
                        width: size.width,
                        height: size.height
                    )
                    .onTapGesture(perform: self.onTap)
            }
        }
    }
}

struct PageIndicatorSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
}

struct PageIndicatorCollectionSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
}

struct PageIndicatorTrailingViewSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
}

#if DEBUG
    struct PagerIndicator_Previews: PreviewProvider {
        static var previews: some View {
            Content()
                .padding(8)
        }

        struct Content: View {
            @State private var index = 3

            var body: some View {
                VStack(spacing: 64) {
                    PageIndicatorView(
                        count: 20,
                        index: $index,
                        style: PageIndicatorStyle(
                            plainStyle: .circle(radius: 10, color: .gray),
                            focusedStyle: .circle(radius: 20),
                            spacing: 10
                        )
                    )
                    .frame(width: 100)
                }
                .background(Color.green)
            }
        }
    }
#endif

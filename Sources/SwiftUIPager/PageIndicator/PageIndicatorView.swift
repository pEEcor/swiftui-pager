import SwiftUI

/// A PageIndicator that shows a visual representation of which page is currenlty focused by a
/// pager.
///
/// The PageIndicatorView allows multiple interactions that modify the state of a Pager. Usually, a
/// PageIndicator is showing simple dots, each representing a Page of the associated Pager.
/// Selecting such a dot focuses the Page in the Pager. Additionally, the PageIndicatorView enables
/// scrolling of the dots when the Pager has too much content for the PageIndicatorView to show a
/// dot for each page. In this case the dots can be scrolled when performing a drag gesture that
/// exceeds the PageIndicatorView's bounds.
///
/// The PageIndicatorView is independent from any Pager, it can be used for any kind of page
/// representation through it's index binding. However, if used with the ``PagerView`` that comes
/// with this library, there are dedicated view modifiers, that provide convienient access to
/// customize the PageIndicator.
///
/// The page indicator can be styled using ``pageIndicator(location:style:background:)`` if
/// additional customization is required. If you need to inject a completely custom page indicator,
/// there is also ``pageIndicator(location:content:)``.
public struct PageIndicatorView: View {

    // View model for the page indicator. By using a state object, the view model will be
    // instatiated exactly once. This allows this view to manage its view model by itself, without
    // any user of the view knowing that this view uses a view model. However subsequent calls to
    // the view's initializer will not update the view model. Specifically count and style,
    // therefore additional onChange modifiers are employed to propagate such changes into the view
    // model.
    @StateObject private var viewModel: PageIndicatorViewModel

    private let count: Int
    private let index: Binding<Int>
    private let style: PageIndicatorStyle

    /// Creates PageIndicatorView, typlically for manual customization.
    ///
    /// You probably don't want to use this directly. The PageIndicator of a PagerView is
    /// customizable using a dedicated view modifier. See ``pageIndicator(location:style:)``.
    /// However, the PageIndicator may be decorated with other Views and than injected into the
    /// PagerView as a custom PageIndicator.
    ///
    /// - Parameters:
    ///   - count: Total count of pages
    ///   - index: Binding to index of currently focused page
    ///   - style: Style of the page indicator
    public init(
        count: Int,
        index: Binding<Int>,
        style: PageIndicatorStyle = .default
    ) {
        self._viewModel = StateObject(
            wrappedValue: PageIndicatorViewModel(
                count: count,
                style: style
            )
        )
        
        self.count = count
        self.index = index
        self.style = style
    }

    public var body: some View {
        self.pageIndicator()
            .readSize(key: PageIndicatorSizePreferenceKey.self)
            .onPreferenceChange(PageIndicatorSizePreferenceKey.self) { size in
                self.viewModel.setWidth(size.width)
            }
            // Propagate specific changes to view model manually since it's held in a state object
            .onChange(of: self.count, perform: self.viewModel.setCount(_:))
            // Propagate style changes to view model
            .onChange(of: self.style, perform: self.viewModel.setStyle(_:))
            // Propagate index change to view model
            .onChange(of: self.index.wrappedValue, perform: self.viewModel.setIndex(_:))
    }
    
    @ViewBuilder
    private func pageIndicator() -> some View {
        GeometryReader { proxy in
            HStack(spacing: self.viewModel.style.spacing) {
                ForEach(0 ..< self.viewModel.dots.count, id: \.self) { index in
                    Indicator(style: self.style(for: index)) {
                        self.viewModel.setIndex(index)
                    }
                    .foregroundColor(self.foregroundColor(for: index))
                }
            }
        }
        .frame(
            maxWidth: self.viewModel.dots.width,
            maxHeight: self.viewModel.dots.height
        )
        .offset(
            CGSize(
                width: self.viewModel.dots.window.offset,
                height: 0
            )
        )
        // Propagate index changes from view model via binding to parent
        .onReceive(self.viewModel.$dots) { index in
            guard let index = self.viewModel.dots.selectedIndex else {
                return
            }
            self.index.wrappedValue = index
        }
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
        if index == self.viewModel.dots.selectedIndex {
            return self.viewModel.style.focused.color
        } else {
            return self.viewModel.style.plain.color
        }
    }
    
    private func style(for index: Int) -> PageIndicatorDotStyle {
        if index == self.viewModel.dots.selectedIndex {
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

private struct PageIndicatorSizePreferenceKey: PreferenceKey {
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
                        count: 10,
                        index: $index,
                        style: .default
                    )
                    .padding(8)
                    .background(
                        Capsule()
                            .foregroundColor(Color(uiColor: .systemGray2))
                            .opacity(0.5)
                    )
                    
                    PageIndicatorView(
                        count: 10,
                        index: $index,
                        style: PageIndicatorStyle(
                            plainStyle: .circle(radius: 30, color: Color(uiColor: .systemGray)),
                            focusedStyle: .circle(radius: 60),
                            spacing: 10
                        )
                    )
                    .frame(width: 250)
                    .background(Color.green)
                }
            }
        }
    }
#endif

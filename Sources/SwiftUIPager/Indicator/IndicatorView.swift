import SwiftUI

/// Indicator that shows a horizontal collection of dots.
///
/// The IndicatorView takes a binding that reflects the currently active dot. Modifing this binding
/// will automatically select the respective dot inside the indicator. Likewise the binding is
/// adjusted when the indicator is used to change the selected dot. The selection can be changed by
/// simple tap gestures to the desired dot or by scrubbing the collection with a drag gesture.
///
/// The IndicatorView adjusts its size to the amount of dots. If the indicator cannot fit all dots,
/// the collection starts scrolling when scrubbing past the edges of the Indicator.
///
/// The IndicatorView is independent from any Pager, it can be used for any kind of page
/// representation through it's index binding. However, if used with the ``PagerView`` that comes
/// with this library, there are dedicated view modifiers, that provide convienient access to
/// customize the PageIndicator.
///
/// - Note: Apple encourages to think twice when deciding which UI Element to use in its Human
/// Interface Guidelines. In this context an Indicator like this might not be the best tool when
/// indicating the current selection of an element in a collection with many elements (which would
/// required too much scrolling).

public struct IndicatorView: View {

    // View model for the page indicator. By using a state object, the view model will be
    // instatiated exactly once. This allows this view to manage its view model by itself, without
    // any user of the view knowing that this view uses a view model. However subsequent calls to
    // the view's initializer will not update the view model. Specifically count and style,
    // therefore additional onChange modifiers are employed to propagate such changes into the view
    // model.
    @StateObject private var viewModel: IndicatorViewModel

    private let count: Int
    private let index: Binding<Int>
    private let style: IndicatorStyle

    /// Creates IndicatorView
    ///
    /// - Parameters:
    ///   - count: Total count of pages
    ///   - index: Binding to index of currently focused page
    ///   - style: Optional style of the page indicator, defaults to a default style
    public init(
        count: Int,
        index: Binding<Int>,
        style: IndicatorStyle = .default
    ) {
        self._viewModel = StateObject(
            wrappedValue: IndicatorViewModel(
                count: count,
                style: style
            )
        )
        
        self.count = count
        self.index = index
        self.style = style
    }

    public var body: some View {
        self.indicator()
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
    private func indicator() -> some View {
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
                width: -self.viewModel.dots.window.offset,
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
    
    private func style(for index: Int) -> DotStyle {
        if index == self.viewModel.dots.selectedIndex {
            return self.viewModel.style.focused
        } else {
            return self.viewModel.style.plain
        }
    }
    
    struct Indicator: View {
        let style: DotStyle
        let onTap: () -> Void
        
        init(
            style: DotStyle,
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
                    IndicatorView(
                        count: 10,
                        index: $index,
                        style: .default
                    )
                    .padding(8)
                    .background(
                        Capsule()
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    )
                    
                    IndicatorView(
                        count: 10,
                        index: $index,
                        style: IndicatorStyle(
                            plainStyle: .circle(
                                radius: 30,
                                color: .red
                            ),
                            focusedStyle: .circle(
                                radius: 60,
                                color: .blue
                            ),
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

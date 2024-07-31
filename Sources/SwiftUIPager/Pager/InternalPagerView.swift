//
//  InternalPagerView.swift
//
//  Copyright © 2023 Paavo Becker.
//

import SwiftUI

// MARK: - InternalPagerView

struct InternalPagerView<
    Data: RandomAccessCollection,
    ID: Hashable,
    EachContent: View
>: View where Data.Element: Identifiable, ID == Data.Element.ID, Data.Index == Int {
    private var index: Binding<Int>

    private let data: Data
    private let configuration: PagerView<Data, ID, EachContent>.Configuration
    private let content: ForEach<Data, ID, EachContent>

    init(
        _ data: Data,
        selection: Binding<Int>,
        configuration: PagerView<Data, ID, EachContent>.Configuration = .default,
        @ViewBuilder content: @escaping (Data.Element) -> EachContent
    ) {
        self.data = data
        self.index = selection
        self.configuration = configuration
        self.content = ForEach(data) { content($0) }
    }

    var body: some View {
        IndicatorWrapper(index: self.index, count: self.data.count) {
            Pager(index: self.index, count: self.data.count, axis: self.configuration.axis) {
                self.content
            }
            .contentShape(Rectangle())
            .clipped()
        }
    }
}

// MARK: - IndicatorWrapper

private struct IndicatorWrapper<Content: View>: View {
    @Environment(\.indicator)
    private var indicator

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
            if let indicator, indicator.location == .top {
                Indicator(index: self.index, count: self.count, environment: indicator)
            }

            self.content

            if let indicator, indicator.location == .bottom {
                Indicator(index: self.index, count: self.count, environment: indicator)
            }
        }
    }

    private struct Indicator: View {
        let index: Binding<Int>
        let count: Int
        let environment: IndicatorEnvironment

        var body: some View {
            self.environment.builder(
                Binding(
                    get: {
                        self.index.wrappedValue
                    },
                    set: { index, _ in
                        if index >= 0 && index < self.count {
                            self.index.wrappedValue = index
                        }
                    }
                )
            )
        }
    }
}

#if DEBUG
struct PagerView_Previews: PreviewProvider {
    static var previews: some View {
        Content()
    }

    struct Content: View {
        let data = [Item(number: 1), Item(number: 2)]

        struct Item: Identifiable, Hashable {
            var id: Int { self.number }
            let number: Int
        }

        @State
        var selection = Item(number: 1)

        var body: some View {
            VStack {
                Picker(selection: self.$selection) {
                    ForEach(self.data) { selection in
                        Text("\(selection.number)")
                            .tag(selection)
                    }
                } label: {
                    Text("Elements")
                }

                self.content1
                self.content2
            }
        }

        var content1: some View {
            PagerView(self.data, selection: self.$selection) { element in
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

        var content2: some View {
            PagerView(self.data) { element in
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

//
//  ContentView.swift
//  swiftui-pager-app
//
//  Created by Paavo Becker on 04.03.23.
//

import SwiftUI
import SwiftUIPager

struct ContentView: View {
    struct Item: Identifiable {
        var id: Int { self.number }
        let number: Int
    }

    let data = [Item(number: 1), Item(number: 2)]

    var body: some View {
        PagerView(
            data,
            indicator: .bottom,
            indicatorStyling: .default) { element in
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

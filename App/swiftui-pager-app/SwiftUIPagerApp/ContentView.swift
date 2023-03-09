//
//  ContentView.swift
//  swiftui-pager-app
//
//  Created by Paavo Becker on 04.03.23.
//

import SwiftUI
import SwiftUIPager

struct ContentView: View {
    static let circles = PageIndicatorStyle(
        plainStyle: .circle(radius: 20, color: .gray),
        focusedStyle: .circle(radius: 30),
        spacing: 20,
        width: .constant(250)
    )
    
    static let rects = PageIndicatorStyle(
        plainStyle: .rect(size: CGSize(width: 20, height: 20), color: .gray),
        focusedStyle: .rect(size: CGSize(width: 80, height: 20)),
        spacing: 20,
        width: .constant(250)
    )
    
    struct Item: Identifiable {
        var id: Int { self.number }
        let number: Int
    }

    let data = (0 ..< 20).map { Item(number: $0) }

    var body: some View {
        PagerView(
            data,
            indicator: .bottom,
            indicatorStyle: Self.rects
        ) { element in
            Color.random
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1
        )
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

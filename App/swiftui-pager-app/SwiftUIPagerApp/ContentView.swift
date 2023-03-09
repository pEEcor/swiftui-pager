//
//  ContentView.swift
//  swiftui-pager-app
//
//  Created by Paavo Becker on 04.03.23.
//

import SwiftUI
import SwiftUIPager

let circles = PageIndicatorStyle(
    plainStyle: .circle(radius: 20, color: .gray),
    focusedStyle: .circle(radius: 30),
    spacing: 20,
    width: .constant(250)
)

let rects = PageIndicatorStyle(
    plainStyle: .rect(size: CGSize(width: 20, height: 20), color: .gray),
    focusedStyle: .rect(size: CGSize(width: 80, height: 20)),
    spacing: 20,
    width: .constant(250)
)

struct Item: Identifiable {
    var id: Int { self.number }
    let number: Int
}

struct ContentView: View {
    @State var style: PageIndicatorStyle
    
    let data = (0 ..< 20).map { Item(number: $0) }
    
    init(style: PageIndicatorStyle = rects) {
        self.style = style
    }

    var body: some View {
        VStack {
            Menu("Styles") {
                Button("Circles") {
                    self.style = circles
                }
                
                Button("Rects") {
                    self.style = rects
                }
            }
            
            PagerView(data) { element in
                Color.random
            }
            .pageIndicator(location: .top) { $index in
                HStack {
                    Button("Back", action: { index -= 1 })
                    Text("\(index)")
                    Button("Forward", action: { index += 1 })
                }
            }
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

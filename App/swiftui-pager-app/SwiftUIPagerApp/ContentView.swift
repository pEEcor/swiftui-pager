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
    focusedStyle: .circle(radius: 40),
    spacing: 20
)

let rects = PageIndicatorStyle(
    plainStyle: .rect(size: CGSize(width: 20, height: 20), color: .gray),
    focusedStyle: .rect(size: CGSize(width: 80, height: 20)),
    spacing: 20
)

struct Item: Identifiable {
    var id: Int { self.number }
    let number: Int
}

struct DemoView: View {
    enum Scenario: Int, Hashable, CaseIterable, Identifiable {
        case styled
        case custom
        
        var id: Self { self }
    }
    
    @State private var scenario: Scenario = .styled
    
    var body: some View {
        PagerView(Scenario.allCases) { scenario in
            switch scenario {
            case .styled:
                StyledView()
            case .custom:
                CustomView()
            }
        }
        .pageIndicator(location: .top) { $index in
            Picker(selection: $index) {
                Text("Styled").tag(0)
                Text("Custom").tag(1)
            } label: {
                Text("Label")
            }
            .pickerStyle(.segmented)
            .padding()
        }
    }
}

struct StyledView: View {
    @State var style: PageIndicatorStyle? = circles
    @State var location: PageIndicatorLocation = .bottom
    
    let data = (0 ..< 20).map { Item(number: $0) }
    
    var body: some View {
        VStack {
            PagerView(data) { element in
                Color.random
            }
            .pageIndicator(location: self.location, style: self.style) { indicator in
                indicator
                    .padding(8)
                    .background(Capsule())
                    .padding(.top, 8)
            }
            .padding()
            
            HStack {
                Menu("Location") {
                    Button("Top") {
                        self.location = .top
                    }
                    
                    Button("Bottom") {
                        self.location = .bottom
                    }
                }
                
                Menu("Styles") {
                    Button("Default") {
                        self.style = .default
                    }
                    
                    Button("Circles") {
                        self.style = circles
                    }
                    
                    Button("Rects") {
                        self.style = rects
                    }
                    
                    Button("None") {
                        self.style = nil
                    }
                }
            }
        }
    }
}

struct CustomView: View {
    
    let data = (0 ..< 10).map { Item(number: $0) }
    
    var body: some View {
        PagerView(data) { element in
            Color.random
        }
        .padding(.top, 300)
        .pageIndicator { $index in
            HStack {
                Button("Previous") {
                    index -= 1
                }
                
                Spacer()
                
                Button("Next") {
                    index += 1
                }
            }
            .padding(8)
        }
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DemoView()
        }
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

//
//  View+ReadSize.swift
//  
//
//  Created by Paavo Becker on 11.03.23.
//

import SwiftUI

extension View {
    func readSize<T: PreferenceKey>(
        key: T.Type
    ) -> some View where T.Value == CGSize {
        self.background(
            GeometryReader(
                content: { proxy in
                    Color.clear.preference(
                        key: key.self,
                        value: proxy.size
                    )
                }
            )
        )
    }
}

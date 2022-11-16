//
//  CountView.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/7/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import Foundation
import SwiftUI

struct CountView: View {
    var count: Int

    var type: String
    
    var leftDivider: Bool = false
    
    @ViewBuilder
    var body: some View {
        if count == 0 {
            EmptyView()
        } else {
            VStack {
                Text("\(count)")
                    .font(.largeTitle.weight(.semibold))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                Text("\(type)")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: leftDivider == true ? 48 : 0))
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .foregroundColor(.accentColor)
                    .frame(width: leftDivider == true ? 2 : 0, height: nil, alignment: .trailing),
                alignment: .trailing
            )
        }
    }
}

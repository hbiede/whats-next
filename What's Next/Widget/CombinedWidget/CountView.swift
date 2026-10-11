//
//  CountView.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 11/7/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

struct CountView: View {
    var count: Int

    var type: RecType

    var leftDivider: Bool = false

    @ViewBuilder
    var body: some View {
        if count == 0 {
            EmptyView()
        } else {
            VStack {
                Text(count, format: .number)
                    .font(.largeTitle.weight(.semibold))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                Image(systemName: type.systemImage)
                    .font(.title2)
                    .foregroundStyle(Color.appAccent)
                    .widgetAccentable()
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: leftDivider == true ? 48 : 0))
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .foregroundStyle(Color.appAccent)
                    .frame(width: leftDivider == true ? 2 : 0, height: nil, alignment: .trailing)
                    .widgetAccentable(),
                alignment: .trailing
            )
        }
    }
}

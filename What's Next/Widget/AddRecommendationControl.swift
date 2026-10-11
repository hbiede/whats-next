//
//  AddRecommendationControl.swift
//  WidgetExtension
//
//  Created by Hundter Biede on 10/9/26.
//  Copyright © 2026 com.hbiede. All rights reserved.
//

import AppIntents
import SwiftUI
import WidgetKit

/// Opens the Add Recommendation screen from Control Center, the Lock Screen or the Action button
struct AddRecommendationControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: ADD_CONTROL_KIND) {
            ControlWidgetButton(action: OpenAddRecommendationIntent()) {
                Label("add-rec-title", systemImage: "plus.square.on.square")
            }
        }
        .displayName("add-rec-title")
        .description("add-control-desc")
    }
}

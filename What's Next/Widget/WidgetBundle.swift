//
//  WidgetBundle.swift
//  Widget
//
//  Created by Hundter Biede on 11/7/22.
//  Copyright © 2022 com.hbiede. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct WhatsNextWidgetBundle: WidgetBundle {
    var body: some Widget {
        WhatsNextSingleWidget()
        WhatsNextCombinedWidget()
    }
}

//
//  QuickActionSettings.swift
//  What's Next
//
//  Created by Hundter Biede on 7/13/22.
//

import Foundation

class QuickActionSettings: Equatable, ObservableObject {
    static func == (lhs: QuickActionSettings, rhs: QuickActionSettings) -> Bool {
        lhs.quickAction == rhs.quickAction
    }


    enum ShortcutAction: String {
        case ADD_REC = "AddRec"
        case SHOW_LIST = "ShowList"
        case GET_REC = "GetRec"
    }

    @Published var quickAction: ShortcutAction? = nil
}

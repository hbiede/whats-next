//
//  QuickActionSettings.swift
//  What's Next
//
//  Created by Hundter Biede on 7/13/22.
//

import Foundation

class QuickActionSettings: ObservableObject {

    enum ShortcutAction: String {
        case ADD_REC = "AddRec"
        case SHOW_LIST = "ShowList"
        case GET_REC = "GetRec"
    }

    @Published var quickAction: ShortcutAction? = nil
}

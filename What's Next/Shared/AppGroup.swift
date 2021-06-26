//
//  AppGroup.swift
//  What's Next
//
//  Created by Hundter Biede on 6/21/21.
//  Copyright © 2021 com.hbiede. All rights reserved.
//

import Foundation

public enum AppGroup: String {
  case root = "group.com.hbiede.whatsnext"

  public var containerURL: URL {
    switch self {
    case .root:
      return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.rawValue)!
    }
  }
}

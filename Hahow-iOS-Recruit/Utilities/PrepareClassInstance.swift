//
//  PrepareClassInstance.swift
//  Hahow-iOS-Recruit
//
//  Created by Fish Shih on 2021/12/19.
//

import Foundation

infix operator -->

/// Prepare class instance
func --> <T>(object: T, closure: (T) -> Void) -> T {
    closure(object)
    return object
}

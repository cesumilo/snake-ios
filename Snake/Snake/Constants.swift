//
//  Constants.swift
//  Snake
//
//  Created by Guillaume Robin on 08/12/2018.
//  Copyright © 2018 Guillaume Robin. All rights reserved.
//

import UIKit

struct Map {
    static let width: Int = 20
    static let height: Int = 40
    static let cellOffset: Int = 10
    static let startX: Int = 100
    static let startY: Int = 100
    static let headerMargin: Int = 200
}

struct ItemType {
    static let FLOOR: Int = 0
    static let BODY: Int = 1
    static let WALL: Int = 2
    static let FOOD: Int = 3
}

struct Player {
    static let X: Int = 1
    static let Y: Int = 0
}

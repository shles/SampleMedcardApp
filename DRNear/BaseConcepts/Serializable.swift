//
//  Serializable.swift
//  DRNear
//
//  Created by Igor Shmakov on 25/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation

protocol Serializable {

    var json: [String: Any] { get }

}

//extension Serializable {
//
//    var json: [String : Any] {
//        return [:]
//    }
//}

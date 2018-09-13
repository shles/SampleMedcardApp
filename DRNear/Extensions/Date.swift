//
//  Date.swift
//  DRNear
//
//  Created by Igor Shmakov on 25/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation

extension Date {

    static func from(fullString: String) -> Date? {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.date(from: fullString)
    }

    var fullString: String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.string(from: self)
    }

    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}

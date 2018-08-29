//
// Created by Артмеий Шлесберг on 25/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation

class FileFrom: File {

    init(name: String, size: Int, id: String = "") {
        self.name = name
        self.size = "\(size) МБ"
        self.identification = id
    }

    private(set) var size: String
    private(set) var name: String
    private(set) var identification: String
}

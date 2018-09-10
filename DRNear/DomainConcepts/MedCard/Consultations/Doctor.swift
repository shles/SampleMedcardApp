//
// Created by Артмеий Шлесберг on 06/09/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation

protocol Doctor: Named, Identified, ContainingImage {
    var specialization: String { get }
}

class SimpleDoctor: Doctor {
    private(set) var specialization: String = "Врач общей практики телемедицина"
    private(set) var name: String = "Малышев Леонид Витальевич"
    private(set) var identification: String = "1"
    private(set) var image: ObservableImage = ObservableImageFrom(image: #imageLiteral(resourceName: "doctorPhoto"))
}

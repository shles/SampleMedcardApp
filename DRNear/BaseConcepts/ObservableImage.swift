//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol ObservableImage {

    func asObservable() -> Observable<UIImage>

}

class ObservableImageFrom: ObservableImage {

    private var image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    func asObservable() -> Observable<UIImage> {
        return Observable.just(image)
    }
}

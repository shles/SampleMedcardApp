//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift

class EmptyObservableImage: ObservableImage {

    let image = UIImage()

    func asObservable() -> Observable<UIKit.UIImage> {
        return Observable.just(image)
    }
}

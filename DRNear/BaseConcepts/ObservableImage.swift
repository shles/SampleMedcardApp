//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol ObservableImage {

    func asObservable() -> Observable<UIImage>

}


class SimpleObservableImage: ObservableImage {
    func asObservable() -> Observable<UIImage> {
        return Observable.just(#imageLiteral(resourceName: "rocketMed"))
    }
}

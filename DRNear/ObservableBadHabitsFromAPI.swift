//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

class ObservableBadHabitsFromAPI: ObservableBadHabits {

    private let token: Token
    init(token: Token) {
        self.token = token
    }

    func asObservable() -> Observable<[BadHabit]> {

        return Observable.create { [unowned self] observer in

            guard let url = URL(string: "http://eco-dev.siblion.ru:8080/eco-emc/api/medical-records/953/bad-habits") else {
                observer.onError(ResponseError())
                return Disposables.create()
            }

            var headers = ["Content-Type": "application/json;charset=UTF-8",
                           "Authorization": "Bearer \(self.token.string)"]

            if let xsrf = UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
                headers["X-XSRF-TOKEN"] = xsrf
            }

            Alamofire.request(
                            url,
                            method: .get,
                            parameters: ["type" : "detached"],
                            encoding: URLEncoding.default,
                            headers: headers)

                .responseData(completionHandler: { response in

                    guard let data = response.data, response.error == nil else {
                        observer.onError(response.error ?? ResponseError())
                        return
                    }

                    if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []),
                       let array = responseJSON as? [[String: Any]] {
                        observer.onNext(array
                                .map { BadHabitFrom(name: $0["name"] as? String ?? "", id: $0["code"] as? String ?? "") }
                        )
                        observer.onCompleted()
                    } else {
                        observer.onError(ResponseError())
                        return
                    }
                })
            return Disposables.create()
        }
    }
}

class ResponseError: LocalizedError {

    var message: String = "Низвестная ошибка"
    var description: [String]?
    var errorDescription: String? {
        return description?.joined(separator: " ") ?? message
    }

    init() {

    }

    init(message: String) {
        self.message = message
    }

}

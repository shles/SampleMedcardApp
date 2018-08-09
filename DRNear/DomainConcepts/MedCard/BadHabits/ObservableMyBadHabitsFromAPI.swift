//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

class ObservableMyBadHabitsFromAPI: ObservableBadHabits {

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
                            parameters: [:],
                            encoding: URLEncoding.default,
                            headers: headers)

                    .responseData(completionHandler: { response in

                        guard let data = response.data, response.error == nil else {
                            observer.onError(response.error ?? ResponseError())
                            return
                        }

                        if let response = response.response, let fields = response.allHeaderFields as? [String: String] {
                            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response.url!)

                            HTTPCookieStorage.shared.setCookies(cookies, for: response.url, mainDocumentURL: nil)

                            for cookie in cookies {
                                var cookieProperties = [HTTPCookiePropertyKey: Any]()
                                cookieProperties[HTTPCookiePropertyKey.name] = cookie.name
                                cookieProperties[HTTPCookiePropertyKey.value] = cookie.value
                                cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain
                                cookieProperties[HTTPCookiePropertyKey.path] = cookie.path
                                cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version)
                                cookieProperties[HTTPCookiePropertyKey.expires] = NSDate().addingTimeInterval(31_536_000)

                                let newCookie = HTTPCookie(properties: cookieProperties)
                                HTTPCookieStorage.shared.setCookie(newCookie!)

                                if cookie.name == "XSRF-TOKEN" {
                                    UserDefaults.standard.set(cookie.value, forKey: "X-XSRF-TOKEN")
                                }
                                print("name: \(cookie.name) value: \(cookie.value)")
                            }
                        }

                        if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []),
                           let array = responseJSON as? [[String: Any]] {
                            observer.onNext(array
                                .map { BadHabitFrom(name: $0["name"] as? String ?? "", id: $0["code"] as? String ?? "", selected: true, token: self.token) }
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


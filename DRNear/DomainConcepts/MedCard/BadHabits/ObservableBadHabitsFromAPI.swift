//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON

class RefreshableBadHabits: ObservableBadHabits {

    private var origin: ObservableBadHabits
    private var refreshOn: Observable<Void>

    init(origin: ObservableBadHabits, refreshOn: Observable<Void>) {
        self.origin = origin
        self.refreshOn = refreshOn
    }
    func asObservable() -> Observable<[BadHabit]> {
//        return Observable.combineLatest(origin.asObservable(), refreshOn.startWith(()).debug()) { habits, _ in
//            return habits
//        }

        return refreshOn.startWith(()).flatMapLatest { [unowned self] in self.origin.asObservable() }
    }
}

class ObservableBadHabitsFromAPI: ObservableBadHabits {

    private let token: Token
    private let request: Request

    init(token: Token) throws {
        guard let url = URL(string: "http://eco-dev.siblion.ru:8080/eco-emc/api/medical-records/952/bad-habits") else {
            throw RequestError()
        }
        request = try AuthorizedRequest(
                url: url,
                method: .get,
                token: token,
                parameters: ["type": "detached"],
                encoding: URLEncoding.default
        )
        self.token = token
    }

    func asObservable() -> Observable<[BadHabit]> {

        return request.make()
            .map { json in

                json.arrayValue.map { (json: JSON) in
                    BadHabitFrom(
                            name: json["name"].string  ?? "",
                            id: json["code"].string ?? "",
                            token: self.token
                    )
                }
            }


//        return Observable.create { [unowned self] observer in
//
//            guard let url = URL(string: "http://eco-dev.siblion.ru:8080/eco-emc/api/medical-records/953/bad-habits") else {
//                observer.onError(ResponseError())
//                return Disposables.create()
//            }
//
//            var headers = ["Content-Type": "application/json;charset=UTF-8",
//                           "Authorization": "Bearer \(self.token.string)"]
//
//            if let xsrf = UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
//                headers["X-XSRF-TOKEN"] = xsrf
//            }
//
//            Alamofire.request(
//                            url,
//                            method: .get,
//                            parameters: ["type" : "detached"],
//                            encoding: URLEncoding.default,
//                            headers: headers)
//
//                .responseData(completionHandler: { response in
//
//                    guard let data = response.data, response.error == nil else {
//                        observer.onError(response.error ?? ResponseError())
//                        return
//                    }
//
//                    if let response = response.response, let fields = response.allHeaderFields as? [String: String] {
//                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response.url!)
//
//                        HTTPCookieStorage.shared.setCookies(cookies, for: response.url, mainDocumentURL: nil)
//
//                        for cookie in cookies {
//                            var cookieProperties = [HTTPCookiePropertyKey: Any]()
//                            cookieProperties[HTTPCookiePropertyKey.name] = cookie.name
//                            cookieProperties[HTTPCookiePropertyKey.value] = cookie.value
//                            cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain
//                            cookieProperties[HTTPCookiePropertyKey.path] = cookie.path
//                            cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version)
//                            cookieProperties[HTTPCookiePropertyKey.expires] = NSDate().addingTimeInterval(31_536_000)
//
//                            let newCookie = HTTPCookie(properties: cookieProperties)
//                            HTTPCookieStorage.shared.setCookie(newCookie!)
//
//                            if cookie.name == "XSRF-TOKEN" {
//                                UserDefaults.standard.set(cookie.value, forKey: "X-XSRF-TOKEN")
//                            }
//                            print("name: \(cookie.name) value: \(cookie.value)")
//                        }
//                    }
//
//                    if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []),
//                       let array = responseJSON as? [[String: Any]] {
//                        observer.onNext(array
//                                .map { BadHabitFrom(name: $0["name"] as? String ?? "", id: $0["code"] as? String ?? "", token: self.token) }
//                        )
////                        observer.onCompleted()
//                    } else {
//                        observer.onError(ResponseError())
//                        return
//                    }
//                })
//            return Disposables.create()
//        }.shareReplay(1).debug()
    }
}

class ResponseError: LocalizedError {

    var message: String = "Ошибка сервера"
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

class RequestError: LocalizedError {

    var message: String = "Ошибка запроса"
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

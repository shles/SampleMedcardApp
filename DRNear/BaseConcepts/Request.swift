//
// Created by Артмеий Шлесберг on 14/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import RxSwift

protocol Request {
    func make() -> Observable<JSON>
}

class AuthorizedRequest: Request {

    private var request: URLRequest

    init(path: String,
         method: HTTPMethod = .get,
         token: Token,
         parameters: Parameters = [:],
         encoding: ParameterEncoding = URLEncoding.default,
         headers: [String: String] = [:]) throws {

        guard let url = URL(string: "http://eco-dev.siblion.ru:81\(path)") else {
            throw RequestError()
        }

        var authHeaders = ["Content-Type": "application/json;charset=UTF-8",
                       "Authorization": "Bearer \(token.string)"]

        if let xsrf = UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
            authHeaders["X-XSRF-TOKEN"] = xsrf
        }

        authHeaders.merging(headers, uniquingKeysWith: { _, second in return second })

        self.request = try encoding.encode(URLRequest(url: url, method: method, headers: authHeaders), with: parameters)
    }

    func make() -> Observable<JSON> {
        return Observable.create { [unowned self] observer in

            Alamofire.request(self.request)
                    .responseData { response in

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
                    }
                    .validate()
                    .responseJSON { response in

                        switch response.result {
                        case .success(let value):

                            observer.onNext(JSON(value))
                            observer.onCompleted()

                        case .failure(let error):

                            observer.onError(error)
                        }
                    }
            return Disposables.create()
        }
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
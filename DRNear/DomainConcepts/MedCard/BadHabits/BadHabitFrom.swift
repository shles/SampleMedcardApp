//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class BadHabitFrom: BadHabit {

    init(name: String, id: String, selected: Bool = false, token: Token) {
        self.name = name
        self.identification = id
        self.isSelected.value = selected
        self.token = token
    }

    var name: String = ""
    var identification: String = ""
    var isSelected: Variable<Bool> = Variable(false)
    private var token: Token

    func select() {

        guard let url = URL(string: "http://eco-dev.siblion.ru:8080/eco-emc/api/medical-records/953/bad-habits") else {
            return
        }

        var headers = ["Content-Type": "application/json;charset=UTF-8",
                       "Authorization": "Bearer \(self.token.string)"]

        if let xsrf = UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
            headers["X-XSRF-TOKEN"] = xsrf
        }

        Alamofire.request(
                        url,
                        method: isSelected.value ? .put : .post,
                        parameters: [identification].asParameters(),
                        encoding: ArrayEncoding(),
                        headers: headers)

                .responseData(completionHandler: { [unowned self] response in

                    guard let data = response.data, response.error == nil else {
                        self.isSelected.value = !self.isSelected.value
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

                })
        isSelected.value = !isSelected.value
    }
}

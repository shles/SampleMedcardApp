//
// Created by Артмеий Шлесберг on 29/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class ImageUploadToAPI: FileUpload {

    private var transitionsSubject = PublishSubject<Transition>()
    private let token: Token
    private let image: UIImage



    init(token: Token, image: UIImage) {
        self.token = token
        self.image = image
    }


    func wantsToPerform() -> Observable<Transition> {
        return transitionsSubject
    }

    func upload(name: String) {


        let parameters = [
            "name": name
        ]
        var headers = ["Content-Type": "application/json;charset=UTF-8",
                       "Authorization": "Bearer \(token.string)"]
        if let xsrf = UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
            headers["X-XSRF-TOKEN"] = xsrf
        }

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(self.image, 0.95)!, withName: "file", fileName: "\(name).jpeg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to:"http://eco-dev.siblion.ru:8080/eco-documents/api/upload",
                headers: headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):

                upload.responseData(completionHandler: { response in

                    guard let data = response.data, response.error == nil else {
                        print(response.error)
                        self.transitionsSubject.onNext(ErrorAlertTransition(error: ResponseError(message: "Не удалось загрузить файл")))
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

                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])

                    if let responseJSON = responseJSON as? [String: Any] {
                        if let id = responseJSON["fuid"] as? String {

//                                    DispatchQueue.main.async {
//                                    observer.onNext(TokenFromString(string: token))
//                                    }
                                self.fuidSubject.onNext(FileFrom(name: name, size: 1099, id: id))
                                self.transitionsSubject.onNext(DismissTransition())
                            } else {
                                self.transitionsSubject.onNext(ErrorAlertTransition(error: ResponseError(message: "Не удалось загрузить файл")))
                            }

                        } else {
                            self.transitionsSubject.onNext(ErrorAlertTransition(error: ResponseError(message: "Не удалось загрузить файл")))
                        }
                    })

            case .failure(let encodingError):
                let cookieStore = HTTPCookieStorage.shared
                if let cookie = cookieStore.cookies?.first(where: { $0.name == "XSRF-TOKEN" }), cookie.value != UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
                    for cookie in cookieStore.cookies ?? [] {
                        cookieStore.deleteCookie(cookie)
                    }
                    UserDefaults.standard.set(nil, forKey: "X-XSRF-TOKEN")
                }
                self.transitionsSubject.onNext(ErrorAlertTransition(error: ResponseError(message: "Не удалось загрузить файл")))
            }
        }


    }

    private let fuidSubject = PublishSubject<File>()
    var file: Observable<File>  {
        return fuidSubject
    }
}

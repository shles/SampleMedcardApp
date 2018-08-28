//
// Created by Артмеий Шлесберг on 28/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation

class ApplicationConfiguration {

    func activateTouchID(forCode code: String) {
        UserDefaults.standard.set(true, forKey: "touchIDKey")
        saveCode(code: code)
    }

    func activateFaceID(forCode code: String) {
        UserDefaults.standard.set(true, forKey: "faceIDKey")
        saveCode(code: code)
    }

    private func saveCode(code: String) {
        //TODO: make it secure
        UserDefaults.standard.set(code, forKey: "userCodeKey")
    }

}

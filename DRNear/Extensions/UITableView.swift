//
// Created by Артмеий Шлесберг on 16/06/2017.
// Copyright (c) 2017 Jufy. All rights reserved.
//

import UIKit
// swiftlint:disable all

extension UITableView {

    func dequeueReusableCellOfType<CellType: UITableViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        let cellName = String(describing: type)
        register(CellType.self, forCellReuseIdentifier: cellName)
        return dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! CellType
    }
}
// swiftlint:enable all

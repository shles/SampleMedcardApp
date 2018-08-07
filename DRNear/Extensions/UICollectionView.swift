//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit

extension UICollectionView {
// swiftlint:disable all
    func dequeueReusableCellOfType<CellType: UICollectionViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        let cellName = String(describing: type)

        register(CellType.self, forCellWithReuseIdentifier: cellName)
        return dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! CellType
    }
// swiftlint:enable all
}

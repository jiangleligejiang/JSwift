//
//  RxTableViewSectionedReloadDataSource.swift
//  RxSwiftDemo
//
//  Created by jams on 2019/9/30.
//  Copyright © 2019 jams. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

open class RxTableViewSectionedReloadDataSource<Section: SectionModelType>
    : TableViewSectionedDataSource<Section>
    , RxTableViewDataSourceType {
    
    public func tableView(_ tableView: UITableView, observedEvent: Event<[Section]>) {
        Binder(self) { dataSource, element in
            dataSource.setSections(element)
            tableView.reloadData()
        }.on(observedEvent)
    }
    
}

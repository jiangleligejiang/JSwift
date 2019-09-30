//
//  SimpleTableViewExampleSectionedViewController.swift
//  RxSwiftDemo
//
//  Created by jams on 2019/9/30.
//  Copyright © 2019 jams. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SimpleTableViewExampleSectionedViewController : UIViewController, UITableViewDelegate {
    
    var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>> (
        configureCell: { (_, tv, indexPath, element) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
            return cell
        }, titleForHeaderInSection: { (dataSource, sectionIndex) -> String? in
            return dataSource[sectionIndex].model
        }
    )
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView.delegate = self
        view.addSubview(tableView)
        
        let dataSource = self.dataSource
        
        let items = Observable.just([
            SectionModel(model: "First section", items: [1.0, 2.0, 3.0]),
            SectionModel(model: "Second section", items: [1.0, 2.0, 3.0]),
            SectionModel(model: "Third section", items: [1.0, 2.0, 3.0])
        ])
        
        items.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
        .subscribe(onNext: { pair in
            print("Tapped `\(pair.1)` @ \(pair.0)")
        })
        .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}

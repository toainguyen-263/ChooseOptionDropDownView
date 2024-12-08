//
//  ViewController.swift
//  ChooseOptionDropDownView
//
//  Created by quannguyen90 on 02/06/2023.
//  Copyright (c) 2023 quannguyen90. All rights reserved.
//

import UIKit
import ChooseOptionDropDownView

struct Product {
    var name: String
    var code: String
}

class ViewController: UIViewController {

    var listAllProducts: [Product] = []
    
    func getAllItems(count: Int) -> [Product] {
        var items = [Product]()
        for i in 0...count {
            items.append(Product(name: "Sản phẩm \(i)", code: "\(i)"))
        }
        
        return items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listAllProducts = getAllItems(count: 100)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTouch3(_ sender: Any) {
        let its = listAllProducts.map { pr -> DropDownItem in
            return DropDownItem(id: pr.code, title: pr.name, isSelected: false, subTitle: nil)
        }
        let vc = ChooseOptionBottomDropdownView.chooseOptionBottomVC(selectedPreviousId: nil, listDropDown: its, title: "CHON ITEM") { item in
            print("---> IT: ", item.getTextSearch())
        }
        vc.show(fromVC: self)
    }
    @IBAction func onTouch2(_ sender: Any) {
    }
    @IBAction func onTouch1(_ sender: Any) {
    }
}


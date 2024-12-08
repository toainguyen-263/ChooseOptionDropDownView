//
//  DemoVC.swift
//  ChooseOptionDropDownView_Example
//
//  Created by Quan Nguyen on 06/02/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import ChooseOptionDropDownView

class DemoVC: UIViewController {
    
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
        listAllProducts = getAllItems(count: 5)
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
        vc.heightHeader = 0
        vc.show(fromVC: self)
    }
    @IBAction func onTouch2(_ sender: Any) {
    }
    @IBAction func onTouch1(_ sender: Any) {
    }
}

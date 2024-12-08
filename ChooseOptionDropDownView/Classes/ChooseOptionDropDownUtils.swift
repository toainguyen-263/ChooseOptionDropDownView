//
//  ChooseOptionDropDownUtils.swift
//  ChooseOptionDropDownView
//
//  Created by Quan Nguyen on 06/02/2023.
//

import Foundation
import SwiftMessages
import IQKeyboardManagerSwift

@objc public protocol DropDownItemSearchable: AnyObject {
    func getTextSearch() -> String
}

public class OptionData<T: DropDownItemSearchable> {
    public var name: String?
    public var id: String?
    public var data: [T]?
    
    public init(name: String? = nil, id: String? = nil, data: [T]? = nil) {
        self.name = name
        self.id = id
        self.data = data
    }
}


open class DropDownItem: DropDownItemSearchable {
    public var id: String = ""
    public var title: String = ""
    public var isSelected: Bool = false
    public var subTitle: String?
    public var dateRange: (Date, Date) = (Date(), Date())
    
    public init(id: String, title: String, isSelected: Bool = false, subTitle: String? = nil) {
        self.id = id
        self.title = title
        self.isSelected = isSelected
        self.subTitle = subTitle
    }
    
    public func getTextSearch() -> String {
        var text = [title]
        if let subTitle = subTitle, !subTitle.isEmpty {
            text.append(subTitle)
        }
        return text.joined()
    }
}

extension ChooseOptionBottomDropdownView {
    public class func chooseOptionInBottomViewRefresh<T: DropDownItemSearchable>(listAllData:[T],
                                                                                 multipleSelection: Bool,
                                                                                 title: String,
                                                                                 cellName: String,
                                                                                 cellBundle: Bundle,
                                                                                 estimatedRowHeight: CGFloat = 50,
                                                                                 configCell: @escaping ((_ view: ChooseOptionBottomDropdownView,_ cell: UITableViewCell, _ data: T) -> ()),
                                                                                 didSelectRow:  ((_ indexPath: IndexPath, _ data: T)->())?,
                                                                                 searchBlock:((_ txtSearch: String?)->[T])? = nil) -> ChooseOptionBottomDropdownView {
        var listDisplay = listAllData
        
        let view = ChooseOptionBottomDropdownView(title: title,
                                                  isShowSearch: listDisplay.count > 10,
                                                  cellName: cellName,
                                                  cellBundle: cellBundle) { section in
            return listDisplay.count
        } configCell: { view, indexPath, cell in
            let data = listDisplay[indexPath.row]
            configCell(view, cell, data)
        }
        view.heightHeader = 0
        view.estimateRowHeight = estimatedRowHeight
        view.viewForHeaderAtSection = nil
        view.didSelectRow = { indexPath in
            let data = listDisplay[indexPath.row]
            didSelectRow?(indexPath, data)
            view.reloadData(count: listDisplay.count)
            if !multipleSelection {
                SwiftMessages.hide()
            }
        }
        
        view.didChangeTextSearch = {(text) in
            if let searchBlock = searchBlock {
                listDisplay = searchBlock(text)
                view.reloadData(count: listDisplay.count, isSearching: true)
            } else {
                if let txt = text?.lowercased().removeSignVietnamese(), !txt.isEmpty {
                    listDisplay = listAllData.filter({$0.getTextSearch().lowercased().removeSignVietnamese().contains(txt)})
                } else {
                    listDisplay = listAllData
                }
            }
            listDisplay = searchBlock?(text) ?? []
            view.reloadData(count: listDisplay.count, isSearching: true)
        }
        view.willShow = { _ in
            view.reloadData(count: listDisplay.count)
        }
        view.show()
        
        return view
    }


    public class func chooseOptionInBottomView<T: DropDownItemSearchable>(listAllData:[T],
                                                                          multipleSelection: Bool,
                                                                          title: String,
                                                                          cellName: String,
                                                                          cellBundle: Bundle,
                                                                          estimatedRowHeight: CGFloat = 50,
                                                                          configCell: @escaping ((_ cell: UITableViewCell, _ data: T) -> ()),
                                                                          didSelectRow:  ((_ indexPath: IndexPath, _ data: T)->())?,
                                                                          searchBlock:((_ txtSearch: String?)->[T])? = nil,
                                                                          didHide:((_ view: ChooseOptionBottomDropdownView) -> ())? = nil) -> ChooseOptionBottomDropdownView {
        
        var listDisplay = listAllData

        let view = ChooseOptionBottomDropdownView(title: title,
                                                  isShowSearch: listDisplay.count > 10,
                                                  cellName: cellName,
                                                  cellBundle: cellBundle) { section in
            return listDisplay.count
        } configCell: { view, indexPath, cell in
            let data = listDisplay[indexPath.row]
            configCell(cell, data)
        }
        view.heightHeader = 0
        view.estimateRowHeight = estimatedRowHeight
        view.viewForHeaderAtSection = nil
        view.didSelectRow = { indexPath in
            let data = listDisplay[indexPath.row]
            didSelectRow?(indexPath, data)
            view.reloadData(count: listDisplay.count)

            if !multipleSelection {
                SwiftMessages.hide()
            }
        }

        view.didChangeTextSearch = {(text) in
            if let searchBlock = searchBlock {
                listDisplay = searchBlock(text)
                view.reloadData(count: listDisplay.count, isSearching: true)
            } else {
                if let txt = text?.lowercased().removeSignVietnamese(), !txt.isEmpty {
                    listDisplay = listAllData.filter({$0.getTextSearch().lowercased().removeSignVietnamese().contains(txt)})
                } else {
                    listDisplay = listAllData
                }
            }
            listDisplay = searchBlock?(text) ?? []
            view.reloadData(count: listDisplay.count, isSearching: true)
        }
        view.didHide = didHide
        view.willShow = { _ in
            view.reloadData(count: listDisplay.count)
        }
        view.show()
        return view
    }

    public class func chooseOptionInBottomViewMultiLevel<T: DropDownItemSearchable>(listAllData:[OptionData<T>],
                                                                                    multipleSelection: Bool,
                                                                                    title: String,
                                                                                    cellName: String,
                                                                                    cellBundle: Bundle,
                                                                                    heightHeader: CGFloat = 0,
                                                                                    configHeader: ((_ section: Int, _ data: OptionData<T>) -> (UIView?))? = nil,
                                                                                    configCell: @escaping ((_ cell: UITableViewCell, _ data: T) -> ()),
                                                                                    didSelectRow:  ((_ indexPath: IndexPath, _ data: T)->())?,
                                                                                    searchBlock:((_ txtSearch: String?)->[OptionData<T>])? = nil, didHide:((_ view: ChooseOptionBottomDropdownView) -> ())? = nil) -> ChooseOptionBottomDropdownView {

        var listDisplay = listAllData.filter({($0.data?.count ?? 0) > 0})
        let allItem = listAllData.reduce([]) { rs, op -> [T] in
            if let data = op.data {
                var newRs = rs
                newRs.append(contentsOf: data)
                return newRs
            }
            
            return rs
        }
        let view = ChooseOptionBottomDropdownView(title: title,
                                                  isShowSearch: allItem.count > 10,
                                                  cellName: cellName,
                                                  cellBundle: cellBundle) {
            return listDisplay.count
        } getNumberItemInSection: { section in
            let data = listDisplay[section]
            return data.data?.count ?? 0
        } configCell: { view, indexPath, cell in
            let data = listDisplay[indexPath.section]
            if let item = data.data?[indexPath.row] {
                configCell(cell, item)
            }
        }
        
        view.getNumberSection = {
            return listDisplay.count
        }
        view.heightHeader = heightHeader
        view.viewForHeaderAtSection = { (section) -> UIView? in
            let data = listDisplay[section]
            if configHeader != nil {
                return configHeader?(section, data)
            } else {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: heightHeader))
                let label = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: heightHeader))
                label.text = data.name
                label.textColor = UIColor(red: 0.387, green: 0.387, blue: 0.387, alpha: 1)
                label.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 14)
                view.addSubview(label)
                view.backgroundColor = UIColor(red: 0.962, green: 0.962, blue: 0.962, alpha: 1)
                return view
            }
        }
        
        // DID SELECT ROW
        view.didSelectRow = { indexPath in
            let data = listDisplay[indexPath.section]
            if let item = data.data?[indexPath.row] {
                didSelectRow?(indexPath, item)
            }
            if !multipleSelection {
                SwiftMessages.hide()
            }
        }
        
        // SEARCH
        view.didChangeTextSearch = {(text) in
            if searchBlock == nil {
                if let txt = text?.lowercased().removeSignVietnamese(), !txt.isEmpty {
                    var listItem = [OptionData<T>]()
                    listAllData.forEach { data in
                        if let items = data.data?.filter({$0.getTextSearch().lowercased().removeSignVietnamese().contains(txt) ?? false}), items.count > 0 {
                            let option = OptionData<T>()
                            option.data = items
                            option.name = data.name
                            option.id = data.id
                            listItem.append(option)
                        }
                    }
                    listDisplay = listItem.filter({$0.data?.count ?? 0 > 0})
                } else {
                    listDisplay = listAllData.filter({($0.data?.count ?? 0) > 0})
                }
                
            } else {
                listDisplay = searchBlock?(text) ?? []
            }
            view.reloadData(count: listDisplay.count, isSearching: true)
        }
        
        view.willShow = { _ in
            view.reloadData(count: listDisplay.count)
        }
        view.show()
        view.didHide = didHide
        return view
    }


    public class func chooseOptionBottom(selectedPreviousId: String?,
                            listDropDown: [DropDownItem],
                            title: String,
                            multiChoice: Bool = true,
                            checkmarkColor: UIColor = UIColor(red: 0.02, green: 0.376, blue: 0.651, alpha: 1),
                            didChooseItem: @escaping ((_ item: DropDownItem)->())) -> ChooseOptionBottomDropdownView {
        let items = listDropDown
        for item in items {
            item.isSelected = selectedPreviousId == item.id
        }
        let view = chooseOptionInBottomView(listAllData: items,
                                 multipleSelection: false,
                                 title: title,
                                 cellName: "DropDownItemCell",
                                 cellBundle: Bundle(for: DropDownItemCell.self),
                                 estimatedRowHeight: 50) { cell, data in
            let cellConfig = cell as? DropDownItemCell
            cellConfig?.item = data
            cellConfig?.tintColor = checkmarkColor
            if data.isSelected {
                cellConfig?.accessoryType = .checkmark
            } else {
                cellConfig?.accessoryType = .none
            }
        } didSelectRow: { indexPath, data in
            didChooseItem(data)
        } searchBlock: { text in
            guard let txt = text, !txt.isEmpty else {
                return items
            }
            
            return items.filter { sup in
                let name = sup.getTextSearch()
                let containName = name.removeSignVietnamese().lowercased().contains(txt)
                return containName
            }
        }
     
        return view
    
    }
    
    public class func chooseOptionBottomVC(selectedPreviousId: String?,
                                           listDropDown: [DropDownItem],
                                           title: String,
                                           multiChoice: Bool = true,
                                           checkmarkColor: UIColor = UIColor(red: 0.02, green: 0.376, blue: 0.651, alpha: 1),
                                           didChooseItem: @escaping ((_ item: DropDownItem)->())) -> ChooseOptionBottomDropDownVC {
        let items = listDropDown
        for item in items {
            item.isSelected = selectedPreviousId == item.id
        }
        let vc = ChooseOptionBottomDropDownVC(title: title,
                                     isShowSearch: true,
                                     cellName: "DropDownItemCell",
                                     cellBundle: Bundle(for: DropDownItemCell.self)) { section in
            return listDropDown.count
        } configCell: { indexPath, cell in
            let data = listDropDown[indexPath.row]
            let cellConfig = cell as? DropDownItemCell
            cellConfig?.item = data
            cellConfig?.tintColor = checkmarkColor
            if data.isSelected {
                cellConfig?.accessoryType = .checkmark
            } else {
                cellConfig?.accessoryType = .none
            }
        }
        vc.didChangeTextSearch = { [unowned vc] text in
            
            if let txt = text?.lowercased().removeSignVietnamese(), !txt.isEmpty {
               let  listDisplay = listDropDown.filter({$0.getTextSearch().lowercased().removeSignVietnamese().contains(txt)})
            } else {
               let listDisplay = listDropDown
                vc.reloadData(count: 0)
            }
            
        }
        return vc
        
    }
}

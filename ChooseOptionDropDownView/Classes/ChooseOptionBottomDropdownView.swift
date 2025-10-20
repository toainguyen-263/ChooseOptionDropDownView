//
//  ChooseOptionBottomDropdownView.swift
//  Pop
//
//  Created by Quan Nguyen on 09/07/2021.
//  Copyright © 2021 quan nguyen. All rights reserved.
//

import UIKit
import SwiftMessages
//import IQKeyboardManagerSwift


public class ChooseOptionBottomDropdownView: UIView {
    
    private var isScrollDown = false
    private var isBeginScroll = false
    private var numberSection = 0
    private var count = 0
    private var cellName: String = ""
    private var cellBundle: Bundle = Bundle(for: ChooseOptionBottomDropdownView.self)

    private var title: String = ""
    private var isShowSearch = false
    private var isKeyboardShowing = false

    var placeholderSearchFeild: String? = NSLocalizedString("Tìm kiếm", comment: "")
    var heightHeader: CGFloat = 50
    var estimateRowHeight: CGFloat = 50 {
        didSet {
            tableView.estimatedRowHeight = estimateRowHeight
            tableView.reloadData()
            configSection(margin: 0)
        }
    }
    
    public var viewForHeaderAtSection: ((_ section: Int) ->(UIView?))?
    public var configCell: ((_ view: ChooseOptionBottomDropdownView, _ indexPath: IndexPath, _ cell: UITableViewCell) ->())?
    public var didSelectRow: ((_ indexPath: IndexPath) -> ())?
    public var getNumberSection:(() -> Int)?
    public var getNumberItemInSection:((_ section: Int) -> Int)?
    public var didChangeTextSearch: ((_ textSearch: String?) -> ())?
    public var scrollToEnd: (() -> ())?

    public var willShow: ((_ view: ChooseOptionBottomDropdownView) -> ())?
    public var didShow: ((_ view: ChooseOptionBottomDropdownView) -> ())?
    public var willHide: ((_ view: ChooseOptionBottomDropdownView) -> ())?
    public var didHide: ((_ view: ChooseOptionBottomDropdownView) -> ())?

    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var labelTitleView: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cTraintHeight: NSLayoutConstraint!
    @IBOutlet weak var cTraintBottom: NSLayoutConstraint!
    @IBOutlet weak var cTraintSearchView: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewHeader: UIView!
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
        self.customView()
        configSection(margin: 0)
    }
    
    public init(title: String,
                isShowSearch: Bool,
                cellName: String,
                cellBundle: Bundle,
                getNumberSection:  (() -> Int)? = nil,
                getNumberItemInSection: @escaping  ((_ section: Int) -> Int),
                configCell: @escaping ((_ view: ChooseOptionBottomDropdownView, _ indexPath: IndexPath, _ cell: UITableViewCell) -> ())) {
        
        super.init(frame: CGRect.zero)
        self.title = title
        self.cellName = cellName
        self.cellBundle = cellBundle
        self.isShowSearch = isShowSearch

        self.getNumberSection = getNumberSection
        self.getNumberItemInSection = getNumberItemInSection

        self.configCell = configCell

        self.setupNib()
        self.customView()
        viewSearch.isHidden = !isShowSearch
        tableView.reloadData()
        configSection(margin: 0)
        self.isKeyboardShowing = false
    }
    
    public func configSection(margin: CGFloat, isSearching: Bool = false) {
        if isSearching {
            return
        }
        
        cTraintBottom.constant = UIApplication.bottomMargin
        tableView.reloadData()
        tableView.layoutIfNeeded()
        let height = tableView.contentSize.height

        if height + cTraintBottom.constant + cTraintSearchView.constant + 30 < UIScreen.main.bounds.size.height - 150 - margin {
            cTraintHeight.constant = height + 30 > 50 ? height + 30 : 50
        } else {
            cTraintHeight.constant = UIScreen.main.bounds.size.height - 150 - margin
        }
    }
        
    
    public func setBackgroundColor(color: UIColor) {
        self.viewHeader.backgroundColor = color
        self.viewContent.backgroundColor = color
    }
    
    public func reloadData(count: Int, isSearching: Bool = false) {
        self.count = count
        tableView.reloadData()
        if !isSearching {
            configSection(margin: 0, isSearching: isSearching)
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    fileprivate func getCellReuseIdentifier() -> String {
        return cellName + "ID"
    }
    
    fileprivate func customView() {
        let nib = UINib(nibName: cellName, bundle: cellBundle)
        tableView.register(nib, forCellReuseIdentifier: getCellReuseIdentifier())
        tableView.tableFooterView = UIView()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        labelTitleView.textColor = UIColor(red: 0.212, green: 0.212, blue: 0.212, alpha: 1)
        labelTitleView.font = UIFont(name: "SanFranciscoDisplay-Semibold", size: 17)
        labelTitleView.text = title

        txtSearch.textColor = UIColor(red: 0.212, green: 0.212, blue: 0.212, alpha: 1)
        txtSearch.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 15)
        txtSearch.placeholder = placeholderSearchFeild ?? NSLocalizedString("Tìm kiếm", comment: "")
        txtSearch.addTarget(self, action: #selector(textSearchDidchange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notify:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard(notify:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    
 @objc func willHideKeyboard(notify: Notification) {
//    IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    self.cTraintBottom.constant = UIApplication.bottomMargin
    self.configSection(margin: 0)
    self.layoutIfNeeded()
     isKeyboardShowing = false
 }
    

 @objc func willShowKeyboard(notify: Notification) {
     print(#function)
//    IQKeyboardManager.shared.shouldResignOnTouchOutside = false
     if let keyboardFrame: NSValue = notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
         let keyboardRectangle = keyboardFrame.cgRectValue
         let keyboardHeight = keyboardRectangle.height
         if !isKeyboardShowing {
             self.cTraintBottom.constant = 0
             self.configSection(margin: keyboardHeight)
             self.layoutIfNeeded()
              isKeyboardShowing = true
         }
     }
 }
    
    @objc func textSearchDidchange() {
        didChangeTextSearch?(txtSearch.text?.removeSignVietnamese().lowercased())
    }
    
    @IBAction func onTouchClose(_ sender: Any) {
        SwiftMessages.hide()
//        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    public func show() {
        SwiftMessages.hide()
        var config = SwiftMessages.Config()
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        config.presentationStyle = .bottom
        config.eventListeners.append { event in
            if case .didHide = event {
//                IQKeyboardManager.shared.shouldResignOnTouchOutside = true
                self.didHide?(self)
            } else if case .willHide = event {
                self.willHide?(self)
//                IQKeyboardManager.shared.shouldResignOnTouchOutside = true
                self.endEditing(true)
            } else if case .willShow = event {
                self.willShow?(self)
            } else if case .didShow = event {
                self.didShow?(self)
            }
        }

        let kbTracking = KeyboardTrackingView()
        config.keyboardTrackingView = kbTracking
        SwiftMessages.show(config: config, view: self)
    }
    
}

// MARK: - TableviewDataSource
extension ChooseOptionBottomDropdownView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return getNumberSection?() ?? 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberItemInSection?(section) ?? 0
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: getCellReuseIdentifier(), for: indexPath)
        configCell?(self, indexPath, cell)
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ChooseOptionBottomDropdownView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewForHeaderAtSection?(section)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightHeader
    }
    
}

extension ChooseOptionBottomDropdownView: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            isBeginScroll = true
        } else {
            isBeginScroll = false
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y == 0 {
            isBeginScroll = true
        } else {
            isBeginScroll = false
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -50 && isBeginScroll {
            isBeginScroll = false
            SwiftMessages.hide()
        }
    }
}


//
//  ChooseOptionBottomDropDownVC.swift
//  ChooseOptionDropDownView
//
//  Created by Quan Nguyen on 24/6/24.
//

import UIKit
import IQKeyboardManagerSwift

public class ChooseOptionBottomDropDownVC: UIViewController {
    
    private var isScrollDown = false
    private var isBeginScroll = false
    private var numberSection = 0
    private var count = 0
    private var cellName: String = ""
    private var cellBundle: Bundle = Bundle(for: ChooseOptionBottomDropDownVC.self)

    private var isShowSearch = false
    private var isKeyboardShowing = false

    var placeholderSearchFeild: String? = NSLocalizedString("Tìm kiếm", comment: "")
    public var heightHeader: CGFloat = 50
    var estimateRowHeight: CGFloat = 50 {
        didSet {
            tableView.estimatedRowHeight = estimateRowHeight
            tableView.reloadData()
            configSection(margin: 0)
        }
    }
    
    public var viewForHeaderAtSection: ((_ section: Int) ->(UIView?))?
    public var configCell: ((_ indexPath: IndexPath, _ cell: UITableViewCell) ->())?
    public var didSelectRow: ((_ indexPath: IndexPath) -> ())?
    public var getNumberSection:(() -> Int)?
    public var getNumberItemInSection:((_ section: Int) -> Int)?
    public var didChangeTextSearch: ((_ textSearch: String?) -> ())?
    public var scrollToEnd: (() -> ())?

    public var willShow: ((_ view: ChooseOptionBottomDropDownVC) -> ())?
    public var didShow: ((_ view: ChooseOptionBottomDropDownVC) -> ())?
    public var willHide: ((_ view: ChooseOptionBottomDropDownVC) -> ())?
    public var didHide: ((_ view: ChooseOptionBottomDropDownVC) -> ())?

    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var labelTitleView: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cTraintSearchView: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewHeader: UIView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.customView()

    }
    
    deinit {
        debugPrint("====> DEINIT", self)
    }
    
    public init(title: String,
                isShowSearch: Bool,
                cellName: String,
                cellBundle: Bundle,
                getNumberSection:  (() -> Int)? = nil,
                getNumberItemInSection: @escaping  ((_ section: Int) -> Int),
                configCell: @escaping ((_ indexPath: IndexPath, _ cell: UITableViewCell) -> ())) {
        
        super.init(nibName: "ChooseOptionBottomDropDownVC", bundle: cellBundle)
        self.title = title
        self.cellName = cellName
        self.cellBundle = cellBundle
        self.isShowSearch = isShowSearch

        self.getNumberSection = getNumberSection
        self.getNumberItemInSection = getNumberItemInSection

        self.configCell = configCell

        self.isKeyboardShowing = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configSection(margin: CGFloat, isSearching: Bool = false) {
        if isSearching {
            return
        }
        
        tableView.reloadData()
        tableView.layoutIfNeeded()

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
    IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    self.configSection(margin: 0)
     self.view.layoutIfNeeded()
     isKeyboardShowing = false
 }
    

 @objc func willShowKeyboard(notify: Notification) {
     print(#function)
    IQKeyboardManager.shared.shouldResignOnTouchOutside = false
     if let keyboardFrame: NSValue = notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
         let keyboardRectangle = keyboardFrame.cgRectValue
         let keyboardHeight = keyboardRectangle.height
         if !isKeyboardShowing {
             self.configSection(margin: keyboardHeight)
             self.view.layoutIfNeeded()
              isKeyboardShowing = true
         }
     }
 }
    
    @objc func textSearchDidchange() {
        didChangeTextSearch?(txtSearch.text?.removeSignVietnamese().lowercased())
    }
    
    @IBAction func onTouchClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    func estimateContentSizeTableview() -> Double {
        if isViewLoaded {
            return tableView.contentSize.height
        }
        return 50
//        let numSection = getNumberSection?() ?? 1
//        return (0..<numSection).reduce(0) { [weak self] partialResult, section in
//            let count = self?.getNumberItemInSection?(section) ?? 0
//            return partialResult + CGFloat(count) * CGFloat(self?.estimateRowHeight ?? 0) + (self?.heightHeader ?? 0)
//        }
    
    }
    
    public func show(fromVC: UIViewController) {
        
        let height = estimateContentSizeTableview()
        var h = height
        if height + 120 + 30 < UIScreen.main.bounds.size.height - 50 {
            h = height + 120 + 30
        } else {
            h = UIScreen.main.bounds.size.height - 50
        }
        
        fromVC.presentSheet(self, animated: true, height: h)
    }
    
}

// MARK: - TableviewDataSource
extension ChooseOptionBottomDropDownVC: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return getNumberSection?() ?? 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberItemInSection?(section) ?? 0
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: getCellReuseIdentifier(), for: indexPath)
        configCell?(indexPath, cell)
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ChooseOptionBottomDropDownVC: UITableViewDelegate {
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

extension ChooseOptionBottomDropDownVC: UIScrollViewDelegate {
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
        }
    }
}

extension UIViewController {
    func presentSheet(_ toViewController: UIViewController, animated: Bool, height: CGFloat? = nil, completion: (()->Void)? = nil) {
        if #available(iOS 15.0, *) {
            if let sheet = toViewController.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    if let height = height {
                        if height > 0 {
                            sheet.detents = [
                                .custom(resolver: { context in
                                return height
                            })
                            ]
                        } else {
                            sheet.detents = [.medium(), .large()]
                        }
                        
                    } else {
                        sheet.detents = [.medium(), .large()]
                    }
                    
                } else {
                    // Fallback on earlier versions
                    sheet.detents = [.medium(), .large()]
                }
                sheet.largestUndimmedDetentIdentifier = .large
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
                if #available(iOS 17.0, *) {
                    sheet.prefersPageSizing = true
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        toViewController.modalPresentationStyle = .formSheet
        present(toViewController, animated: animated, completion: completion)
    }

}

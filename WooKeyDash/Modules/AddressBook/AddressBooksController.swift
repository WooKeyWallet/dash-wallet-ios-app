//
//  AddressBooksController.swift


import UIKit

class AddressBooksController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 66 }
    
    var didSelected: ((String) -> Void)?
    
    
    // MARK: - Properties (Private)
    
    private var archiveObj: NSMutableArray = NSMutableArray()
    
    
    // MARK: - Life Cycles

    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "address.title", comment: "")
        }
        
        do /// Subviews
        {
            tableView.register(cellType: AddressBookViewCell.self)
            tableView.separatorInset.left = 25
            tableViewPlaceholder.setImage(UIImage.bundleImage("no_address_placeholder"), for: .withoutData)
            tableViewPlaceholder.setDescription(LocalizedString(key: "address.empty", comment: ""), for: .withoutData)
            tableViewPlaceholder.setButtonTitle(LocalizedString(key: "address.add.title", comment: ""), for: .withoutData)
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "navigation_item_add"), style: .plain, target: self, action: #selector(self.addAction))
        
        tableViewPlaceholder.bottomButton.addTarget(self, action: #selector(self.addAction), for: .touchUpInside)
        
        onDidSelectRow { [unowned self] (row, _) in
            guard let model: AddressBook = row.serializeModel(), let handler = self.didSelected else { return }
            handler(model.tokenAddress)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    private func loadData() {
        DispatchQueue.global().async {
            var rowList = [TableViewRow]()
            if let list = NSKeyedUnarchiver.unarchiveObject(withFile: "AddressBook.archiver".filePaths.document) as? NSArray {
                for obj in list {
                    if let dict = obj as? NSDictionary {
                        let label = dict.object(forKey: "label") as? String ?? ""
                        let address = dict.object(forKey: "address") as? String ?? ""
                        let model = AddressBook(label: label, tokenAddress: address)
                        rowList.append(TableViewRow(model, cellType: AddressBookViewCell.self, rowHeight: self.rowHeight))
                    }
                }
                self.archiveObj = NSMutableArray.init(array: list)
            }
            let state: TableViewPlaceholder.State = rowList.count > 0 ? .none : .withoutData
            self.dataSource = [TableViewSection(rowList)]
            DispatchQueue.main.async {
                self.tableViewPlaceholder.state = state
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func addAction() {
        let vc = AddressBookAddController()
        vc.archiveObj = self.archiveObj
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension AddressBooksController {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: LocalizedString(key: "delete", comment: ""), handler: {
            [unowned self] (_, indexPath) in
                HUD.showHUD()
                DispatchQueue.global().async {
                    self.archiveObj.removeObject(at: indexPath.row)
                    let success = NSKeyedArchiver.archiveRootObject(self.archiveObj, toFile: "AddressBook.archiver".filePaths.document)
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        guard success else {
                            HUD.showError(LocalizedString(key: "delete.failure", comment: ""))
                            return
                        }
                        HUD.showError(LocalizedString(key: "delete.success", comment: ""))
                        self.loadData()
                    }
                }
            })
        ]
    }
}

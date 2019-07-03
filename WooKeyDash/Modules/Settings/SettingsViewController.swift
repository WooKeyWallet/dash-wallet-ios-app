//
//  SettingsViewController.swift


import UIKit

class SettingsViewController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var style: UITableView.Style { return .grouped }
    override var rowHeight: CGFloat { return 60 }
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var viewModel = { SettingsViewModel() }()
    
    
    // MARK: - Life Cycles
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "settings", comment: "")
        }
        
        do /// Subviews
        {
            tableView.register(cellType: SettingsViewCell.self)
            tableView.separatorInset.left = 65
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Load Data
        {
            viewModel.dataSourceState.observe(self) { (data, SELF) in
                SELF.dataSource = data
                DispatchQueue.main.async {
                    SELF.tableView.reloadData()
                }
            }
            
            viewModel.reloadData()
        }
        
        do /// Select Action
        {
            onDidSelectRow { [unowned self] (row, _) in
                guard let indexPath = row.indexPath else { return }
                self.navigationController?.pushViewController(self.viewModel.getNextViewController(indexPath), animated: true)
            }
        }
    }
}

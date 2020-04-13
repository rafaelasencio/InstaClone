//
//  SearchVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavController()
        
        self.tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        return cell
    }
    
    func configureNavController(){
        self.navigationItem.title = "Algo"
    }
}

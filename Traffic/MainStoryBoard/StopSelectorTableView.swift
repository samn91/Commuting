//
//  StopSelectorTableView.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-08-30.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class StopSelectorTableView : UITableViewController, UISearchBarDelegate {
    
    private var rows:Array<BussStop>=[]
    private var lastSelected:BussStop?=nil
    
    @IBOutlet weak var searchBar:UISearchBar!
    
    override func viewDidLoad() {
        searchBar.delegate = self
        tableView.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let stopInfo=self.rows[indexPath.row]
        cell.textLabel?.text = stopInfo.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selected=rows[indexPath.row]
        Saver.addBussStop(stop: selected)
        existView()
        searchBar.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if  searchText.count > 1 {
            Downloader.downloadBussStop(searchText) { list in
                self.rows=list
                self.tableView.reloadData()
            }
        }
    }
    
    func existView()  {
        navigationController?.popViewController(animated: true)
    }
}

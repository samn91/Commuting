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
    private static let STOP = 0
    private static let ROUTE = 1
    private static let FROM = "From: "
    private static let TO = "To: "
    
    
    private var rows:Array<BussStop>=[]
    private var inputType = StopSelectorTableView.STOP
    private var lastSelected:BussStop?=nil
    
    private var routeSelector:String? = nil {
        didSet{
            fromLabel.font = UIFont.systemFont(ofSize: 17.0)
            toLabel.font = UIFont.systemFont(ofSize: 17.0)
            if  routeSelector == StopSelectorTableView.FROM {
                fromLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
            } else if  routeSelector == StopSelectorTableView.TO {
                toLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
            }
        }
    }
    
    
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var routeContainer: UIStackView!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    override func viewDidLoad() {
        searchBar.delegate=self
        tableView.delegate = self
        routeSelector = StopSelectorTableView.FROM
        
        calculateHeader()
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
        switch inputType {
        case StopSelectorTableView.STOP:
            Saver.addBussStop(stop: selected)
            existView()
        case StopSelectorTableView.ROUTE:
            selected = Parser.removeKnownPrifix(forStop: selected)
            if routeSelector == StopSelectorTableView.FROM {
                routeSelector = StopSelectorTableView.TO
                fromLabel.text = StopSelectorTableView.FROM + selected.name!
            } else {
                toLabel.text = StopSelectorTableView.TO + selected.name!
                Saver.addRoute(route: RouteInfo(from: lastSelected!, to: selected))
                existView()
            }
        default: break
            
        }
        
        lastSelected=selected
        searchBar.text = ""
    }
    
    @IBAction func routeValueChanged(_ sender: UISegmentedControl) {
        routeContainer.isHidden =  sender.selectedSegmentIndex == StopSelectorTableView.STOP
        inputType = sender.selectedSegmentIndex
        calculateHeader()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if  searchText.count > 1 {
            Downloader.downloadBussStop(searchText) { (list) in
                self.rows=list
                self.tableView.reloadData()
            }
        }
        
    }
    
    func existView()  {
        navigationController?.popViewController(animated: true)
    }
    
    func calculateHeader() {
         let height = CGFloat(28.0 * (inputType == StopSelectorTableView.STOP ? 3 : 4 ))
        if let headerView = tableView.tableHeaderView {
            //let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    
    
}

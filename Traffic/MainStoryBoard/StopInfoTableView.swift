//
//  TableView.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-08-29.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation
import UIKit


class StopInfoTableView: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var refreshView: UIRefreshControl!
    private var rows : Array<BussTimeInfo> = []
    private var downloadCount = 0
    var routeInfo:RouteInfo?=nil
    var bussStops:Array<BussStop>? = nil
    {
        didSet{
            downloadCount=bussStops?.count ?? 0
        }
    }
    
    override func viewDidLoad() {
        downloadContent()
        NotificationCenter.default.addObserver(self, selector:#selector(downloadContent), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let stopInfo=self.rows[indexPath.row]
        
        if stopInfo.stopName != nil{
            cell.textLabel?.font=cell.textLabel?.font.withSize(13.0)
        }
        cell.textLabel?.text =
            (stopInfo.isRealTime ? "" : "*")  +
            (stopInfo.stopName == nil ? "" :"\(stopInfo.stopName!)-\(stopInfo.stopPoint): ")  + Parser.timeFormatter.string(from: stopInfo.time) + " - " + stopInfo.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selected=rows[indexPath.row]
       
        
    }
    
    @IBAction func onRefreshing(_ sender: UIRefreshControl) {
        self.downloadContent()
    }
    
    
    @objc func downloadContent()  {
        rows.removeAll()
        tableView.reloadData()
        refreshView.beginRefreshing()
        
        if routeInfo != nil {
            Downloader.downloadRoute(routeInfo!){
                self.rows=$0
                self.tableView.reloadData()
                self.refreshView.endRefreshing()
            }
        } else if bussStops != nil {
            if self.downloadCount == 1 { // show title
                navigationController?.title=self.bussStops?[0].name
            }
            for stop in self.bussStops! {
                Downloader.downloadBussInfo(stop: stop) { (list) in
                    self.downloadCount -= 1
                    self.rows+=list
                    if self.downloadCount == 0 {
                        self.rows.sort{ $0.time<$1.time }
                        self.tableView.reloadData()
                        self.refreshView.endRefreshing()
                        self.downloadCount=self.bussStops?.count ?? 0
                    }
                }
            }
        }
        
        
    }
    
}

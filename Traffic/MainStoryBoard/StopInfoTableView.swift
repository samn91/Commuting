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
    private var numberOfBussStopDownloaded = 0
    var routeInfo:RouteInfo?=nil
    var bussStops:Array<BussStop>? = nil
    {
        didSet{
            numberOfBussStopDownloaded=bussStops?.count ?? 0
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
        let stopInfo = self.rows[indexPath.row]
        
        let multipleStops = self.bussStops!.count > 1
        let relativeTime = Parser.timeFormatter.string(from: stopInfo.time) +
            (stopInfo.isRealTime ? " " : "*")
        let stopPoint = " \(stopInfo.stopPoint) "
        let stopNameAndPoint = multipleStops ?  "\(stopInfo.stopName)-\(stopInfo.stopPoint):" : stopPoint
        if multipleStops {
            cell.textLabel?.font = cell.textLabel?.font.withSize(13.0)
        } else {
            cell.textLabel?.font = cell.textLabel?.font.withSize(UIFont.systemFontSize)
        }
        cell.textLabel?.text = stopNameAndPoint + " "
              + relativeTime + " - " + stopInfo.name
        
        cell.textLabel?.highlightRange(stopPoint)//
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
        
        if routeInfo != nil {//todo remove when implementing filters
            Downloader.downloadRoute(routeInfo!){
                self.rows = $0
                self.tableView.reloadData()
                self.refreshView.endRefreshing()
            }
        } else if bussStops != nil {
            if self.bussStops?.count == 1 { // show title
                self.title = self.bussStops![0].name
            }
            for stop in self.bussStops! {
                Downloader.downloadBussInfo(stop: stop) { (list) in
                    self.numberOfBussStopDownloaded -= 1
                    self.rows+=list
                    if self.numberOfBussStopDownloaded == 0 {
                        self.rows.sort{ $0.time<$1.time }
                        self.tableView.reloadData()
                        self.refreshView.endRefreshing()
                        self.numberOfBussStopDownloaded = self.bussStops?.count ?? 0
                    }
                }
            }
        }
    }
}

extension UILabel{
    func highlightRange(_ textToHightlight:String){
        let range = (text! as NSString).range(of: textToHightlight)
        
        let attributedText = NSMutableAttributedString.init(string: text!)
       // attributedText.addAttribute(NSAttributedStringKey.font, value: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.medium) , range: range)
        attributedText.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.green , range: range)
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white , range: range)
        self.attributedText = attributedText
    }
}

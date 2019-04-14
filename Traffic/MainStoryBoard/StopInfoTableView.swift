//
//  TableView.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-08-29.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation
import UIKit

class StopInfoTableView: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var refreshView: UIRefreshControl!
    private var rows : Array<BussTimeInfo> = []
    private var numberOfBussStopDownloaded = 0
    private var multipleStops=false
    var routeInfo:RouteInfo?=nil
    var stopPoints=Array<String>()
    var bussStops:Array<BussStop>? = nil
    {
        didSet{
            if let count = bussStops?.count{
                numberOfBussStopDownloaded = count
                multipleStops = count > 1
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        downloadContent()
        NotificationCenter.default.addObserver(self, selector:#selector(downloadContent), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        let adapter = Adapter(self.multipleStops)
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stopPoints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CustomCollectionCell
        cell.contentView.backgroundColor=UIColor.cyan
        
        cell.label.text = stopPoints[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        if self.multipleStops {
            cell.textLabel?.font = cell.textLabel?.font.withSize(13.0)
        } else {
            cell.textLabel?.font = cell.textLabel?.font.withSize(UIFont.systemFontSize)
        }
        
        let stopInfo = self.rows[indexPath.row]
        
        let stopPoint = " \(stopInfo.stopPoint) "
        let stopNameAndPoint = self.multipleStops ?  "\(stopInfo.stopName)-\(stopInfo.stopPoint):" : stopPoint
        
        cell.textLabel?.text = stopNameAndPoint + " "
            + stopInfo.getRelativeTime() + " - " + stopInfo.getNameAndDriaction()
        
        cell.textLabel?.highlightRange(stopPoint)
        return cell
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
            if !self.multipleStops && !self.bussStops!.isEmpty { // show title
                self.title = self.bussStops![0].name
            }
            for stop in self.bussStops! {
                Downloader.downloadBussInfo(stop: stop) { (list) in
                    self.numberOfBussStopDownloaded -= 1
                    self.rows+=list
                    if self.numberOfBussStopDownloaded == 0 {
                        let stopslist=self.rows.map{$0.stopPoint.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }.filter{!$0.isEmpty}.sorted()//todo fix sorting
                        self.stopPoints = Array(Set(stopslist))
                        self.collectionView.reloadData()
                        self.rows.sort{ $0.time<$1.time }
                        self.tableView.reloadData()
                        self.refreshView.endRefreshing()
                        self.numberOfBussStopDownloaded = self.bussStops!.count
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

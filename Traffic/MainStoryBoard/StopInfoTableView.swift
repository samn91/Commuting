//
//  TableView.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-08-29.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation
import UIKit

class StopInfoTableView: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var refreshView: UIRefreshControl!
    private var fullRows : Array<BussTimeInfo> = []
    private var filteredRows : Array<BussTimeInfo> = []
    private var numberOfBussStopDownloaded = 0
    private var multipleStops = false
    private var selectedStopPoints = Array<String>()
    var stopPoints = Array<String>()
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
    
    
    //helper function
    private func isThere(_ array: Array<String>, _ element: String) -> Bool{
        return array.index(of: element) == nil ? false : true
    }
    
    override func viewDidLoad() {
        downloadContent()
        NotificationCenter.default.addObserver(self, selector:#selector(downloadContent), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        let adapter = Adapter(self.multipleStops)
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stopPoints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CustomCollectionCell
        
        let point = stopPoints[indexPath.row]
        
        let weight = isThere(selectedStopPoints, point) ? UIFont.Weight.bold : UIFont.Weight.medium
        
        cell.label.textColor = isThere(selectedStopPoints, point) ? UIColor.black : UIColor.lightGray
        cell.label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: weight)
        
        cell.label.text = point
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let stopPoint = self.stopPoints[indexPath.item]
        let spIndex: Int? = selectedStopPoints.index(of: stopPoint)
        if (spIndex != nil) { //already selected, remove filter
            if self.selectedStopPoints.count == 0 {
                self.selectedStopPoints.remove(at: spIndex!)
                selectedStopPoints.insert(contentsOf: stopPoints, at: 0)
            } else if self.selectedStopPoints.count == stopPoints.count {
                selectedStopPoints.removeAll()
                self.selectedStopPoints.append(stopPoint)
            } else {
                self.selectedStopPoints.remove(at: spIndex!)
            }
        } else {
            self.selectedStopPoints.append(stopPoint)
        }
        applyStopPointFilter()
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        if self.multipleStops {
            cell.textLabel?.font = cell.textLabel?.font.withSize(13.0)
        } else {
            cell.textLabel?.font = cell.textLabel?.font.withSize(UIFont.systemFontSize)
        }
        
        let stopInfo = self.filteredRows[indexPath.row]
        
        let stopPoint = " \(stopInfo.stopPoint.isEmpty ? "?" : stopInfo.stopPoint) "
        let stopNameAndPoint = self.multipleStops ?  "\(stopInfo.stopName) \(stopPoint):" : stopPoint
        
        cell.textLabel?.text = stopNameAndPoint + " "
            + stopInfo.getRelativeTime() + " - " + stopInfo.getNameAndDriaction()
        
        cell.textLabel?.highlightRange(stopPoint)
        return cell
    }
    
    @IBAction func onRefreshing(_ sender: UIRefreshControl) {
        self.downloadContent()
    }
    
    @objc func downloadContent()  {
        self.fullRows.removeAll()
        tableView.reloadData()
        refreshView.beginRefreshing()
        
        if bussStops != nil {
            if !self.multipleStops && !self.bussStops!.isEmpty { // show title
                self.title = self.bussStops![0].name
            }
            for stop in self.bussStops! {
                Downloader.downloadBussInfo(stop: stop) { (list) in
                    self.numberOfBussStopDownloaded -= 1
                    self.fullRows+=list
                    if self.numberOfBussStopDownloaded == 0 {
                        let stopslist=self.fullRows.map{$0.stopPoint.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }.filter{!$0.isEmpty}.sorted()//todo fix sorting
                        self.stopPoints = Array(Set(stopslist))
                        self.collectionView.reloadData()
                        if self.selectedStopPoints.count == 0 {
                            self.selectedStopPoints.insert(contentsOf: self.stopPoints, at: 0)
                        }
                        self.applyStopPointFilter()
                        self.tableView.reloadData()
                        self.refreshView.endRefreshing()
                        self.numberOfBussStopDownloaded = self.bussStops!.count
                    }
                }
            }
        }
    }
    
    func applyStopPointFilter()  {
        if (selectedStopPoints.isEmpty){
            self.filteredRows = self.fullRows
        } else {
            self.filteredRows = self.fullRows.filter{selectedStopPoints.index(of: $0.stopPoint) != nil }
        }
        self.filteredRows = self.filteredRows.sorted{ $0.time<$1.time }
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

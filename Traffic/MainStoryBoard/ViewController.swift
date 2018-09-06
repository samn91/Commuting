//
//  ViewController.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-08-27.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, CLLocationManagerDelegate {
    
    
    static let prefix = ["Malmö"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hereButton: UIButton!
    
    var rows:Array<BussStop> = []
    
    
    let locationManager = CLLocationManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //print("awakeFromNib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewDidLoad")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rows = Saver.getBussStop()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "workSegue"{
            // stops=[BussStop(i:"80821",n:nil)]
        }
        if segue.identifier == "stopInfoSegue"{
            let stops = sender as? [BussStop]
            if let tv = segue.destination as? StopInfoTableView, (stops != nil) {
                tv.bussStops = stops!.map {
                    if var name = $0.name {
                        for px in ViewController.prefix {
                            if name.starts(with: px){
                                name =  name.components(separatedBy: " ").dropFirst(1).joined()
                                return BussStop(i: $0.id,n: name)
                            }
                        }
                    }
                    return BussStop(i: $0.id,n: nil)
                }
                tv.title=(sender as? UIButton)?.titleLabel?.text
            }
        }
    }
    
    @IBAction func workClicked(_ sender: UIButton) {
        openStopInfoTableView(list: [BussStop(i:"80821",n:nil)])
    }
    
    @IBAction func hereCliecked(_ sender: UIButton) {
        sender.isEnabled = false
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        //cell.textLabel?.font=cell.textLabel?.font.withSize(13.0)
        cell.textLabel?.text=rows[indexPath.row].name ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = BussStop(i: rows[indexPath.row].id,n: nil)
        openStopInfoTableView(list: [item])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.rows.remove(at: indexPath.row)
            Saver.saveBussStops(list: self.rows)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        Downloader.downloadBussStopForPoint(String(locValue.latitude), String(locValue.longitude)) { (list) in
            self.openStopInfoTableView(list: list)
            self.hereButton.isEnabled=true
        }
        
    }
    
    func openStopInfoTableView(list:Array<BussStop>) {
        self.performSegue(withIdentifier: "stopInfoSegue", sender: list)
    }
    
}




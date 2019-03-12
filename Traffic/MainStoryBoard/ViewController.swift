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
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hereButton: UIButton!
    
    var rows:Array<CustomStringConvertible> = []
    
    var hadLocationUpdate=false
    
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
        rows.removeAll()
        Saver.getRoutes().forEach { rows.append($0) }
        Saver.getBussStop().forEach { rows.append($0) }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopInfoSegue"{
            if let tv = segue.destination as? StopInfoTableView {
                if  let stops = sender as? [BussStop] {
                    tv.bussStops = Parser.removeKnownPrifix(stops: stops)
                    tv.title=(sender as? UIButton)?.titleLabel?.text
                } else if let route = sender as? RouteInfo {
                    tv.routeInfo = route
                }
            }
        }
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
        cell.textLabel?.text = rows[indexPath.row].description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let stop = rows[indexPath.row] as? BussStop {
            let item = BussStop(i: stop.id,n: nil)
            openStopInfoTableView(list: [item])
        } else if let route = rows[indexPath.row] as? RouteInfo {
            openStopInfoTableView(forRoute: route)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let stop = rows[indexPath.row] as? BussStop {
                Saver.removeBussStop(stop: stop)
            } else  if let route = rows[indexPath.row] as? RouteInfo {
                Saver.removeRoute(route: route)
            }
            self.rows.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.hadLocationUpdate == true{
            return
        }
        self.hadLocationUpdate=true
        manager.stopUpdatingLocation()
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        Downloader.downloadBussStopForPoint(String(locValue.latitude), String(locValue.longitude)) { (list) in
            self.openStopInfoTableView(list: list)
            self.hereButton.isEnabled=true
            self.hadLocationUpdate=false
        }
        
    }

    
    func openStopInfoTableView(list: Array<BussStop>) {
        self.performSegue(withIdentifier: "stopInfoSegue", sender: list)
    }
    
    func openStopInfoTableView(forRoute route: RouteInfo) {
        self.performSegue(withIdentifier: "stopInfoSegue", sender: route)
    }
    
}




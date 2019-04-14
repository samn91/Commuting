//
//  Adapter.swift
//  Traffic
//
//  Created by Samer Naoura on 2019-04-14.
//  Copyright © 2019 Samer Naoura. All rights reserved.
//

import Foundation
import UIKit

class Adapter:NSObject, UITableViewDelegate, UITableViewDataSource{
    var rows : Array<String> = []
    var resizeFont=false
    
    init(_ resizeFont:Bool){
        self.resizeFont=resizeFont
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let stopInfo = self.rows[indexPath.row]
        
        
        if self.resizeFont {
            cell.textLabel?.font = cell.textLabel?.font.withSize(13.0)
        } else {
            cell.textLabel?.font = cell.textLabel?.font.withSize(UIFont.systemFontSize)
        }
        cell.textLabel?.text = stopInfo
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selected=rows[indexPath.row]
        
        
    }
}

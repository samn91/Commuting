//
//  BussInfo.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-08-28.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation
struct BussTimeInfo {
    /*
     <Line>
         <Name>5</Name>
         <No>5</No>
         <JourneyDateTime>2018-08-28T06:26:00</JourneyDateTime>
         <IsTimingPoint>true</IsTimingPoint>
         <StopPoint>A</StopPoint>
         <LineTypeId>4</LineTypeId>
         <LineTypeName>Stadsbuss</LineTypeName>
         <Towards>Stenkällan via Rosengård</Towards>
         <RealTime>
             <RealTimeInfo>
                 <NewDepPoint>B</NewDepPoint>
                 <DepTimeDeviation>3</DepTimeDeviation>
                 <DepDeviationAffect>NON_CRITICAL</DepDeviationAffect>
             </RealTimeInfo>
         </RealTime>
         <TrainNo>0</TrainNo>
         <Deviations/>
         <RunNo>17</RunNo>
     </Line>
 */
    
    
    var name:String
    var time:Date
    var stopName:String
    var isRealTime:Bool
    let stopPoint:String
    init(n:String,t:Date,s:String,r:Bool,sp:String) {
        name=n
        time=t
        stopName=s
        isRealTime=r
        stopPoint=sp
    }
    
}

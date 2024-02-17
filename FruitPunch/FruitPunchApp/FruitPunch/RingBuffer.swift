//
//  RingBuffer.swift
//  HTTPSwiftExample
//
//  Created by Eric Larson on 10/27/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

import UIKit

let BUFFER_SIZE = 50

class RingBuffer: NSObject {
    
    var xAccel = [Double](repeating:0, count:BUFFER_SIZE)
    var yAccel = [Double](repeating:0, count:BUFFER_SIZE)
    var zAccel = [Double](repeating:0, count:BUFFER_SIZE)
    
    var xGyro = [Double](repeating:0, count:BUFFER_SIZE)
    var yGyro = [Double](repeating:0, count:BUFFER_SIZE)
    var zGyro = [Double](repeating:0, count:BUFFER_SIZE)
    
    
    var head:Int = 0 {
        didSet{
            if(head >= BUFFER_SIZE){
                head = 0
            }
            
        }
    }
    
    func addNewData(xAcc:Double,yAcc:Double,zAcc:Double, xGy:Double, yGy:Double, zGy:Double){
        xAccel[head] = xAcc
        yAccel[head] = yAcc
        zAccel[head] = zAcc
        
        xGyro[head] = xGy
        yGyro[head] = yGy
        zGyro[head] = zGy
        
        head += 1
    }
    
    func getDataAsVector()->[Double]{
        var allData = [Double](repeating:0, count:6*BUFFER_SIZE)
        for i in 0..<BUFFER_SIZE {
            let idx = (head+i)%BUFFER_SIZE
            allData[6*i] = xAccel[idx]
            allData[6*i+1] = yAccel[idx]
            allData[6*i+2] = zAccel[idx]
            allData[6*i+3] = xGyro[idx]
            allData[6*i+4] = yGyro[idx]
            allData[6*i+5] = zGyro[idx]
        }

        return allData
        
    }

}

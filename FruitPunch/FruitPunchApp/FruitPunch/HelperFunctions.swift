//
//  HelperFunctions.swift
//  FruitPunch
//
//  Created by Jaden Prawiro on 12/5/23.
//

import Foundation
import UIKit

func randomCGFloat(_ lowerLimit: CGFloat, _ upperLimit: CGFloat) -> CGFloat{
    return lowerLimit + CGFloat(arc4random()) / CGFloat(UInt32.max) * upperLimit - lowerLimit
}

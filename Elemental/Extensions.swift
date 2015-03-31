//
//  Extensions.swift
//  Elemental
//
//  Created by Jason Martin on 3/29/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

import Foundation
import SpriteKit

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            
            var error: NSError?
            let data: NSData? = NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
            if let data = data {
                
                let dictionary: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions(), error: &error)
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return dictionary
                } else {
                    println("Level file '\(filename)' is not valid JSON: \(error!)")
                    return nil
                }
            } else {
                println("Could not load level file: \(filename), error: \(error!)")
                return nil
            }
        } else {
            println("Could not find level file: \(filename)")
            return nil
        }
    }
}



extension SKColor {
    
    class func appIceMana() -> UIColor {
        return UIColor(red: 109.0/255.0, green: 189.0/255.0, blue: 189.0/255.0, alpha: 0.3)
    }
    
    class func appFireMana() -> UIColor {
        return UIColor(red: 222.0/255.0, green: 130.0/255.0, blue: 49.0/255.0, alpha: 1.0)
    }
    
    class func appEarthMana() -> UIColor {
        return UIColor(red: 142.0/255.0, green: 77.0/255.0, blue: 10.0/255.0, alpha: 1.0)
    }
    
    class func appWindMana() -> UIColor {
        return UIColor(red: 63.0/255.0, green: 116.0/255.0, blue: 158.0/255.0, alpha: 1.0)
    }
    
    class func appTimeMana() -> UIColor {
        return UIColor(red: 182.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 1.0)
    }
    
    class func appVoidMana() -> UIColor {
        return UIColor(red: 197.0/255.0, green: 139.0/255.0, blue: 251.0/255.0, alpha: 1.0)
    }
    
    class func appLightningMana() -> UIColor {
        return UIColor(red: 251.0/255.0, green: 101.0/255.0, blue: 248.0/255.0, alpha: 1.0)
    }
    
    class func appWaterMana() -> UIColor {
        return UIColor(red: 87.0/255.0, green: 147.0/255.0, blue: 198.0/255.0, alpha: 1.0)
    }
}
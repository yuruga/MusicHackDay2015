//
//  Share.swift
//  MusicHackDay2015
//
//  Created by ichikawa on 2015/08/21.
//  Copyright (c) 2015年 yuruga. All rights reserved.
//

import Foundation

class Share {
    
    static let APP_KEY_CENTRAL_MANAGER = "app_key_central_manager"
    static let APP_KEY_PERIPHERAL =  "app_key_peripheral"
    
    private static var _APP_VARS: [String: AnyObject!] = [:]
    
    static func getConfigValueWithKey(key: String) -> (String) {
        let bundleIdentifier = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier") as! String
        return NSBundle.mainBundle().objectForInfoDictionaryKey(key) as! String
    }
    
    static func setUserDefault(key:String, val:AnyObject) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(val, forKey: key)
    }
    
    static func getUserDefault(key:String) -> (AnyObject){
        let ud = NSUserDefaults.standardUserDefaults()
        return ud.objectForKey(key)!
    }
    
    static func hasUserDefault(key:String) -> (Bool){
        let ud = NSUserDefaults.standardUserDefaults()
        return ud.objectForKey(key) != nil
    }
    
    static func getAppValueWithKey(key: String) -> (AnyObject!) {
        return _APP_VARS[key]
    }
    
    static func setAppValueWithKey(key: String, val: AnyObject!) {
        _APP_VARS[key] = val
    }
}


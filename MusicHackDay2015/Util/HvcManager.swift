//
//  HvcManager.swift
//  MusicHackDay2015
//
//  Created by ichikawa on 2015/08/22.
//  Copyright (c) 2015年 yuruga. All rights reserved.
//

import Foundation

class HvcManager: NSObject, HVC_Delegate {
    
    
    //MARK: Singleton
    private override init() {
        super.init()
        _hvc = HVC_BLE()
        _hvc.delegateHVC = self
    }
    static let _instance = HvcManager()
    static func defaultInstance() -> (HvcManager) {
        return _instance;
    }
    private var _hvc:HVC_BLE!
    private var _devices:[CBPeripheral] = []
    private var _deviceSearchCount:Int = 0
    
    //デバイス探索
    func deviceSearch() {
        println("@@@= Start Search")
        
        //クリア
        _devices = []
        
        //検索確認
        NSTimer.scheduledTimerWithTimeInterval(
            2.0,
            target: self,
            selector: "deviceSearchedCheck:",
            userInfo: nil,
            repeats: true
        )
        
        //スキャン開始
        _hvc.deviceSearch()
    }
    //デバイス検出チェック
    func deviceSearchedCheck(timer:NSTimer){
        let devices = _hvc.getDevices().mutableCopy() as! [CBPeripheral]
        _devices = devices.filter { (device) -> Bool in
            if (device.name.rangeOfString(HVC_DEVICE_KEY) != nil) {
                return true
            }
            return false
        }
        if(_devices.count > 0){
            timer.invalidate()
            NSNotificationCenter.defaultCenter().postNotificationName(
                EVENT_DEVICE_SCAN_FINISH,
                object: nil
            )
            self.disconnect()
            println("Found \(_devices)")
            return
        }
        _deviceSearchCount += 1
        if _deviceSearchCount > 5 {
            _deviceSearchCount = 0;
            timer.invalidate()
            NSNotificationCenter.defaultCenter().postNotificationName(
                EVENT_DEVICE_SCAN_FINISH,
                object: nil
            )
            self.disconnect()
            println("Not Found")
        }
    }
    
    func getDevices() -> ([CBPeripheral]) {
        return _devices
    }
    
    func connect(device:CBPeripheral) {
        _hvc.connect(device)
    }
    
    func disconnect() {
        _hvc.disconnect()
    }
    
    func onConnected() {
        println("@@@=Connected")
        NSNotificationCenter.defaultCenter().postNotificationName(
            EVENT_DEVICE_CONNECTED,
            object: nil
        )
    }
    
    func onDisconnected() {
        println("@@@=Disconnected")
        NSNotificationCenter.defaultCenter().postNotificationName(
            EVENT_DEVICE_DISCONNECTED,
            object: nil
        )
    }
    
    func onPostExecute(result: HVC_RES!, errcode err: HVC_ERRORCODE, status outStatus: UInt8) {
        println("@@@=onPostExecute \(result)")
    }
    
    func onPostGetDeviceName(value: NSData!) {
        println("@@@=onPostGetDeviceName \(value)")
    }
    
    func onPostGetParam(param: HVC_PRM!, errcode err: HVC_ERRORCODE, status outStatus: UInt8) {
        println("@@@=onPostGetParam \(param)")
    }
    
    func onPostGetVersion(ver: HVC_VER!, errcode err: HVC_ERRORCODE, status outStatus: UInt8) {
        println("@@@=onPostGetVersion \(ver)")
    }
    
    func onPostSetParam(err: HVC_ERRORCODE, status outStatus: UInt8) {
        println("@@@=onPostSetParam")
    }
}
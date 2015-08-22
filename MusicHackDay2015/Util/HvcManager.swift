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
    private var _executeFlag:HVC_FUNCTION!
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
        
        //パラメータセット
        let param = HVC_PRM()
        param.face().setMinSize(60)
        param.face().setMaxSize(480)
        _hvc.setParam(param)
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
        
        var data:Dictionary = Dictionary<String, [Dictionary<String, Int32>]>()
        if err == HVC_ERRORCODE.NORMAL && outStatus == 0 {
            // Human body detection
            var humanBody:[Dictionary<String, Int32>] = [Dictionary<String, Int32>]()
            for i:Int32 in 0..<result.sizeBody() {
                let dt = result.body(i)
                humanBody.append([
                    "size": dt.size(),
                    "x": dt.posX(),
                    "y": dt.posY(),
                    "confidence": dt.confidence()
                ])
            }
            data["HumanBody"] = humanBody
            
            // Hand detection
            var hand:[Dictionary<String, Int32>] = [Dictionary<String, Int32>]()
            for i:Int32 in 0..<result.sizeHand() {
                let dt = result.hand(i)
                hand.append([
                    "size": dt.size(),
                    "x": dt.posX(),
                    "y": dt.posY(),
                    "confidence": dt.confidence()
                ])
            }
            data["Hand"] = hand
            
            //Face
            var face:[Dictionary<String, Int32>] = [Dictionary<String, Int32>]()
            var age:[Dictionary<String, Int32>] = [Dictionary<String, Int32>]()
            var gender:[Dictionary<String, Int32>] = [Dictionary<String, Int32>]()
            var gaze:[Dictionary<String, Int32>] = [Dictionary<String, Int32>]()
            var blink:[Dictionary<String, Int32>] = [Dictionary<String, Int32>]()
            var exp:[Dictionary<String, Int32>] = [Dictionary<String, Int32>]()
            
            for i:Int32 in 0..<result.sizeFace() {
                let fd = result.face(i)
                face.append([
                    "size": fd.size(),
                    "x": fd.posX(),
                    "y": fd.posY(),
                    "confidence": fd.confidence(),
                    "yaw": fd.dir().yaw(),
                    "pitch": fd.dir().pitch(),
                    "roll": fd.dir().roll(),
                    "dir_confidence": fd.dir().confidence()
                ])
                
                age.append([
                    "age": fd.age().age(),
                    "confidence": fd.age().confidence()
                ])
                
                var g:Int32 = 0
                if fd.gen().gender() == HVC_GENDER.GEN_MALE {
                    g = 1
                }
                gender.append([
                    "gender": g,
                    "confidence": fd.gen().confidence()
                ])
                
                gaze.append([
                    "LR": fd.gaze().gazeLR(),
                    "UD": fd.gaze().gazeUD()
                ])
                
                blink.append([
                    "ratioL": fd.blink().ratioL(),
                    "ratioR": fd.blink().ratioR()
                ])
                
                var e:Int32 = 0
                switch fd.exp().expression() {
                case HVC_EXPRESSION.EX_NEUTRAL:
                    e = 1
                    break
                case HVC_EXPRESSION.EX_HAPPINESS:
                    e = 2
                    break
                case HVC_EXPRESSION.EX_SURPRISE:
                    e = 3
                    break
                case HVC_EXPRESSION.EX_ANGER:
                    e = 4
                    break
                case HVC_EXPRESSION.EX_SADNESS:
                    e = 5
                    break
                default:
                    break
                }
                
                exp.append([
                    "expression": e,
                    "score": fd.exp().score(),
                    "degree": fd.exp().degree()
                ])
            }
            data["Face"] = face
            data["Age"] = age
            data["Gender"] = gender
            data["Gaze"] = gaze
            data["Blink"] = blink
            data["Exp"] = exp
        }
        
        //データ送出
        NSNotificationCenter.defaultCenter().postNotificationName(EVENT_DEVICE_RECEIVE_DATA, object: data as? AnyObject)
        
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            self._hvc.Execute(self._executeFlag, result: result)
        });
        
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
        
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            self._executeFlag = HVC_FUNCTION.ACTIV_BODY_DETECTION
                | HVC_FUNCTION.ACTIV_HAND_DETECTION
                | HVC_FUNCTION.ACTIV_FACE_DETECTION
                | HVC_FUNCTION.ACTIV_FACE_DIRECTION
                | HVC_FUNCTION.ACTIV_AGE_ESTIMATION
                | HVC_FUNCTION.ACTIV_GENDER_ESTIMATION
                | HVC_FUNCTION.ACTIV_GAZE_ESTIMATION
                | HVC_FUNCTION.ACTIV_BLINK_ESTIMATION
                | HVC_FUNCTION.ACTIV_EXPRESSION_ESTIMATION
            
            let res = HVC_RES()
            self._hvc.Execute(self._executeFlag, result: res)
        })
    }
}
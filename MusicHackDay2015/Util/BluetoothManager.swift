//
//  BluetoothManager.swift
//  MusicHackDay2015
//
//  Created by ichikawa on 2015/08/21.
//  Copyright (c) 2015年 yuruga. All rights reserved.
//


import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //シングルトン
    static let sharedInstance = BluetoothManager()
    
    static let EVENT_SCAN_UPDATE = "event_scan_update"
    static let EVENT_SCAN_STATE_CHANGE = "event_scan_state_change"
    static let EVENT_RECEIVE_VALUE = "event_receive_value"
    
    //スキャンタイマー
    let _scanTime = 15.0
    var _timer: NSTimer!
    
    //BLE利用可能判定
    var _bleEnable = false
    
    //BLEスキャン状態
    var _scanActive = false
    var scanActive: Bool {
        get {
            return _scanActive
        }
    }
    
    //BLEサービスUUID
    let _serviceUUID = CBUUID(string: Share.getConfigValueWithKey("ServiceUUID"))
    
    //BLEマネージャ
    var _centralManager: CBCentralManager!
    
    //ペリフェラルリスト
    var _peripherals: [CBPeripheral] = []
    var peripherals:[CBPeripheral] {
        get {
            return _peripherals
        }
    }
    
    //選択中のペリフェラル
    var _peripheral: CBPeripheral!
    var peripheral: CBPeripheral {
        get {
            return _peripheral
        }
        set(val) {
            _peripheral = val
        }
    }
    
    override init () {
        super.init()
        self._centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    deinit {
        self._centralManager.delegate = nil
    }
    
    func connect() {
        if self._peripheral?.state == CBPeripheralState.Disconnected {
            println("Try Connect")
            self._peripheral?.delegate = self
            self._centralManager.connectPeripheral(self._peripheral, options: nil)
        } else if self._peripheral?.state == CBPeripheralState.Connecting {
            println("Connecting")
        }
    }
    
    func disconnect() {
        if (self._peripheral?.state == CBPeripheralState.Connected) {
            println("Try Disconnect")
            self._peripheral.delegate = nil
            self._centralManager.cancelPeripheralConnection(self._peripheral)
            return
        }
    }
    
    func startScan() {
        //有効判定
        if !self._bleEnable || self._scanActive { return }
        
        self._scanActive = true
        
        //リストをクリア
        self._peripheral = nil
        self._peripherals = []
        
        //ペリフェラルリスト更新通知
        NSNotificationCenter.defaultCenter().postNotificationName(BluetoothManager.EVENT_SCAN_UPDATE, object: nil)
        
        //周囲のペリフェラルデバイスを探索
        self._centralManager.scanForPeripheralsWithServices([self._serviceUUID], options: nil)
        
        //スキャン状態変化通知
        NSNotificationCenter.defaultCenter().postNotificationName(BluetoothManager.EVENT_SCAN_STATE_CHANGE, object: nil)
        
        //一定秒後にスキャン停止
        _timer?.invalidate()
        _timer = NSTimer.scheduledTimerWithTimeInterval(
            _scanTime,
            target: self,
            selector: "stopScan",
            userInfo: nil,
            repeats: false
        )
    }
    
    func stopScan() {
        _timer?.invalidate()
        self._centralManager.stopScan()
        self._scanActive = false
        
        //スキャン状態変化通知
        NSNotificationCenter.defaultCenter().postNotificationName(BluetoothManager.EVENT_SCAN_STATE_CHANGE, object: nil)
    }
    
    //BLEステータス変化通知
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        self._bleEnable = false
        switch central.state {
        case .PoweredOn:
            println("PoweredOn")
            self._bleEnable = true
            self.startScan()
            break
        case .PoweredOff:
            println("PoweredOff")
            break
        case .Resetting:
            println("Resetting")
            self._bleEnable = true
            break
        case .Unauthorized:
            println("Unauthorized")
            break
        case .Unsupported:
            println("Unsupported")
            break
        default:
            println("Other state")
            break
        }
    }
    
    // ペリフェラルのスキャン結果
    func centralManager(central: CBCentralManager!,
        didDiscoverPeripheral peripheral: CBPeripheral!,
        advertisementData: [NSObject : AnyObject]!,
        RSSI: NSNumber!)
    {
        println("scan peripheral: \(peripheral.identifier)")
        println(advertisementData)
        println(RSSI)
        
        //取得したペリフェラルを追加
        for p in self._peripherals {
            if p.identifier.UUIDString == peripheral.identifier.UUIDString {
                return
            }
        }
        self._peripherals.append(peripheral)
        
        //ペリフェラルリスト更新通知
        NSNotificationCenter.defaultCenter().postNotificationName(BluetoothManager.EVENT_SCAN_UPDATE, object: nil)
    }
    
    
    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(central: CBCentralManager!,
        didConnectPeripheral peripheral: CBPeripheral!)
    {
        println("Connected!")
        
        //サービス取得
        self.peripheral.discoverServices([_serviceUUID])
    }
    
    // ペリフェラルへの接続が失敗すると呼ばれる
    func centralManager(central: CBCentralManager!,
        didFailToConnectPeripheral peripheral: CBPeripheral!,
        error: NSError!)
    {
        println("Connect Failed...")
    }
    
    //サービスの探索結果
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if (error != nil) {
            println("error: \(error)")
            return
        }
        
        let services: [CBService] = peripheral.services as! [CBService]
        println(self.peripheral.services.count)
        println("Services Found \(services.count)")
        for service in services {
            println(service.UUID.UUIDString)
            //let characteristicUUID = CBUUID(string: "648DEBD8-2732-4A98-98C3-E9AA6B8424B0")
            //TODO: UUID限定化
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    //キャラクタリスティック探索結果を取得する
    func peripheral(peripheral: CBPeripheral!,
        didDiscoverCharacteristicsForService service: CBService!,
        error: NSError!)
    {
        if (error != nil) {
            println("error: \(error)")
            return
        }
        
        let characteristics: [CBCharacteristic] = service.characteristics as! [CBCharacteristic]
        println("Characteristics Found \(characteristics.count)")
        for characteristic in characteristics {
            println(characteristic.UUID.UUIDString)
            peripheral.readValueForCharacteristic(characteristic)
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
        }
    }
    
    //キャラクタリスティックの値取得
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        let data: NSData = characteristic.value
        
        //キャラクタリスティックの値通知
        NSNotificationCenter.defaultCenter().postNotificationName(BluetoothManager.EVENT_RECEIVE_VALUE, object: data)
    }
    
}

//
//  ViewController.swift
//  MusicHackDay2015
//
//  Created by ichikawa on 2015/08/21.
//  Copyright (c) 2015年 yuruga. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIPopoverControllerDelegate {

    @IBOutlet weak var btnRefresh: UIBarButtonItem!
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var label001: UILabel!
    @IBOutlet weak var label002: UILabel!
    @IBOutlet weak var label003: UILabel!
    @IBOutlet weak var label004: UILabel!
    @IBOutlet weak var label005: UILabel!
    @IBOutlet weak var label006: UILabel!
    
    
    
    private var _audio: SPTCoreAudioController?
    private var _player: SPTAudioStreamingController?
    
    //MARK: delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //既存の接続を切る
        HvcManager.defaultInstance().disconnect()
        
        btnPlay.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.showAuth()
        //self.requestAuthToPlay()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "connectedDevice:",
            name: EVENT_DEVICE_CONNECTED,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "disconnectedDevice:",
            name: EVENT_DEVICE_DISCONNECTED,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "showDevices:",
            name: EVENT_DEVICE_SCAN_FINISH,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "updateDeviceData:",
            name: EVENT_DEVICE_RECEIVE_DATA,
            object: nil
        )
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchDevices(sender: AnyObject) {
        if btnRefresh.tag == 0 {
            HvcManager.defaultInstance().deviceSearch()
        }else{
            HvcManager.defaultInstance().disconnect()
        }
        btnRefresh.enabled = false
    }
    @IBAction func audioPlay(sender: AnyObject!) {
        btnPlay.setTitle("Play", forState: UIControlState.Normal)
        if btnPlay.titleLabel?.text == "Play" {
            AudioManager.defaultInstance().play()
            btnPlay.setTitle("Pause", forState: UIControlState.Normal)
        }else{
            AudioManager.defaultInstance().pause()
            btnPlay.setTitle("Play", forState: UIControlState.Normal)
        }
    }
    
    func connectedDevice(notification:NSNotification){
        btnRefresh.title = "Disconnect"
        btnRefresh.tag = 1
        btnRefresh.enabled = true
        btnPlay.enabled = true
    }
    
    func disconnectedDevice(notification:NSNotification){
        btnRefresh.title = "Connect"
        btnRefresh.tag = 0
        btnRefresh.enabled = true
        btnPlay.enabled = false
        
        AudioManager.defaultInstance().pause()
        btnPlay.setTitle("Play", forState: UIControlState.Normal)
    }
    
    func showDevices(notification:NSNotification){
        let devices = HvcManager.defaultInstance().getDevices()
        
        let title = "devices"
        var message = "found devices"
        if devices.count <= 0 {
            message = "not found devices"
        }

        //UIAlertController使用
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        for i in 0..<devices.count {
            let d = devices[i]
            let selectAction = UIAlertAction(
                title: devices[i].name,
                style: .Default) { (action) -> Void in
                    println("AddAction Tap \(i)")
                    HvcManager.defaultInstance().connect(d)
                }
            ac.addAction(selectAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            println("Cancel button tapped.")
        }
        ac.addAction(cancelAction)
        
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    //デバイスデータ更新
    func updateDeviceData(notification:NSNotification){
        
        var data = HvcManager.defaultInstance().getDeviceData()
        if data != nil {
            println("====001")
            /*
            if data["HumanBody"]?.count > 0 {
                let bodies = data["HumanBody"]
                let imax = min(bodies!.count, 2)
                for i:Int in 0..<imax {
                    let body = bodies![i]
                    println("====002")
                    println("===> \(body)")
                    var size = body["size"]! as Int32
                    let sizeScale = Float(max(min(size, 300), 0)) / 300 * 100
                    AudioManager.defaultInstance().getAudio(i).volume(sizeScale)
                    println("@@@= \(sizeScale)")
                    
                    
                    let x = body["x"]! as Int32
                    let y = body["y"]! as Int32
                    if i == 0 {
                        label001.text = String(size as Int32)
                        label002.text = String(x as Int32)
                        label003.text = String(y as Int32)
                    }
                }
                
            }
            */
            
            //減衰
            AudioManager.defaultInstance().getAudio(0).volume(
                AudioManager.defaultInstance().getAudio(0).getVolume() * 0.75
            )
            AudioManager.defaultInstance().getAudio(1).volume(
                AudioManager.defaultInstance().getAudio(1).getVolume() * 0.75
            )
            
            if data["Face"]?.count > 0 {
                let faces = data["Face"]
                let imax = min(faces!.count, 2)
                for i:Int in 0..<imax {
                    let face = faces![i]
                    var size = face["size"]! as Int32
                    
                    let sizeScale = Float(max(min(size - HVC_FACE_MIN, 256), 0)) / 256 * 100
                    AudioManager.defaultInstance().getAudio(i).volume(sizeScale)
                    
                    var yaw = face["yaw"]! as Int32
                    var pitch = face["pitch"]! as Int32
                    var roll = face["roll"]! as Int32
                    
                    let yawSize = Float(max(min(yaw, 30), -30)) / 30
                    AudioManager.defaultInstance().getAudio(i).pan(yawSize)
                    
                    let pitchSize = Float(max(min(abs(pitch), 50), 0)) / 50 * 8000
                    AudioManager.defaultInstance().getAudio(i).hipass(pitchSize)
                    
                    let rollSize = Float(max(min(abs(roll), 15), 0)) / 15 * 80
                    AudioManager.defaultInstance().getAudio(i).distortion(rollSize)
                    
                    if i == 0 {
                        label001.text = String(yaw)
                        label002.text = String(pitch)
                        label003.text = String(roll)
                    }else{
                        label004.text = String(yaw)
                        label005.text = String(pitch)
                        label006.text = String(roll)
                    }
                }
            }
            
        }
    }

    /*
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
*/
    
    
/**
    volume: 0 ~ 100
    pan: -1 ~ 1　※左-右
    distortion: 0 ~100
    distortionGain: -10~0(?) ※distortionの感じが変わる
    reverb : 0 ~100
    delay : 0~100
    delayTime : 0~2 ※delayの間隔(秒)
    hipass : 0~20000位？※この周波数以上を通す(Hz)
    lowpass : 0~20000位？※この周波数以下を通す(Hz)
    
    が実装されてるはずです
    
    AudioManger.defaultInstance.getAudio(0).volume(50)
**/
    
    
    

    
    
    
    
    
    
    
    
    
    
    
//================= 未使用 ====================
    
    
    //MARK: instance methods
    func showAuth() {
        
        SpotifyManager.defaultInstance().showLoginView(
            self,
            callbackSuccess: { (session: SPTSession) -> Void in
                
                //TODO: ローカルストレージにトークン保存する用
                let session = SpotifyManager.defaultInstance().createSession(session.accessToken)
                
                //決めトラック
                let trackStr = "spotify:track:58s6EuEYJdlb0kO7awm3Vp"
                
                //再生
                self.playWithSession(session, track: trackStr)
                
            },
            callbackFail: { () -> Void in
                println("login fail...")
            
            }) { () -> Void in
                println("login cancel...")
            }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //再生
    func playWithSession(session: SPTSession!, track: String) {
        //オーディオコントロール
        _audio = SPTCoreAudioController()
        
        //ストリームコントロール
        _player = SPTAudioStreamingController(
            clientId: SPT_CLIENT_ID,
            audioController: _audio
        )
        
        //ログイン
        _player?.loginWithSession(session, callback: { (err: NSError!) -> Void in
            if err != nil {
                println("error: \(err.localizedDescription)")
            }else{
                let track = NSURL(string: track)
                let arr: [AnyObject] = [track as! AnyObject]
                self._player?.playURIs(arr, fromIndex: 0, callback: { (err: NSError!) -> Void in
                    if err != nil {
                        println("error: \(err.localizedDescription)")
                    }else{
                        println("PlayMusic")
                        self._audio?.volume = 1.0
                    }
                })
            }
        })
        /*
        _player?.loginWithSession(session, callback: { (err: NSError!) -> Void in
            if err != nil {
                println("error: \(err.localizedDescription)")
            }else{
                let track = NSURL(string: track)
                let arr: [AnyObject] = [track as! AnyObject]
                self._player?.playURIs(arr, fromIndex: 0, callback: { (err: NSError!) -> Void in
                    if err != nil {
                        println("error: \(err.localizedDescription)")
                    }else{
                        println("PlayMusic")
                        self._audio?.volume = 1.0
                    }
                })
            }
        })
        */
    }
}


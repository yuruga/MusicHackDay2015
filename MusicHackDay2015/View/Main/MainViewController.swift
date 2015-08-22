//
//  ViewController.swift
//  MusicHackDay2015
//
//  Created by ichikawa on 2015/08/21.
//  Copyright (c) 2015年 yuruga. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController, UITableViewDataSource, UIPopoverControllerDelegate {

    @IBOutlet weak var btnRefresh: UIBarButtonItem!
    
    private var _audio: SPTCoreAudioController?
    private var _player: SPTAudioStreamingController?
    
    //MARK: delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //既存の接続を切る
        HvcManager.defaultInstance().disconnect()
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
    
    func connectedDevice(notification:NSNotification){
        btnRefresh.title = "Disconnect"
        btnRefresh.tag = 1
        btnRefresh.enabled = true
    }
    
    func disconnectedDevice(notification:NSNotification){
        btnRefresh.title = "Connect"
        btnRefresh.tag = 0
        btnRefresh.enabled = true
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


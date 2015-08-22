//
//  ViewController.swift
//  MusicHackDay2015
//
//  Created by ichikawa on 2015/08/21.
//  Copyright (c) 2015年 yuruga. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController, UITableViewDataSource {

    private var _audio: SPTCoreAudioController?
    private var _player: SPTAudioStreamingController?
    
    //MARK: delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.showAuth()
        //self.requestAuthToPlay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


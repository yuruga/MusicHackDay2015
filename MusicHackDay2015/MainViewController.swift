//
//  ViewController.swift
//  MusicHackDay2015
//
//  Created by ichikawa on 2015/08/21.
//  Copyright (c) 2015年 yuruga. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController, UITableViewDataSource {
    
//    private static let _USERNAME = "xlune999"
//    private static let _CLIENT_ID = "963b6a541b954022bc4b4355c33978c8"
//    private static let _ACCESS_TOKEN = "BQDzF8zy5RjMCzLI1DTHPs9JMH3hJozSQDiYhXbE8USavziO0dS4ectgP97ai1x0jcNhCO0EgsbKptAfBfsH0w"
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

//    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
//        println("didFailToLogin")
//    }
//    
//    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
//        println("didLoginWithSession")
//        
//        self.createSessionToPlay(session.accessToken)
//    }
//    
//    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
//       println("cancel")
//    }
    
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
                SpotifyManager.defaultInstance().playTrackWithSession(
                    session,
                    track: trackStr,
                    callbackSuccess: { (stream: SPTAudioStreamingController, audio: SPTCoreAudioController) -> Void in
                    
                    
                    }, callbackFail: { (error: NSError) -> Void in
                    
                    }
                )
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
    /*
    func requestAuthToPlay() {
        //Spotify
        let auth = SPTAuth.defaultInstance()
        auth.clientID = SPT_CLIENT_ID
        auth.redirectURL = NSURL(string: "yurugamhd://callback")
        auth.requestedScopes = [SPTAuthStreamingScope]
        
        //認証用URL
        let loginUrl = auth.loginURL
        
        //ブラウザ表示
        delay(0.1) {
            if UIApplication.sharedApplication().canOpenURL(loginUrl!){
                UIApplication.sharedApplication().openURL(loginUrl!)
            }
            return
        }
    }
    
    func receiveAuth(url: NSURL!) {
        if SPTAuth.defaultInstance().canHandleURL(url) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (err: NSError!, session: SPTSession!) -> Void in
                if err != nil {
                    println("Auth Error: \(err.localizedDescription)")
                    return
                }
                
                //再生
                self.playWithSession(session)
            })
        }
    }


    
    func createSessionToPlay(token: String!) {
        //セッション取得
        let session = SPTSession(
            userName: SPT_USERNAME,
            accessToken: token,
            expirationTimeInterval: 7*24*60*60
        )
        
        //再生
        self.playWithSession(session)
    }

    func playWithSession(session: SPTSession!) {
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
                let track = NSURL(string: "spotify:track:58s6EuEYJdlb0kO7awm3Vp")
                let arr: [AnyObject] = [track as! AnyObject]
                self._player?.playURIs(arr, fromIndex: 0, callback: { (err: NSError!) -> Void in
                    if err != nil {
                        println("error: \(err.localizedDescription)")
                    }
                    println("PlayMusic")
                })
            }
        })
    }
*/

}


//
//  SpotifyManager.swift
//  MusicHackDay2015
//
//  Created by ichikawa on 2015/08/22.
//  Copyright (c) 2015年 yuruga. All rights reserved.
//

import Foundation

class SpotifyManager: NSObject, SPTAuthViewDelegate {
    
    //MARK: Singleton
    private override init() {
        
    }
    static let _instance = SpotifyManager()
    static func defaultInstance() -> (SpotifyManager) {
        return _instance;
    }
    
    //ログイン用コールバック
    private var _loginSuccessFunc:((SPTSession)->Void)!
    private var _loginFailFunc:(()->Void)!
    private var _loginCancelFunc:(()->Void)!
    
    //ログイン
    func showLoginView(
        parentVC: UIViewController!,
        callbackSuccess: (SPTSession)->Void,
        callbackFail: ()->Void,
        callbackCancel: ()->Void){
            
            _loginSuccessFunc = callbackSuccess
            _loginFailFunc = callbackFail
            _loginCancelFunc = callbackCancel
            
            let auth = SPTAuth.defaultInstance()
            auth.clientID = SPT_CLIENT_ID
            auth.redirectURL = NSURL(string: "yurugamhd://callback")
            auth.requestedScopes = [SPTAuthStreamingScope]
            
            let vc = SPTAuthViewController.authenticationViewControllerWithAuth(auth)
            vc.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            parentVC.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            parentVC.definesPresentationContext = true
            
            vc.clearCookies { () -> Void in
                parentVC.presentViewController(vc, animated: true, completion: nil)
            }
    }
    
    //セッション作成
    func createSession(accessToken: String) -> (SPTSession) {
        //セッション取得
        return SPTSession(
            userName: SPT_USERNAME,
            accessToken: accessToken,
            expirationTimeInterval: 7*24*60*60
        )
    }
    
    //MARK: delegate
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        println("didLoginWithSession")
        self._loginSuccessFunc(session)
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        println("didFailToLogin")
        self._loginFailFunc()
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        println("cancel")
        self._loginCancelFunc()
    }
}
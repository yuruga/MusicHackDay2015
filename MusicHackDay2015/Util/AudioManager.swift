//
//  AudioManager.swift
//  MusicHackDay2015
//
//  Created by MAEDA Naohito on 2015/08/22.
//  Copyright (c) 2015年 yuruga. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AudioManager : NSObject{
    
    //@IBOutlet weak var buttonPlay: UIButton!
    
    //MARK: Singleton
    
    static let _instance = AudioManager()
    static func defaultInstance() -> (AudioManager) {
        return _instance;
    }
    
    private var _audios:[Audio]
    
    private let audioEngine: AVAudioEngine!
    
    private var audioFile: AVAudioFile!
    private var audioFile2: AVAudioFile!
    
    class Audio:NSObject{
        private var _audioFilePlayer:AVAudioPlayerNode
        private var _audioFile:AVAudioFile
        private var _audioReverb: AVAudioUnitReverb!
        private var _audioDistortion: AVAudioUnitDistortion!
        private var _audioBandFilter: AVAudioUnitEQ
        private var _audioDelay: AVAudioUnitDelay!
        
        init(audioFile:AVAudioFile, audioEngine:AVAudioEngine){
            // AVPlayerNodeの生成
            _audioFilePlayer = AVAudioPlayerNode()
            _audioFile = audioFile
            
            
            // ReverbNodeの生成
            _audioReverb = AVAudioUnitReverb()
            _audioReverb.loadFactoryPreset(.LargeHall)
            _audioReverb.wetDryMix = 0
            
            //Distortionの作成
            _audioDistortion = AVAudioUnitDistortion()
            _audioDistortion.loadFactoryPreset(.MultiDistortedSquared)
            _audioDistortion.preGain = -0
            _audioDistortion.wetDryMix = 0
            
            //delayの作成
            _audioDelay = AVAudioUnitDelay()
            _audioDelay.delayTime = 0.2
            _audioDelay.feedback = 2
            _audioDelay.lowPassCutoff = 15000
            _audioDelay.wetDryMix = 0
            
            //badnFilterの作成
            _audioBandFilter = AVAudioUnitEQ(numberOfBands: 2)
            var bandfilterParams = _audioBandFilter.bands[0] as! AVAudioUnitEQFilterParameters
            bandfilterParams.filterType = .HighPass
            bandfilterParams.frequency = 0
            bandfilterParams.bypass = false
            bandfilterParams = _audioBandFilter.bands[1] as! AVAudioUnitEQFilterParameters
            bandfilterParams.filterType = .LowPass
            bandfilterParams.frequency = 40000
            bandfilterParams.bypass = false
            
            
            // AVPlayerNodeをAVAudioEngineへ追加
            audioEngine.attachNode(_audioFilePlayer)
            audioEngine.attachNode(_audioReverb)
            audioEngine.attachNode(_audioDistortion)
            audioEngine.attachNode(_audioDelay)
            audioEngine.attachNode(_audioBandFilter)
            
            
            // AVPlayerNodeをAVAudioEngineへ
            audioEngine.connect(_audioFilePlayer, to: _audioDistortion, format: _audioFile.processingFormat)
            audioEngine.connect(_audioReverb, to: _audioBandFilter, format: _audioFile.processingFormat)
            audioEngine.connect(_audioDistortion, to: _audioDelay, format: _audioFile.processingFormat)
            audioEngine.connect(_audioDelay, to: _audioReverb, format: _audioFile.processingFormat)
            audioEngine.connect(_audioBandFilter, to: audioEngine.mainMixerNode, format: _audioFile.processingFormat)
        }
        func delay(wet:Float){
            _audioDelay.wetDryMix = wet
        }
        func delayTime(time:NSTimeInterval){
            _audioDelay.delayTime = time
        }
        func reverb(wet:Float){
            _audioReverb.wetDryMix = wet
        }
        func distortion(wet:Float){
            _audioDistortion.wetDryMix = wet
        }
        func distortionGain(gain:Float){
            _audioDistortion.preGain = gain
        }

        func hipass(freq:Float){
            var bandfilterParams = _audioBandFilter.bands[0] as! AVAudioUnitEQFilterParameters
            bandfilterParams.filterType = .HighPass
            bandfilterParams.frequency = freq
            bandfilterParams.bypass = false
        }
        func lowpass(freq:Float){
            var bandfilterParams = _audioBandFilter.bands[1] as! AVAudioUnitEQFilterParameters
            bandfilterParams.filterType = .LowPass
            bandfilterParams.frequency = freq
            bandfilterParams.bypass = false
        }
        func volume(val:Float){
            _audioFilePlayer.volume = val
        }
        func pan(val:Float){
            _audioFilePlayer.pan = val
        }
        func play(){
            _audioFilePlayer.scheduleFile(_audioFile, atTime: nil, completionHandler: nil)
            _audioFilePlayer.play()
        }
        func pause(){
            if(_audioFilePlayer.playing){
                _audioFilePlayer.pause()
            }
        }
    }
    
    
    
    
    
    private override init() {
        //super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _audios = []
        
        
        // AVAudioEngineの生成
        audioEngine = AVAudioEngine()
        
        
        
        // AVAudioFileの生成
        audioFile = AVAudioFile(forReading: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("audio/track1", ofType: "mp3")!), error: nil)
        audioFile2 = AVAudioFile(forReading: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("audio/track2", ofType: "mp3")!), error: nil)
        
        _audios.append(Audio(audioFile: audioFile, audioEngine: audioEngine))
        _audios.append(Audio(audioFile: audioFile2, audioEngine: audioEngine))
        
        
        // AVAudioEngineの開始
        audioEngine.startAndReturnError(nil)
    }
    
    func getAudio(index:Int) -> Audio{
        return _audios[index]
    }
    
    func play(){
//        audioFilePlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
//        audioFilePlayer.play()
//        
//        audioFilePlayer2.scheduleFile(audioFile2, atTime: nil, completionHandler: nil)
//        audioFilePlayer2.play()
        
        for audio in _audios{
            audio.play()
        }
        //_audios[0].play()
    }
    
    func pause(){
        for audio in _audios{
            audio.pause()
        }
    }
    
    
}
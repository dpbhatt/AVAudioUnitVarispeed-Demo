//
//  ViewController.swift
//  AudioSpeedDemo
//
//  Created by TekTak on 03/06/2018.
//  Copyright © 2018 Sensus. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var engine = AVAudioEngine()
    
    var audioPlayer = AVAudioPlayerNode()
    var speedIncrement = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        speedLabel.text = "rate \(speedSlider.value)"
        if(pitchSwitch.isOn){
        pitchLabel.text = "pitch \(Float(speedIncrement * (-500)))"
        } else{
            pitchLabel.text = ""
        }
        volumeLabel.text = "volume \(speedSlider.value * 10.0)"
    }
    
    @IBOutlet weak var pitchSwitch: UISwitch!
    @IBAction func speedSlider(_ sender: UISlider) {
        speedIncrement = Double(sender.value)
        speedLabel.text = "rate \(speedSlider.value)"
        if(pitchSwitch.isOn){
             pitchLabel.text = "pitch \(Float(speedIncrement * (-500)))"
        } else {
            pitchLabel.text = ""
        }
       
        volumeLabel.text = "volume \(speedSlider.value * 10.0)"
        audioPlayer.volume = speedSlider.value * 10.0
        Play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var volumeLabel: UILabel!
    
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBAction func playSound(_ sender: UIButton) {
        Play()
    }
    func Play() {
        engine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()
        audioPlayer.volume = 10.0
        
        let path = Bundle.main.path(forResource: "Beep", ofType: "wav")!
        let url = NSURL.fileURL(withPath: path)
        
        let file = try? AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(pcmFormat: file!.processingFormat, frameCapacity: AVAudioFrameCount(file!.length))
        do {
            try file!.read(into: buffer!)
        } catch _ {
        }
        
        let pitch = AVAudioUnitTimePitch()
        let speed = AVAudioUnitVarispeed()
        
        print(pitchSwitch.isOn)
        
        if (pitchSwitch.isOn){
            pitch.pitch =  Float(speedIncrement * (-500))
          
        }
        
        speed.rate = Float(speedIncrement)
        //pitch.overlap = 32 // 3.0 - 32.0
        engine.attach(audioPlayer)
        
        if (pitchSwitch.isOn){
            engine.attach(pitch)
        }
        engine.attach(speed)
        
        engine.connect(audioPlayer, to: speed, format: buffer?.format)
        if (pitchSwitch.isOn){
            engine.connect(speed, to: pitch, format: buffer?.format)
        }
        if (!pitchSwitch.isOn){
            engine.connect(speed, to: engine.mainMixerNode, format: buffer?.format)
              pitchLabel.text = ""
        } else {
            engine.connect(pitch, to: engine.mainMixerNode, format: buffer?.format)
             pitchLabel.text = "pitch \(Float(speedIncrement * (-500)))"
        }
        audioPlayer.scheduleBuffer(buffer!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
        
        engine.prepare()
        do {
            try engine.start()
        } catch _ {
        }
        
        audioPlayer.play()
        
    }
}

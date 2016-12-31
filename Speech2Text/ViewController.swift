//
//  ViewController.swift
//  Speech2Text
//
//  Created by Abed on 28/12/2016.
//  Copyright © 2016 Webiaturist. All rights reserved.
//

import UIKit
import AVFoundation
import Speech 

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var TextField: UITextView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var microphoneBtn: UIButton!
    @IBOutlet weak var guideTextLabel: UILabel!
    
    // Telling Apple that the language is English
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    let myBtnColor = UIColor(red: 140, green: 255, blue: 3, alpha: 1)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        
        microphoneBtn.isEnabled = false
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization{ (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus{
                
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                
            case .notDetermined:
                isButtonEnabled = false
                
            default:
                isButtonEnabled = false
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneBtn.isEnabled = isButtonEnabled
            }
            
        }
        
    }
    
    
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.TextField.text = result?.bestTranscription.formattedString 
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.microphoneBtn.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available{
            microphoneBtn.isEnabled = true
        } else{
            microphoneBtn.isEnabled = false
        }
    }
    

    
    @IBAction func microphoneTapped(_ sender: Any) {
        if audioEngine.isRunning{
            audioEngine.stop()
            guideTextLabel.text = "Continue recording"
            activitySpinner.stopAnimating()
            activitySpinner.isHidden = true
            recognitionRequest?.endAudio()
            microphoneBtn.isEnabled = false
            microphoneBtn.backgroundColor = UIColor.init(colorLiteralRed: 140.0/255, green: 255.0/255, blue: 3.0/255, alpha: 1.0)
            
        } else{
            startRecording()
            guideTextLabel.text = "Say something, I'm listening!"
            microphoneBtn.backgroundColor = UIColor.red
            activitySpinner.isHidden = false
            activitySpinner.startAnimating()
        }
    }

    
    
    /*
     func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
     player.stop()
     activitySpinner.stopAnimating()
     activitySpinner.isHidden = true
     }
     
     func requestSpeechAuth(){
     SFSpeechRecognizer.requestAuthorization { authStatus in
     if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized{
     if let path = Bundle.main.url(forResource: "test", withExtension: "m4a"){
     do {
     let sound = try AVAudioPlayer(contentsOf: path)
     self.audioPlayer = sound
     self.audioPlayer.delegate = self
     sound.play()
     } catch{
     print("Error!")
     }
     
     let recognizer = SFSpeechRecognizer()
     let request = SFSpeechURLRecognitionRequest(url: path)
     recognizer?.recognitionTask(with: request){ (result, error) in
     if let error = error{
     print("There was an error: \(error)")
     } else{
     self.TextField.text = result?.bestTranscription.formattedString
     }
     }
     }
     }
     }
     }
     */
}










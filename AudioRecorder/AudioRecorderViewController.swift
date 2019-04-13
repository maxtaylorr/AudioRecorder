//
//  AudioRecorderViewController.swift
//  AudioRecorder
//
//  Created by Max Taylor on 4/12/19.
//  Copyright © 2019 Max Taylor. All rights reserved.
//

import UIKit
import AVKit

class AudioRecorderViewController: UIViewController, AVAudioRecorderDelegate, UIToolbarDelegate, AVAudioPlayerDelegate {
    

    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var images = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() {
                [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.images = self.loadUIButtons()
                        
                    } else {
                    // don't let the app record because permission was denied
                    }
                }
            }
        } catch {
            print("Failed to record!")
        }
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @IBAction func playTapped(_ sender: Any) {
        if audioPlayer?.isPlaying == false {
            startPlaying()
        } else {
            finishPlaying()
        }
    }
    
    
    func loadUIButtons() -> [UIImage?] {
        let playImage = UIImage(named: "play")
        playButton.image = playImage
        
        let recordImage = UIImage(named: "record")
        recordButton.image = recordImage
        
        let pauseImage = UIImage(named: "pause")
        let stopImage = UIImage(named: "stop")
        
        let images = [pauseImage, stopImage, playImage, recordImage]
        return images
    }
    
    func startRecording() {
        let audioFileName = "audio.caf"
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(audioFileName)
        recordButton.image = images[0]

        
        let recordingSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: recordingSettings)
            audioRecorder.delegate = self
            audioRecorder.record() // everytime this is called i get ca_debug_string inPropertyData == NULL
        } catch {                  // couldn't figure out how to fix this even after researching for some time
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.image = images[3]
        } else {
            recordButton.image = images[3]
            print("Failed to record ):")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func startPlaying() {
        do {
            if let fileURL = Bundle.main.path(forResource: "audio", ofType: "caf") {
                playButton.image = images[1]
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("Couldn't play audio ):")
            }
        } catch let error {
                print("Can't play the audio file failed with an error \(error.localizedDescription)")
            }
        audioPlayer.play()
    }
    
    func finishPlaying() {
        if(audioPlayer?.isPlaying == true) {
            audioPlayer.stop()
            playButton.image = images[2]
        } else {
            playButton.image = images[2]
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

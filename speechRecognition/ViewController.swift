import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController, AVAudioRecorderDelegate {

    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        print("Failed to record");
                    }
                }
            }
        } catch {
            print("Failed to record");
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            print (result?.bestTranscription.formattedString)
        })
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: UIControlState())
        }
    }
    
    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func loadRecordingUI() {
        recordButton = UIButton(frame: CGRect(x: 30, y: 64, width: 250, height: 64))
        recordButton.backgroundColor =  UIColor.blue();
        recordButton.setTitle("Tap to Record", for: UIControlState())
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyleTitle1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory();
        do {
            try audioURL = URL(fileURLWithPath: audioFilename).appendingPathComponent("recording.m4a");
        } catch {
            
        }
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Tap to Stop", for: UIControlState())
        } catch {
            finishRecording(success: false)
        }
    }

}

func getDocumentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}


import UIKit
import AVKit
import AVFoundation
import NotificationCenter

class CallViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    //MARK: - Constants
    private enum Settings: String {
        case CallVideo, IsRecordingOn
    }
    
    private enum SoundFile: String {
        case OutboundRingTone, StartCall, EndCall, ClickOff
    }
    
    private struct ResetTime {
        static let Seconds: Int64 = 0
        static let PreferredTimeScale : Int32 = 1
        static let SeekTime: CMTime = CMTimeMake(value: ResetTime.Seconds, timescale: ResetTime.PreferredTimeScale)
    }
    
    //MARK: - Properties
    var audioDevice: AVCaptureDevice?
    var audioPlayer: AVAudioPlayer?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var isRecording = false
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoFileOutput: AVCaptureMovieFileOutput?
    var videoName: String!
    
    //MARK: - Computed properties
    var translationX: CGFloat { return UIScreen.main.bounds.width * 0.30 }
    var translationY: CGFloat { return UIScreen.main.bounds.height * 0.30 }
    
    //MARK: - Outlets
    @IBOutlet weak var callingLbl: UILabel!
    @IBOutlet weak var callingNameLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var endCallBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var princessImg: CircleImg!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var videoView: UIView!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    //MARK: Helpers
    private func addTime() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            self?.timeLbl.text = self?.getTimeString(from: currentItem.currentTime())
        })
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print(error!)
            return
        }
    }
    
    private func getTimeString(from time:CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02i:%02i", arguments: [minutes,seconds])
    }
    
    @objc func playerDidFinishPlaying() {
        playSound(soundFile: SoundFile.EndCall.rawValue, soundFileType: "mp3")
        player.pause()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.recordVideo()
            self.captureSession.stopRunning()
            self.performSegue(withIdentifier: "exitModalScene", sender: self)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func playSound(soundFile: String, soundFileType: String) {
        guard let url = Bundle.main.url(forResource: soundFile, withExtension: soundFileType) else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func recordVideo() {
        let defaults = UserDefaults.standard
        let recordingPermission = defaults.bool(forKey: Settings.IsRecordingOn.rawValue)
        if recordingPermission {
            if isRecording {
                isRecording = false
                videoFileOutput?.stopRecording()
            } else {
                isRecording = true
                let randomFilename = String.randomStringWithLength(16) + "Episode" + videoName + ".mov"
                var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsDirectory.appendPathComponent(randomFilename)
                videoFileOutput?.startRecording(to: documentsDirectory, recordingDelegate: self)
            }
        } else {
            print("Recording Permission isOff")
        }
    }
    
    private func resetVideo() {
        player.seek(to: ResetTime.SeekTime)
        player.play()
    }
    
    private func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera, .builtInMicrophone],
            mediaType: nil,
            position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
            if device.hasMediaType(AVMediaType.audio) {
                audioDevice = device
            }
        }
        currentDevice = frontCamera
    }
    
    private func setupDevices() {
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        setupVideo()
        
    }
    
    private func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            captureSession.addInput(captureDeviceInput)
            captureSession.addInput(audioDeviceInput)
            videoFileOutput = AVCaptureMovieFileOutput()
            captureSession.addOutput(videoFileOutput!)
        } catch {
            print(error)
        }
    }
    
    private func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraView.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.position = CGPoint (x: self.cameraView.frame.width/2, y: self.cameraView.frame.height/2)
        cameraPreviewLayer?.bounds = cameraView.frame
    }
    
    private func setupVideo() {
        guard let url = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            debugPrint("Video not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: url))
        playerLayer = AVPlayerLayer(player: player)
        videoView.layer.addSublayer(playerLayer)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    private func updateUI() {
        videoName = UserDefaults.standard.string(forKey: Settings.CallVideo.rawValue)
        setupDevices()
        captureSession.startRunning()
        cameraView.isHidden = false
        playSound(soundFile: SoundFile.OutboundRingTone.rawValue, soundFileType: "mp3")
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            self.callingLbl.text = "Connecting..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.playSound(soundFile: SoundFile.StartCall.rawValue, soundFileType: "mp3")
                self.cameraView.layer.cornerRadius = 20
                self.cameraView.layer.masksToBounds = true
                let scale = CGAffineTransform(scaleX: 0.25, y: 0.25)
                let translate = CGAffineTransform(translationX: self.translationX, y: self.translationY)
                self.princessImg.isHidden = true
                self.callingLbl.isHidden = true
                self.callingNameLbl.isHidden = true
                self.darkView.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.cameraView.transform = scale.concatenating(translate)
                })
                NotificationCenter.default.addObserver(self, selector: #selector(CallViewController.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                self.recordVideo()
                self.resetVideo()
                self.addTime()
            }
        }
    }
    
    //MARK: Actions
    @IBAction func endCall(_ sender: UIButton) {
        playSound(soundFile: SoundFile.ClickOff.rawValue, soundFileType: "mp3")
        player.pause()
        recordVideo()
        captureSession.stopRunning()
    }
    
    
}

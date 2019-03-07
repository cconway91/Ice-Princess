import UIKit
import AVFoundation

class RecordingsTableViewCell: UITableViewCell, PauseVideoDelegate {
    
    //MARK: - Constants
    
    //I should Try to make this Global
    private struct ResetTime {
        static let Seconds: Int64 = 0
        static let PreferredTimeScale : Int32 = 1
        static let SeekTime: CMTime = CMTimeMake(value: ResetTime.Seconds, timescale: ResetTime.PreferredTimeScale)
    }
    
    //MARK: - Properties
    weak var delegate: RecordingsTableViewCellDelegate?
    var deleteURL: URL!
    var durationTime: Float64!
    var durationSeconds = 0
    var durationMinutes = 0
    var isPlaying = false
    var progressTimer = Timer()
    var silentVideoTimer = Timer()
    var time = 0
    var timer = Timer()
    var timerOn = false
    var url: URL!
    var videoURL: URL!
    var videoName: String!
    
    //MARK: - Outlets
    @IBOutlet weak var leftTime: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var rightTime: UILabel!
    @IBOutlet weak var silentVideoView: VideoView!
    @IBOutlet weak var videoView: VideoView!
    
    //MARK: - Helpers
    func playVideos() {
        videoView.player?.seek(to: ResetTime.SeekTime)
        videoView.player?.play()
        silentVideoView.player?.seek(to: ResetTime.SeekTime)
        silentVideoView.player?.isMuted = true
        silentVideoView.player?.play()
        playBtn.setImage(UIImage(named: "Stop"), for: .normal)
        silentVideoTimer = Timer.scheduledTimer(timeInterval: durationTime, target: self, selector: #selector(RecordingsTableViewCell.stopVideos), userInfo: nil, repeats: true)
        progressView.isHidden = false
        leftTime.isHidden = false
        rightTime.isHidden = false
        progressTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(RecordingsTableViewCell.startProgressView), userInfo: nil, repeats: true)
        RunLoop.main.add(progressTimer, forMode: .common)
        if timerOn == false {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func setupTime() {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        durationTime = CMTimeGetSeconds(duration)
        durationMinutes = Int((durationTime.truncatingRemainder(dividingBy: 3600)) / 60)
        durationSeconds = Int(durationTime.truncatingRemainder(dividingBy: 60))
        rightTime.text = String(format: "%02i:%02i", arguments: [durationMinutes,durationSeconds])
    }
    
    @objc func startProgressView() {
        progressView.progress = Float(Double(progressView.progress) + 0.01/durationTime)
    }
    
    @objc func stopVideos() {
        videoView.player?.pause()
        silentVideoView.player?.pause()
        silentVideoTimer.invalidate()
        playBtn.setImage(UIImage(named: "Play"), for: .normal)
        progressView.isHidden = true
        leftTime.isHidden = true
        rightTime.isHidden = true
        progressTimer.invalidate()
        progressView.progress = 0.00
        timer.invalidate()
        time = 0
        leftTime.text = "\(timeFormatted(time))"
        timerOn = false
        isPlaying = false
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc func updateTime() {
        time = time + 1
        leftTime.text = "\(timeFormatted(time))"
    }
    
    //MARK: - Actions
    @IBAction func deleteVideoPressed(_ sender: UIButton) {
        delegate?.deleteVideo(senderCell: self, videoURL: url)
    }
    
    @IBAction func playBtnPressed(_ sender: Any) {
        if isPlaying {
            isPlaying = false
            stopVideos()
        } else {
            isPlaying = true
            playVideos()
        }
    }
    
    @IBAction func shareVideoPressed(_ sender: UIButton) {
        delegate?.shareVideo(senderCell: self, videoURL: url, videoName: videoName)
    }
    
    //MARK: - PauseVideoDelegate
    func pauseVideo() {
        stopVideos()
    }
}

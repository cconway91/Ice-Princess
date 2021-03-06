import UIKit
import AVKit
import AVFoundation
import Photos

class RecordingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching, RecordingsTableViewCellDelegate, ShareViewControllerDelegate, PauseVideoDelegate {
    
    //MARK: - Constants
    private struct Storyboard {
        static let CellIdentifier = "RecordingsCell"
    }
    
    //MARK: - Properties
    
    var cells: [Int: RecordingsTableViewCell] = [:]
    var shareVideoName: String!
    var shareVideoURL: URL!
    var tasks = [URLSessionTask]()
    var urls: [URL] = []
    var verticalSelected = true
    var selectedPlayer : RecordingsTableViewCell?
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noRecordingsView: UIView!
    @IBOutlet weak var renderingView: UIView!
    @IBOutlet weak var renderingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressLbl: UILabel!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteOverlapVideo()
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        for cell in self.cells {
            cell.value.pauseVideo()
        }
    }
    
    func pauseVideo() {
        for cell in self.cells {
            cell.value.pauseVideo()
        }
    }
    
    //MARK: - Helpers
    private func fetchURLs() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles])
            let movFiles = directoryContents.filter{ $0.pathExtension == "mov" }
            print("mov urls:", movFiles)
            let temp = directoryContents.map { url in
                (url, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                }
                .sorted(by: { $0.1 > $1.1 }) // sort descending modification dates
                .map { $0.0 } // extract file names
            self.urls = temp
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func checkNoRecordingsView() {
        if urls.isEmpty {
            noRecordingsView.isHidden = false
        } else {
            noRecordingsView.isHidden = true
        }
    }
    
    private func deleteOverlapVideo() {
        //This is to remove video that is created after sharing
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent("overlapVideo.mov")
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: destinationPath) {
            do {
                try fileManager.removeItem(atPath: destinationPath)
                print("Deleted Overlap Video")
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        } else {
            print("Overlap file does not exist")
        }
    }
    
    private func updateUI() {
        tableView.prefetchDataSource = self
        fetchURLs()
        self.tableView.reloadData()
        checkNoRecordingsView()
    }
    
    func resetVideos()
    {
        self.cells = [:]
        self.tasks = [URLSessionTask]()
        self.selectedPlayer = nil
        self.updateUI()
    }
    
    func cancelPrefetchVideo(forItemAtIndex index: Int) {
        let url = self.urls[index]
        guard let taskIndex = tasks.index(where: { $0.originalRequest?.url == url }) else {
            return
        }
        //        self.cells[index] = nil
        let task = tasks[taskIndex]
        task.cancel()
        tasks.remove(at: taskIndex)
    }
    
    
    func prefetchVideo(forItemAtIndex index: Int) {
        let url = self.urls[index]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier) as! RecordingsTableViewCell
        guard tasks.index(where: { $0.originalRequest?.url == url }) == nil else {
            // We're already downloading the video.
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                cell.url = url
                cell.delegate = self
                cell.setupTime()
                let path: String = url.path
                //Get Video Name function
                //Need to Include Child Name
                var startPos: Int = 0
                if let range = path.range(of: "Episode") {
                    startPos = path.distance(from: path.endIndex, to: range.lowerBound) + 7
                }
                let ind = path.index(path.endIndex, offsetBy: startPos)
                let mySubstring = path[ind...]
                let myString = String(mySubstring)
                var endPos: Int = 0
                if let range = path.range(of: ".") {
                    endPos = path.distance(from: path.endIndex, to: range.lowerBound)
                }
                let newIndex = myString.index(myString.startIndex, offsetBy: endPos - startPos)
                let myNewSubstring = myString[..<newIndex]
                cell.videoName = String(myNewSubstring)
                print(cell.videoName)
                DispatchQueue.global(qos: .userInteractive).async {
                    let player = AVPlayer(url: cell.url)
                    let silentURL: NSURL = Bundle.main.url(forResource: cell.videoName, withExtension: "mp4")! as NSURL
                    let silentPlayer = AVPlayer(url: silentURL as URL)
                    let silentLayer = AVPlayerLayer(player: silentPlayer)
                    DispatchQueue.main.async {
                        cell.videoView?.playerLayer.player = player
                        cell.silentVideoView?.playerLayer.player = silentLayer.player
                    }
                }
                self.cells[index] = cell
                let indexPath = IndexPath(row: index, section: 0)
                if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            }
        }
        task.resume()
        tasks.append(task)
    }
    
    //MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier) as! RecordingsTableViewCell
        //self.cells.index(forKey: indexPath.row) == nil
        if self.cells.index(forKey: indexPath.row) == nil {
            self.prefetchVideo(forItemAtIndex: indexPath.row)
        } else {
            cell = self.cells[indexPath.row]!
        }
        cell.playBtn.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urls.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 479
    }
    
    //MARK: - Table View Data Source Prefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { self.prefetchVideo(forItemAtIndex: $0.row) }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        //        indexPaths.forEach { self.cancelPrefetchVideo(forItemAtIndex: $0.row) }
    }
    
    //MARK: - RecordingsTableViewCellDelegate
    func deleteVideo(senderCell: RecordingsTableViewCell, videoURL: URL) {
        let alert = UIAlertController(title: "Alert", message: "Would you like to delete this video?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: videoURL)
                //StopPlayer If Selected Video is playing
                if self.selectedPlayer != nil
                {
                    self.selectedPlayer?.pauseVideo()
                }
                
                //DeleteVideo From Here
                /*    if let index = self.cells.index(forKey: senderCell.playBtn.tag)
                 {
                 self.cells.remove(at: index)
                 }
                 self.cancelPrefetchVideo(forItemAtIndex: senderCell.playBtn.tag)
                 
                 self.urls.remove(at: senderCell.playBtn.tag)
                 self.tableView.reloadData()
                 self.checkNoRecordingsView()*/
                self.resetVideos()
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func shareVideo(senderCell: RecordingsTableViewCell, videoURL: URL, videoName: String) {
        shareVideoURL = videoURL
        shareVideoName = videoName
        
        let alerts = UIStoryboard(name: "Alerts", bundle: nil)
        let shareSegue = alerts.instantiateViewController(withIdentifier: "Share") as! ShareViewController
        shareSegue.providesPresentationContextTransitionStyle = true
        shareSegue.definesPresentationContext = true
        shareSegue.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        shareSegue.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        shareSegue.delegate = self
        self.present(shareSegue, animated: true, completion: nil)
    }
    
    func playVideoTapped(senderCell: RecordingsTableViewCell) {
        if self.selectedPlayer != nil
        {
            if self.selectedPlayer?.playBtn.tag != senderCell.playBtn.tag
            {
                self.selectedPlayer?.pauseVideo()
            }
        }
        self.selectedPlayer = senderCell
    }
    
    
    //MARK: - ShareViewControllerDelegate
    func verticalVideoSelected() {
        verticalSelected = true
    }
    
    func squareVideoSelected() {
        verticalSelected = false
    }
    
    func shareBtnAction() {
        let silentPath = Bundle.main.path(forResource: shareVideoName, ofType: "mp4")!
        let silentUrl = URL.init(fileURLWithPath: silentPath)
        let exporter = AVAssetExportSession.overlapVideos(shareVideoURL,
                                                          secondUrl: silentUrl,
                                                          isPortraitMode: verticalSelected,
                                                          exportedFilename: "overlapVideo.mov")
        renderingView.isHidden = false
        renderingActivityIndicator.startAnimating()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            let progress = Int((exporter?.progress ?? 0) * 100)
            self.progressLbl.text = "\(progress)%"
        }
        
        exporter?.exportAsynchronously {
            DispatchQueue.main.async {
                timer.invalidate()
                let activityVC = UIActivityViewController(activityItems: [exporter?.outputURL ?? self.shareVideoURL as Any], applicationActivities: nil)
                activityVC.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                    if completed {
                        self.deleteOverlapVideo()
                        self.verticalSelected = true
                    }
                }
                activityVC.popoverPresentationController?.sourceView = self.view
                self.renderingView.isHidden = true
                self.renderingActivityIndicator.stopAnimating()
                self.present(activityVC, animated: true, completion: nil)
            }
        }
        
        
        
    }
}

import UIKit
import AVKit
import AVFoundation
import StoreKit

class PreviewViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    //MARK: - Constants
    private struct ResetTime {
        static let Seconds: Int64 = 0
        static let PreferredTimeScale : Int32 = 1
        static let SeekTime: CMTime = CMTimeMake(value: ResetTime.Seconds, timescale: ResetTime.PreferredTimeScale)
    }
    
    private enum Settings: String {
        case CallVideo, HappyBirthday
    }
    
    //MARK: - Properties
    var delegate: EpisodesViewControllerDelegate?
    var list = [SKProduct]()
    var p = SKProduct()
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoName: String!

    //MARK: - Outlets
    @IBOutlet weak var bottomLbl: UILabel!
    @IBOutlet weak var previewBox: RoundView!
    @IBOutlet weak var replayBtn: UIButton!
    @IBOutlet weak var replayLbl: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var videoView: UIView!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
//      check to see if purchase is avaliable
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            let productID: NSSet = NSSet(objects: "EpisodeTwo")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("please enable IAPS")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        let scale = CGAffineTransform(scaleX: 1.25, y: 1.25)
        UIView.animate(withDuration: 0.2, animations: {
            self.previewBox.transform = scale
        })
    }
    
    //MARK: - Helpers
    func unlockEpisode() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: Settings.HappyBirthday.rawValue)
        defaults.set(videoName, forKey: Settings.CallVideo.rawValue)
        checkCallVideo()
    }
    
    func buyEpisode() {
        for product in list {
            let prodID = product.productIdentifier
            if(prodID == "EpisodeTwo") {
                p = product
                buyProduct()
            }
        }
    }
    
    func buyProduct() {
        print("buy " + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay as SKPayment)
    }
    
    private func checkCallVideo() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: videoName) {
            if defaults.string(forKey: Settings.CallVideo.rawValue) == videoName {
                selectBtn.setImage(UIImage(named: "CheckmarkYellow"), for: .normal)
                topLbl.text = "Selected Episode"
            } else {
                selectBtn.setImage(UIImage(named: "CheckmarkGrey"), for: .normal)
                topLbl.text = "Select This Episode"
            }
        } else {
            selectBtn.setImage(UIImage(named: "Buy"), for: .normal)
            topLbl.text = "Purchase This Episode"
        }
    }
    
    private func checkVideoName() {
        if videoName == "Introduction" {
            titleLbl.text = "Introduction"
            bottomLbl.text = "Hello, it's nice to meet you!"
        } else if videoName == "HappyBirthday" {
            titleLbl.text = "Happy Birthday!"
            bottomLbl.text = "Are you having a good day?"
        } else {
            print("Video Not Found")
        }
    }
    
    private func nextVideoName() {
        if videoName == "Introduction" {
            videoName = "HappyBirthday"
        } else if videoName == "HappyBirthday" {
            videoName = "Introduction"
        } else {
            print("Video Not Found")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add payment")
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            switch trans.transactionState {
            case .purchased:
                print("buy ok, unlock IAP HERE")
                print(p.productIdentifier)
                let prodID = p.productIdentifier
                switch prodID {
                case "EpisodeTwo":
                    unlockEpisode()
                default:
                    print("IAP not found")
                }
                queue.finishTransaction(trans)
            case .failed:
                print("buy error")
                queue.finishTransaction(trans)
                break
            default:
                print("Default")
                break
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            list.append(product)
        }
    }
    
    @objc func playerDidFinishPlaying() {
        player.pause()
        replayBtn.isHidden = false
        replayLbl.isHidden = false
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func resetVideo() {
        player.seek(to: ResetTime.SeekTime)
        player.play()
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
        checkVideoName()
        checkCallVideo()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        NotificationCenter.default.addObserver(self, selector: #selector(PreviewViewController.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.setupVideo()
        self.resetVideo()
        }
    }
    
    //MARK: - Actions
    @IBAction func cancelBtnPressed(_ sender: Any) {
        player.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        replayBtn.isHidden = true
        replayLbl.isHidden = true
        player.pause()
        nextVideoName()
        setupVideo()
        checkVideoName()
        checkCallVideo()
        resetVideo()
    }
    
    @IBAction func previousBtnPressed(_ sender: Any) {
        replayBtn.isHidden = true
        replayLbl.isHidden = true
        player.pause()
        nextVideoName()
        setupVideo()
        checkVideoName()
        checkCallVideo()
        resetVideo()
    }
    
    @IBAction func replayBtnPressed(_ sender: Any) {
        replayBtn.isHidden = true
        replayLbl.isHidden = true
        resetVideo()
    }
    
    @IBAction func selectBtnPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: videoName) {
            defaults.set(videoName, forKey: Settings.CallVideo.rawValue)
            checkCallVideo()
        } else {
            buyEpisode()
        }
        delegate?.updateCheckmark()
    }
}

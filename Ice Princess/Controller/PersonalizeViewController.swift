import UIKit
import StoreKit

class PersonalizeViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    //MARK: - Constants
    private enum Settings: String {
        case CallVideo
    }
    
    private struct Storyboard {
        static let ShowEpisodesSegueIdentifier = "ShowEpisodes"
    }
    
    //MARK: - Properties
    var list = [SKProduct]()
    var p = SKProduct()
    
    //MARK: - Outlets
    @IBOutlet weak var backgroundPrincessPhoto: UIImageView!
    @IBOutlet weak var episodeView: RoundView!
    @IBOutlet weak var previewTitleLbl: UILabel!
    @IBOutlet weak var previewBottomLbl: UILabel!
    @IBOutlet weak var princessPhoto: CircleImgWithBoarder!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.minimumPressDuration = 0
        episodeView.addGestureRecognizer(tap)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    //MARK: - Helpers
    func unlockEpisode() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "HappyBirthday")
    }
    
    private func updateUI() {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: Settings.CallVideo.rawValue) == "Introduction" {
            previewTitleLbl.text = "Introduction"
            previewBottomLbl.text = "Hello, it's nice to meet you!"
            princessPhoto.image = UIImage(named: "Introduction")
            backgroundPrincessPhoto.image = UIImage(named: "Introduction")
        } else {
            previewTitleLbl.text = "Happy Birthday!"
            previewBottomLbl.text = "Are you having a good day?"
            princessPhoto.image = UIImage(named: "HappyBirthday")
            backgroundPrincessPhoto.image = UIImage(named: "HappyBirthday")
        }
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
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("transactions restored")
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            let prodID = t.payment.productIdentifier as String
            switch prodID {
            case "EpisodeTwo":
                unlockEpisode()
            default:
                print("IAP not found")
            }
        }
        let alert = UIAlertController(title: "Alert", message: "You've successfully restored your purchases!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
        
        }))
        present(alert, animated: true, completion: nil)
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
    
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            episodeView.alpha = CGFloat(0.5)
        } else if  gesture.state == .ended {
            episodeView.alpha = CGFloat(1.0)
            performSegue(withIdentifier: Storyboard.ShowEpisodesSegueIdentifier, sender: self)
        }
    }
    
    //MARK: - Actions
    @IBAction func episodesBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: Storyboard.ShowEpisodesSegueIdentifier, sender: self)
    }
    
    @IBAction func restoreBtnPressed(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
}

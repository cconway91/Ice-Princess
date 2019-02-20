import UIKit

class LaunchScreenViewController: UIViewController {
    
    private struct Storyboard {
        static let ShowMainSegueIdentifier = "ShowMain"
    }
    
    //MARK: - Properties
    var time = 0
    var timer = Timer()
    
    //MARK: - Outlets
    @IBOutlet weak var princessImg: UIImageView!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        blinkingPrincess()
        perform(#selector(LaunchScreenViewController.segueNextController), with: nil, afterDelay: 3.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Helpers
    private func blinkingPrincess() {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func updateTime() {
        time = time + 1
        if time % 2 == 0 {
            princessImg.image = UIImage(named: "PrincessEyesOpen")
        } else {
            princessImg.image = UIImage(named: "PrincessEyesClosed")
        }
    }
    
    @objc func segueNextController() {
        performSegue(withIdentifier: Storyboard.ShowMainSegueIdentifier, sender: self)
    }
}

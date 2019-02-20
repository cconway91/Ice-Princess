import UIKit

class MainViewContoller: UIViewController {
    
    //MARK: - Constants
    private struct Storyboard {
        static let ShowParentsOnlySegueIdentifier = "ShowParentsOnly"
    }
    
    //MARK: - Outlets
    @IBOutlet weak var callBtn: RoundBtn!
    @IBOutlet weak var titleLbl: UILabel!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        callBtn.alpha = 0.0
        titleLbl.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Helpers
    private func updateUI() {
        let scale = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.2, animations: {
            self.callBtn.alpha = 1.0
            self.titleLbl.alpha = 1.0
            self.callBtn.transform = scale
            self.titleLbl.transform = scale
        })
    }
    
    //MARK: - Segues
    @IBAction func exitModalScene(_ segue: UIStoryboardSegue) {
    }
}

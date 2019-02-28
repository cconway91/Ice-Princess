import UIKit

class MainViewContoller: UIViewController {
    
    //MARK: - Constants
    private struct Storyboard {
        static let ShowParentsOnlySegueIdentifier = "ShowParentsOnly"
    }
    
    //MARK: - Outlets
    @IBOutlet weak var callBtn: RoundBtn!
    @IBOutlet weak var parentsBtn: RoundBtn!
    @IBOutlet weak var titleLbl: UILabel!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        callBtn.alpha = 0.0
        parentsBtn.alpha = 0.0
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
    private func parentsOnlyMessage(_ title: String) {
        let alertController = UIAlertController(title: title, message: "What is 5+3?", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = "Place Answer Here"
        }
        let enterAction = UIAlertAction(title: "Enter", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let answerTextField = alertController.textFields![0] as UITextField
            if let answerText = answerTextField.text {
                let answer = answerText
                if answer == "8" {
                    self.performSegue(withIdentifier: Storyboard.ShowParentsOnlySegueIdentifier, sender: self)
                } else {
                    self.parentsOnlyMessage("Oops! Try again")
                }
            } else {
                self.parentsOnlyMessage("Oops! Try again")
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(enterAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func updateUI() {
        let scale = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.2, animations: {
            self.callBtn.alpha = 1.0
            self.parentsBtn.alpha = 1.0
            self.titleLbl.alpha = 1.0
            self.callBtn.transform = scale
            self.parentsBtn.transform = scale
            self.titleLbl.transform = scale
        })
    }
    
    //MARK: - Segues
    @IBAction func exitModalScene(_ segue: UIStoryboardSegue) {
    }
    
    //Mark: - Actions
    @IBAction func parentsOnlyBtnPressed(_ sender: RoundBtn) {
        parentsOnlyMessage("Parents Only Question")
    }
}

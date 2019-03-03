import UIKit

class ShareViewController: UIViewController {
    
    //MARK: - Constants
    private struct ButtonColor {
        static let White = UIColor.white
        static let Yellow = UIColor(red:170/255.0, green:170/255.0, blue:170/255.0, alpha: 1.0)
    }
    
    //MARK: - Properties
    var delegate: ShareViewControllerDelegate?
    
    //MARK: - Outlets
    @IBOutlet weak var verticalBtn: UIButton!
    @IBOutlet weak var squareBtn: UIButton!
    @IBOutlet weak var shareBtn: RoundBtn!
    @IBOutlet weak var shareView: RoundView!
    
    //MARK: - View Controller Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    //MARK: - Helpers
    private func updateUI() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        let scale = CGAffineTransform(scaleX: 1.25, y: 1.25)
        UIView.animate(withDuration: 0.2, animations: {
            self.shareView.transform = scale
        })
    }
    
    //MARK: - Actions
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func verticalBtnPressed(_ sender: Any) {
        verticalBtn.setImage(UIImage(named: "SelectOn"), for: .normal)
        squareBtn.setImage(UIImage(named: "SelectOff"), for: .normal)
        delegate?.verticalVideoSelected()
    }
    
    @IBAction func squareBtnPressed(_ sender: Any) {
        verticalBtn.setImage(UIImage(named: "SelectOff"), for: .normal)
        squareBtn.setImage(UIImage(named: "SelectOn"), for: .normal)
        delegate?.squareVideoSelected()
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        delegate?.shareBtnAction()
        self.dismiss(animated: true, completion: nil)
    }
}

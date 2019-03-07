import UIKit

class ParentsOnlyViewController: UIViewController, SegueHandler {
    
    //MARK: - Constants
    private struct Storyboard {
        static let ShowSettingsSegueIdentifier = "ShowSettings"
    }
    
    //MARK: - Properties
    weak var delegate: PauseVideoDelegate?
    
    //MARK: - Outlets
    @IBOutlet weak var personalizeView: UIView!
    @IBOutlet weak var segmentControl: CustomSegmentedControl!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var recordingsView: UIView!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.segmentedControl.addTarget(self, action: #selector(ParentsOnlyViewController.segmentValueChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.ShowSettingsSegueIdentifier {
            let dvc = segue.destination as! SettingsViewController
            dvc.delegate = self
        }
    }
    
    //MARK: - Helpers
    @objc func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            recordingsView.isHidden = false
            personalizeView.isHidden = true
            settingsView.isHidden = true
        case 1:
            recordingsView.isHidden = true
            personalizeView.isHidden = false
            settingsView.isHidden = true
            delegate?.pauseVideo()
        case 2:
            recordingsView.isHidden = true
            personalizeView.isHidden = true
            settingsView.isHidden = false
            delegate?.pauseVideo()
        default:
            break;
        }
    }
    
    func segueToNext(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
}

import UIKit

class EpisodesViewController: UITableViewController {
    
    //MARK: - Constants
    private enum Settings: String {
        case CallVideo
    }
    
    //MARK: - Outlets
    @IBOutlet weak var episodeOneBtn: UIButton!
    @IBOutlet weak var episodeTwoBtn: UIButton!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()

    }
    
    //MARK: - Helpers
    private func seguePreviewViewController(_ videoName: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let previewViewController = sb.instantiateViewController(withIdentifier: "Preview") as! PreviewViewController
        previewViewController.videoName = videoName
        previewViewController.providesPresentationContextTransitionStyle = true
        previewViewController.definesPresentationContext = true
        previewViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        previewViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(previewViewController, animated: true, completion: nil)
    }
    
    private func updateUI() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "HappyBirthday") {
            if defaults.string(forKey: Settings.CallVideo.rawValue) == "Introduction" {
                episodeOneBtn.setImage(UIImage(named: "CheckmarkLightYellow"), for: .normal)
                episodeTwoBtn.setImage(nil, for: .normal)
            } else {
                episodeOneBtn.setImage(nil, for: .normal)
                episodeTwoBtn.setImage(UIImage(named: "CheckmarkLightYellow"), for: .normal)
            }
        } else {
            episodeOneBtn.setImage(UIImage(named: "CheckmarkLightYellow"), for: .normal)
            episodeTwoBtn.setImage(UIImage(named: "Lock"), for: .normal)
        }
    }
    
    //MARK: - Actions
    @IBAction func episodeOneBtnPressed(_ sender: Any) {
        episodeOneBtn.setImage(UIImage(named: "CheckmarkLightYellow"), for: .normal)
        episodeTwoBtn.setImage(nil, for: .normal)
        let defaults = UserDefaults.standard
        defaults.set("Introduction", forKey: Settings.CallVideo.rawValue)
    }
    
    @IBAction func episodeTwoBtnPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "HappyBirthday") {
            episodeOneBtn.setImage(nil, for: .normal)
            episodeTwoBtn.setImage(UIImage(named: "CheckmarkLightYellow"), for: .normal)
            defaults.set("HappyBirthday", forKey: Settings.CallVideo.rawValue)
        } else {
            seguePreviewViewController("HappyBirthday")
        }
    }
    
    //Mark: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            seguePreviewViewController("Introduction")
        }
        if indexPath.row == 1 {
            seguePreviewViewController("HappyBirthday")
        }
    }
}

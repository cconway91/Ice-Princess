import UIKit

class SettingsViewController: UITableViewController {
    
    //MARK: - Constants
    private enum Settings: String {
        case IsRecordingOn
    }
    
    private struct Storyboard {
        static let ShowAboutUsSegueIdentifier = "ShowAboutUs"
        static let ShowWhyOurAppisSafeSegueIdentifier = "ShowWhyOurAppisSafe"
    }
    
    //MARK: - Properties
    weak var delegate: SegueHandler?
    
    //MARK: - Outlets
    @IBOutlet weak var recordingSwitchUI: UISwitch!
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    //MARK: - Helpers
    private func updateUI() {
        let defaults = UserDefaults.standard
        if (defaults.bool(forKey: Settings.IsRecordingOn.rawValue)) {
            recordingSwitchUI.isOn = true
        } else {
            recordingSwitchUI.isOn = false
        }
    }
    
    //MARK: - Actions
    @IBAction func recordingSwitch(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        if sender.isOn {
            defaults.set(true, forKey: Settings.IsRecordingOn.rawValue)
        } else {
            defaults.set(false, forKey: Settings.IsRecordingOn.rawValue)
        }
    }
    
    //Mark: - Tableview Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            delegate?.segueToNext(identifier: Storyboard.ShowAboutUsSegueIdentifier)
        }
        if indexPath.row == 3 {
            delegate?.segueToNext(identifier: Storyboard.ShowWhyOurAppisSafeSegueIdentifier)
        }
        if indexPath.row == 4 {
            UIApplication.shared.open(URL(string: "https://www.facebook.com/VideoCallPrincess/")! as URL, options: [:], completionHandler: nil)
        }
    }
}

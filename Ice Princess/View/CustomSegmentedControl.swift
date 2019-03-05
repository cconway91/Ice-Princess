import UIKit

@IBDesignable
class CustomSegmentedControl: UIView {
    
    let segmentedControl = UISegmentedControl()
    let bottomBar = UIView()
    let buttonBar = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        segmentedControl.removeAllSegments()
        backgroundColor = .white
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular),
            NSAttributedString.Key.foregroundColor: UIColor(red: 0x84, green: 0xC0, blue: 0xE2)
            ], for: .selected)
        segmentedControl.insertSegment(withTitle: "Recordings", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Personalize", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "Settings", at: 2, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .lightGray
        buttonBar.backgroundColor = UIColor(red: 0x84, green: 0xC0, blue: 0xE2)
        self.addSubview(segmentedControl)
        self.addSubview(bottomBar)
        self.addSubview(buttonBar)
        segmentedControl.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        segmentedControl.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottomBar.bottomAnchor.constraint(equalTo: buttonBar.bottomAnchor).isActive = true
        buttonBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor).isActive = true
        bottomBar.heightAnchor.constraint(equalToConstant: 1).isActive = true
        buttonBar.heightAnchor.constraint(equalToConstant: 4).isActive = true
        bottomBar.leftAnchor.constraint(equalTo: segmentedControl.leftAnchor).isActive = true
        buttonBar.leftAnchor.constraint(equalTo: segmentedControl.leftAnchor).isActive = true
        bottomBar.rightAnchor.constraint(equalTo: segmentedControl.rightAnchor).isActive = true
        buttonBar.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1 / CGFloat(segmentedControl.numberOfSegments)).isActive = true
        buttonBar.layer.cornerRadius = 2
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            self.buttonBar.frame.origin.x = (self.segmentedControl.frame.width / CGFloat(self.segmentedControl.numberOfSegments)) * CGFloat(self.segmentedControl.selectedSegmentIndex)
        }
    }
}

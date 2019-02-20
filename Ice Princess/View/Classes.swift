import UIKit

@IBDesignable
class CircleImg: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width/2
        clipsToBounds = true
    }
}

@IBDesignable
class RoundBtn: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
        titleLabel?.font = UIFont.systemFont(ofSize: ((24/414) * (UIScreen.main.bounds.width)))
    }
}

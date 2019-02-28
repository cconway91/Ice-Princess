import UIKit

@IBDesignable
class RoundView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}

@IBDesignable
class CircleImg: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width/2
        clipsToBounds = true
    }
}

@IBDesignable
class CircleImgWithBoarder: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width/2
        clipsToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
}

@IBDesignable
class CircleView: UIImageView {
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

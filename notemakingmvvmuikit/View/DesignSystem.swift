import UIKit

struct DesignSystem {
    struct Colors {
        static let primary = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        static let primaryLight = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        static let primaryDark = UIColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0)

        static let gradientStart = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        static let gradientEnd = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)

        static let backgroundPrimary = UIColor.systemBackground
        static let backgroundSecondary = UIColor.secondarySystemBackground
        static let backgroundCard = UIColor.systemBackground

        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let textTertiary = UIColor.tertiaryLabel

        static let success = UIColor.systemGreen
        static let warning = UIColor.systemOrange
        static let error = UIColor.systemRed

        static let shadow = UIColor.black.withAlphaComponent(0.1)
        static let shadowStrong = UIColor.black.withAlphaComponent(0.2)
    }

    struct Typography {
        static let appTitle = UIFont.boldSystemFont(ofSize: 32)
        static let appSubtitle = UIFont.systemFont(ofSize: 16, weight: .medium)

        static let navigationTitle = UIFont.boldSystemFont(ofSize: 18)

        static let headline = UIFont.boldSystemFont(ofSize: 22)
        static let title = UIFont.boldSystemFont(ofSize: 18)
        static let body = UIFont.systemFont(ofSize: 16)
        static let caption = UIFont.systemFont(ofSize: 14)
        static let footnote = UIFont.systemFont(ofSize: 12)

        static let noteTitle = UIFont.boldSystemFont(ofSize: 17)
        static let noteContent = UIFont.systemFont(ofSize: 15)
        static let noteDate = UIFont.systemFont(ofSize: 13)
    }

    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 32
        static let xxlarge: CGFloat = 48
    }

    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
    }

    struct Animation {
        static let quick: TimeInterval = 0.2
        static let medium: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5

        static let springDamping: CGFloat = 0.8
        static let springVelocity: CGFloat = 0.3
    }
}

struct ShadowStyle {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: Float
}

extension UIView {
    func roundCorners(radius: CGFloat = DesignSystem.CornerRadius.medium) {
        layer.cornerRadius = radius
        layer.masksToBounds = false
    }

    func applyCardStyle() {
        backgroundColor = DesignSystem.Colors.backgroundCard
        roundCorners(radius: DesignSystem.CornerRadius.large)
        layer.shadowColor = DesignSystem.Colors.shadow.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 8
    }

    func addGradientBackground(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        layer.sublayers?.filter { $0.name == "gradientLayer" }.forEach { $0.removeFromSuperlayer() }
        let gradient = CAGradientLayer()
        gradient.name = "gradientLayer"
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.zPosition = -1
        layer.insertSublayer(gradient, at: 0)
    }

    func bounceIn(delay: TimeInterval = 0) {
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        alpha = 0
        UIView.animate(
            withDuration: DesignSystem.Animation.medium,
            delay: delay,
            usingSpringWithDamping: DesignSystem.Animation.springDamping,
            initialSpringVelocity: DesignSystem.Animation.springVelocity,
            options: .curveEaseOut,
            animations: {
                self.transform = .identity
                self.alpha = 1
            }, completion: nil
        )
    }

    func slideInFromBottom(delay: TimeInterval = 0) {
        transform = CGAffineTransform(translationX: 0, y: 50)
        alpha = 0
        UIView.animate(withDuration: DesignSystem.Animation.medium, delay: delay, options: .curveEaseOut) {
            self.transform = .identity
            self.alpha = 1
        }
    }
}

extension UIButton {
    func applyPrimaryStyle() {
        backgroundColor = DesignSystem.Colors.primary
        setTitleColor(.white, for: .normal)
        titleLabel?.font = DesignSystem.Typography.body
        roundCorners(radius: DesignSystem.CornerRadius.medium)

        layer.shadowColor = DesignSystem.Colors.primary.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3

        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.8
        }
    }

    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}

extension UITextField {
    func applyModernStyle() {
        backgroundColor = DesignSystem.Colors.backgroundSecondary
        textColor = DesignSystem.Colors.textPrimary
        font = DesignSystem.Typography.body
        roundCorners()
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: DesignSystem.Spacing.medium, height: frame.height))
        leftViewMode = .always
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: DesignSystem.Spacing.medium, height: frame.height))
        rightViewMode = .always
    }
}

extension UITextView {
    func applyModernStyle() {
        backgroundColor = DesignSystem.Colors.backgroundSecondary
        textColor = DesignSystem.Colors.textPrimary
        font = DesignSystem.Typography.body
        roundCorners()
        textContainerInset = UIEdgeInsets(top: DesignSystem.Spacing.medium, left: DesignSystem.Spacing.medium, bottom: DesignSystem.Spacing.medium, right: DesignSystem.Spacing.medium)
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255)
        return String(format: "#%06x", rgb)
    }
}


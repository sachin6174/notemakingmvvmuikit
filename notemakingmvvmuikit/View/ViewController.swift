//
//  ViewController.swift
//  notemakingmvvmuikit
//
//  Created by sachin kumar on 30/08/25.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBeautifulWelcomeScreen()
    }

    private func setupBeautifulWelcomeScreen() {
        DispatchQueue.main.async {
            self.view.addGradientBackground(
                colors: [
                    DesignSystem.Colors.gradientStart,
                    DesignSystem.Colors.gradientEnd
                ],
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 1, y: 1)
            )
        }

        if let button = view.subviews.first(where: { $0 is UIButton }) as? UIButton {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                button.applyPrimaryStyle()
                button.bounceIn()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.animateWelcomeElements()
        }
    }

    private func animateWelcomeElements() {
        if let stackView = view.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            for (index, subview) in stackView.arrangedSubviews.enumerated() {
                subview.slideInFromBottom(delay: Double(index) * 0.1)
            }
        }
    }

    @IBAction func getStartedTapped(_ sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = .identity
        }) { _ in
            self.launchNotes()
        }
    }

    private func launchNotes() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let notesListVC = storyboard.instantiateViewController(withIdentifier: "NotesListViewController") as? NotesListViewController else { return }
        let nav = UINavigationController(rootViewController: notesListVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

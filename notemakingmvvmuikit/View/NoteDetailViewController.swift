import UIKit

final class NoteDetailViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!

    var viewModel: NoteDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        populateFields()
        bindViewModel()
    }

    private func setupView() {
        title = viewModel?.isCreatingNew == true ? "New Note" : "Edit Note"
        view.backgroundColor = DesignSystem.Colors.backgroundPrimary
        navigationController?.navigationBar.tintColor = DesignSystem.Colors.primary
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.navigationTitle
        ]
        titleTextField.applyModernStyle()
        titleTextField.placeholder = "Enter note title..."
        titleTextField.font = DesignSystem.Typography.title
        contentTextView.applyModernStyle()
        contentTextView.font = DesignSystem.Typography.body
        contentTextView.textColor = DesignSystem.Colors.textPrimary
        DispatchQueue.main.async {
            self.view.addGradientBackground(
                colors: [
                    DesignSystem.Colors.gradientStart.withAlphaComponent(0.1),
                    DesignSystem.Colors.gradientEnd.withAlphaComponent(0.05)
                ],
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 1, y: 1)
            )
        }
    }

    private func populateFields() {
        guard let vm = viewModel else { return }
        if vm.isCreatingNew {
            titleTextField.text = ""
            contentTextView.text = "Start writing your note here...\n\nThis beautiful interface demonstrates the VIEW layer in MVVM architecture — it handles display and user input while the ViewModel manages the logic."
            contentTextView.textColor = DesignSystem.Colors.textSecondary
        } else {
            titleTextField.text = vm.note?.title
            contentTextView.text = vm.note?.content
            contentTextView.textColor = DesignSystem.Colors.textPrimary
        }
    }

    private func bindViewModel() {
        viewModel.onSaved = { [weak self] in
            UIView.animate(withDuration: DesignSystem.Animation.quick) {
                self?.view.alpha = 0.8
                self?.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            } completion: { _ in
                self?.navigationController?.popViewController(animated: true)
            }
        }
        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let title = titleTextField.text ?? ""
        let content = contentTextView.text ?? ""
        let cleanContent = content.hasPrefix("Start writing your note here...") ? "" : content
        viewModel.save(title: title, content: cleanContent)
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}


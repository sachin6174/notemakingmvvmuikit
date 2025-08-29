import UIKit
import CoreData

final class NotesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = NotesListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    private func setupView() {
        title = "Notes"
        view.backgroundColor = DesignSystem.Colors.backgroundPrimary

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.backgroundColor = DesignSystem.Colors.backgroundPrimary
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = DesignSystem.Colors.primary
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.appTitle
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.navigationTitle
        ]
    }

    private func bindViewModel() {
        viewModel.onNotesChanged = { [weak self] in
            DispatchQueue.main.async { self?.tableView.reloadData() }
        }
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        viewModel.onShowDetail = { [weak self] note, isCreating in
            guard let self = self else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController {
                detailVC.viewModel = NoteDetailViewModel(note: note, isCreatingNew: isCreating)
                self.navigationController?.pushViewController(detailVC, animated: true)
            } else {
                let detailVC = NoteDetailViewController()
                detailVC.viewModel = NoteDetailViewModel(note: note, isCreatingNew: isCreating)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.didTapAdd()
    }
}

extension NotesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "NoteCell")

        let note = viewModel.notes[indexPath.row]

        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        let cardView = UIView()
        cardView.applyCardStyle()
        cardView.backgroundColor = UIColor(hexString: note.colorHex ?? "#4ECDC4") ?? DesignSystem.Colors.backgroundCard
        cardView.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(cardView)

        let titleLabel = UILabel()
        titleLabel.text = (note.title?.isEmpty ?? true) ? "Untitled Note" : note.title
        titleLabel.font = DesignSystem.Typography.noteTitle
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        let contentLabel = UILabel()
        contentLabel.text = note.content
        contentLabel.font = DesignSystem.Typography.noteContent
        contentLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        contentLabel.numberOfLines = 3

        let dateLabel = UILabel()
        if let updatedAt = note.updatedAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: updatedAt)
        }
        dateLabel.font = DesignSystem.Typography.noteDate
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        let favoriteIcon = UILabel()
        favoriteIcon.text = note.isFavorite ? "⭐" : ""
        favoriteIcon.font = UIFont.systemFont(ofSize: 16)

        let labelStack = UIStackView(arrangedSubviews: [titleLabel, contentLabel, dateLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        labelStack.translatesAutoresizingMaskIntoConstraints = false

        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(labelStack)
        cardView.addSubview(favoriteIcon)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),

            labelStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            labelStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            labelStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -50),
            labelStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            favoriteIcon.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            favoriteIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])

        return cell
    }
}

extension NotesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelect(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { viewModel.delete(at: indexPath.row) }
    }
}

import Foundation
import CoreData

final class NoteDetailViewModel {
    private let repo: NotesRepository
    private(set) var note: NoteEntity?
    let isCreatingNew: Bool

    var onSaved: (() -> Void)?
    var onError: ((String) -> Void)?

    init(note: NoteEntity?, isCreatingNew: Bool, repo: NotesRepository = CoreDataNotesRepository()) {
        self.note = note
        self.isCreatingNew = isCreatingNew
        self.repo = repo
    }

    func save(title: String, content: String) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty || !c.isEmpty else {
            onError?("Note must have either a title or content")
            return
        }

        if isCreatingNew {
            _ = repo.create(title: t, content: c, category: "General")
            onSaved?()
        } else if let note {
            if repo.update(note, title: t, content: c, category: nil) {
                onSaved?()
            } else {
                onError?("Failed to update note")
            }
        }
    }
}

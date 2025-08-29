import Foundation
import CoreData

final class NotesListViewModel {
    // Outputs
    private(set) var notes: [NoteEntity] = [] { didSet { onNotesChanged?() } }
    var onNotesChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    var onShowDetail: ((NoteEntity?, Bool) -> Void)?

    // Dependencies
    private let repo: NotesRepository

    init(repo: NotesRepository = CoreDataNotesRepository()) {
        self.repo = repo
    }

    func load() {
        notes = repo.fetchNotes()
    }

    func didTapAdd() {
        onShowDetail?(nil, true)
    }

    func didSelect(at index: Int) {
        guard notes.indices.contains(index) else { return }
        onShowDetail?(notes[index], false)
    }

    func delete(at index: Int) {
        guard notes.indices.contains(index) else { return }
        let note = notes[index]
        if repo.delete(note) {
            load()
        } else {
            onError?("Failed to delete note")
        }
    }
}

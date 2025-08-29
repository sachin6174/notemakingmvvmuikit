import Foundation

protocol NotesRepository {
    func fetchNotes() -> [NoteEntity]
    func create(title: String, content: String, category: String) -> NoteEntity
    func update(_ note: NoteEntity, title: String, content: String, category: String?) -> Bool
    func delete(_ note: NoteEntity) -> Bool
}

final class CoreDataNotesRepository: NotesRepository {
    private let manager: CoreDataManager
    init(manager: CoreDataManager = .shared) { self.manager = manager }

    func fetchNotes() -> [NoteEntity] { manager.getAllNotes() }

    func create(title: String, content: String, category: String = "General") -> NoteEntity {
        manager.createNote(title: title, content: content, category: category)
    }

    func update(_ note: NoteEntity, title: String, content: String, category: String? = nil) -> Bool {
        manager.updateNote(note, title: title, content: content, category: category)
    }

    func delete(_ note: NoteEntity) -> Bool { manager.deleteNote(note) }
}


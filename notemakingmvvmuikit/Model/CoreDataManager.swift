import Foundation
import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "notemakingmvvmuikit")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func saveContext() {
        guard context.hasChanges else { return }
        do { try context.save() } catch { fatalError("Unresolved error: \(error)") }
    }

    // MARK: - CRUD
    @discardableResult
    func createNote(title: String, content: String, category: String = "General") -> NoteEntity {
        let note = NoteEntity(context: context)
        note.id = UUID()
        note.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        note.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        note.category = category
        note.createdAt = Date()
        note.updatedAt = Date()
        note.isFavorite = false
        note.colorHex = generateRandomNoteColor()
        saveContext()
        return note
    }

    func getAllNotes() -> [NoteEntity] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func searchNotes(query: String) -> [NoteEntity] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        let title = NSPredicate(format: "title CONTAINS[cd] %@", query)
        let content = NSPredicate(format: "content CONTAINS[cd] %@", query)
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [title, content])
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    @discardableResult
    func updateNote(_ note: NoteEntity, title: String, content: String, category: String? = nil) -> Bool {
        note.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        note.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if let category { note.category = category }
        note.updatedAt = Date()
        saveContext()
        return true
    }

    @discardableResult
    func deleteNote(_ note: NoteEntity) -> Bool {
        context.delete(note)
        saveContext()
        return true
    }

    // MARK: - Helpers
    func generateRandomNoteColor() -> String {
        // A few nice pastel colors
        let palette = ["#4ECDC4", "#556270", "#C7F464", "#FF6B6B", "#C44D58", "#45B7AA", "#96CEB4", "#FFEEAD", "#D4A5A5"]
        return palette.randomElement() ?? "#4ECDC4"
    }
}


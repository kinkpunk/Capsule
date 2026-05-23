import Foundation

enum AccessibilityID {
    enum Tab {
        static let today = "tab.today"
        static let wardrobe = "tab.wardrobe"
        static let outfits = "tab.outfits"
        static let planner = "tab.planner"
        static let profile = "tab.profile"
    }

    enum Wardrobe {
        static let addButton = "wardrobe.add"
        static let searchField = "wardrobe.search"
        static let filterAll = "wardrobe.filter.all"
        static func filterCategory(_ rawValue: String) -> String { "wardrobe.filter.category.\(rawValue)" }
        static let emptyAddButton = "wardrobe.empty.add"
        static let batchImport = "wardrobe.batchImport"
    }

    enum AddItem {
        static let nameField = "addItem.name"
        static let saveButton = "addItem.save"
        static let cancelButton = "addItem.cancel"
        static let chooseFromGallery = "addItem.gallery"
        static let takePhoto = "addItem.camera"
        static let addAnotherToggle = "addItem.addAnother"
    }

    enum BatchImport {
        static let picker = "batchImport.picker"
        static let saveAll = "batchImport.saveAll"
        static let clearAll = "batchImport.clearAll"
        static let defaultsSection = "batchImport.defaults"
        static func itemName(_ id: UUID) -> String { "batchImport.item.\(id.uuidString).name" }
        static func itemCategory(_ id: UUID) -> String { "batchImport.item.\(id.uuidString).category" }
        static func itemColor(_ id: UUID) -> String { "batchImport.item.\(id.uuidString).color" }
    }

    enum ItemDetail {
        static let nameField = "itemDetail.name"
        static let saveButton = "itemDetail.save"
        static let archiveButton = "itemDetail.archive"
        static let unarchiveButton = "itemDetail.unarchive"
        static let deleteButton = "itemDetail.delete"
        static let chooseFromGallery = "itemDetail.gallery"
        static let takePhoto = "itemDetail.camera"
    }

    enum Today {
        static let addMenu = "today.addMenu"
        static let refreshButton = "today.refresh"
        static let addItem = "today.addItem"
        static let newOutfit = "today.newOutfit"
        static let batchImport = "today.batchImport"
    }

    enum Outfits {
        static let addButton = "outfits.add"
        static let emptyAddButton = "outfits.empty.add"
        static let assignButtonPrefix = "outfits.assign."
        static let assignSheetSave = "outfits.assign.save"
    }
}

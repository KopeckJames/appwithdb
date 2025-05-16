import Foundation
import CoreData

class CoreDataModelUpdater {
    static let shared = CoreDataModelUpdater()
    
    private init() {
        print("CoreDataModelUpdater initialized")
    }
    
    /// Updates the Core Data model with new attributes for meal analysis
    func updateMealEntity() {
        let context = CoreDataStack.shared.viewContext
        
        // Check if we need to update the model
        if !needsUpdate(context: context) {
            print("Core Data model is already up to date")
            return
        }
        
        print("Updating Core Data model with new attributes for meal analysis")
        
        // Get the entity description for Meal
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Meal", in: context) else {
            print("Failed to get entity description for Meal")
            return
        }
        
        // Add new attributes if they don't exist
        addAttributeIfNeeded(entityDescription: entityDescription, name: "ingredientsData", type: .binaryDataAttributeType)
        addAttributeIfNeeded(entityDescription: entityDescription, name: "glycemicIndex", type: .stringAttributeType)
        addAttributeIfNeeded(entityDescription: entityDescription, name: "diabeticFriendly", type: .booleanAttributeType, defaultValue: false)
        addAttributeIfNeeded(entityDescription: entityDescription, name: "healthRecommendations", type: .stringAttributeType)
        
        // Save the context to persist the changes
        do {
            try context.save()
            print("Core Data model updated successfully")
        } catch {
            print("Error updating Core Data model: \(error)")
        }
    }
    
    /// Checks if the model needs to be updated
    private func needsUpdate(context: NSManagedObjectContext) -> Bool {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Meal", in: context) else {
            return false
        }
        
        // Check if any of the new attributes are missing
        let attributesToCheck = ["ingredientsData", "glycemicIndex", "diabeticFriendly", "healthRecommendations"]
        let properties = entityDescription.propertiesByName
        
        for attributeName in attributesToCheck {
            if properties[attributeName] == nil {
                return true
            }
        }
        
        return false
    }
    
    /// Adds an attribute to the entity if it doesn't already exist
    private func addAttributeIfNeeded(entityDescription: NSEntityDescription, name: String, type: NSAttributeType, defaultValue: Any? = nil) {
        if entityDescription.propertiesByName[name] == nil {
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = true
            
            if let defaultValue = defaultValue {
                attribute.defaultValue = defaultValue
            }
            
            var properties = entityDescription.properties
            properties.append(attribute)
            entityDescription.properties = properties
            
            print("Added attribute \(name) to Meal entity")
        }
    }
}

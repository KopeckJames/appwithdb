import SwiftUI
import UIKit
import CoreData

struct EditMealView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    let meal: Meal

    // Meal properties
    @State private var title: String
    @State private var mealType: String
    @State private var notes: String
    @State private var selectedImage: UIImage?
    @State private var foodItems: [FoodItemData] = []

    // UI states
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingImageOptions = false
    @State private var showingAddFoodItem = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // Meal type options
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    init(meal: Meal) {
        self.meal = meal

        // Initialize state variables with meal data
        _title = State(initialValue: meal.title ?? "")
        _mealType = State(initialValue: meal.mealType ?? "Breakfast")
        _notes = State(initialValue: meal.notes ?? "")

        // Load image if available
        if let photoData = meal.photoData {
            _selectedImage = State(initialValue: UIImage(data: photoData))
        }

        // Load food items
        var loadedItems: [FoodItemData] = []
        if let foodItems = meal.foodItems as? Set<FoodItem> {
            for item in foodItems {
                let foodItem = FoodItemData(
                    name: item.name ?? "",
                    calories: item.calories,
                    protein: item.protein,
                    carbs: item.carbs,
                    fat: item.fat,
                    servingSize: item.servingSize ?? ""
                )
                loadedItems.append(foodItem)
            }
        }
        _foodItems = State(initialValue: loadedItems)
    }

    var body: some View {
        NavigationView {
            Form {
                // Meal photo section
                Section(header: Text("Photo")) {
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                                .padding(.vertical, 8)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                                .padding(.vertical, 20)
                        }

                        Button(action: {
                            showingImageOptions = true
                        }) {
                            Text(selectedImage == nil ? "Add Photo" : "Change Photo")
                                .foregroundColor(.blue)
                        }
                        .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Meal details section
                Section(header: Text("Meal Details")) {
                    TextField("Title", text: $title)

                    Picker("Meal Type", selection: $mealType) {
                        ForEach(mealTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }

                    if let date = meal.date {
                        HStack {
                            Text("Date & Time")
                            Spacer()
                            Text(dateFormatter.string(from: date))
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Notes section
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                // Food items section
                Section(header: HStack {
                    Text("Food Items")
                    Spacer()
                    Button(action: {
                        showingAddFoodItem = true
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }) {
                    if foodItems.isEmpty {
                        Text("No food items added")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(foodItems.indices, id: \.self) { index in
                            FoodItemDataRow(item: foodItems[index])
                        }
                        .onDelete(perform: deleteFoodItem)
                    }
                }

                // Nutritional summary
                Section(header: Text("Nutritional Summary")) {
                    HStack {
                        Text("Total Calories:")
                        Spacer()
                        Text("\(totalCalories) cal")
                            .foregroundColor(.orange)
                            .fontWeight(.bold)
                    }

                    HStack {
                        Text("Protein:")
                        Spacer()
                        Text("\(totalProtein)g")
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Carbs:")
                        Spacer()
                        Text("\(totalCarbs)g")
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Fat:")
                        Spacer()
                        Text("\(totalFat)g")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Edit Meal", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    updateMeal()
                }
                .disabled(title.isEmpty)
            )
            .actionSheet(isPresented: $showingImageOptions) {
                ActionSheet(
                    title: Text("Select Photo"),
                    message: Text("Choose a source"),
                    buttons: [
                        .default(Text("Camera")) {
                            showingCamera = true
                        },
                        .default(Text("Photo Library")) {
                            showingImagePicker = true
                        },
                        .destructive(Text("Remove Photo")) {
                            selectedImage = nil
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showingAddFoodItem) {
                AddFoodItemView(onAdd: { foodItem in
                    foodItems.append(foodItem)
                })
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Calculate total calories
    private var totalCalories: Int {
        Int(foodItems.reduce(0) { $0 + $1.calories })
    }

    // Calculate total protein
    private var totalProtein: Int {
        Int(foodItems.reduce(0) { $0 + $1.protein })
    }

    // Calculate total carbs
    private var totalCarbs: Int {
        Int(foodItems.reduce(0) { $0 + $1.carbs })
    }

    // Calculate total fat
    private var totalFat: Int {
        Int(foodItems.reduce(0) { $0 + $1.fat })
    }

    // Delete food item
    private func deleteFoodItem(at offsets: IndexSet) {
        foodItems.remove(atOffsets: offsets)
    }

    // Update meal
    private func updateMeal() {
        if title.isEmpty {
            alertMessage = "Please enter a title for the meal"
            showingAlert = true
            return
        }

        let success = MealManager.shared.updateMeal(
            meal: meal,
            title: title,
            mealType: mealType,
            notes: notes,
            photo: selectedImage,
            foodItems: foodItems,
            context: viewContext
        )

        if success {
            presentationMode.wrappedValue.dismiss()
        } else {
            alertMessage = "Failed to update meal. Please try again."
            showingAlert = true
        }
    }

    // Date formatter
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

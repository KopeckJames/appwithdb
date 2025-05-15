import SwiftUI
import UIKit
import CoreData

struct AddMealView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    // Meal properties
    @State private var title = ""
    @State private var mealType = "Breakfast"
    @State private var notes = ""
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

                    DatePicker("Date & Time", selection: .constant(Date()))
                        .disabled(true) // Using current date/time
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
            .navigationBarTitle("Add Meal", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveMeal()
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

    // Save meal
    private func saveMeal() {
        if title.isEmpty {
            alertMessage = "Please enter a title for the meal"
            showingAlert = true
            return
        }

        let success = MealManager.shared.createMeal(
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
            alertMessage = "Failed to save meal. Please try again."
            showingAlert = true
        }
    }
}

// Image picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Food item data row
struct FoodItemDataRow: View {
    let item: FoodItemData

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)

                if !item.servingSize.isEmpty {
                    Text(item.servingSize)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(item.calories)) cal")
                    .font(.subheadline)
                    .foregroundColor(.orange)

                HStack(spacing: 8) {
                    Text("P: \(Int(item.protein))g")
                        .font(.caption)
                        .foregroundColor(.blue)

                    Text("C: \(Int(item.carbs))g")
                        .font(.caption)
                        .foregroundColor(.green)

                    Text("F: \(Int(item.fat))g")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Add food item view
struct AddFoodItemView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var servingSize = ""
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fat: Double = 0

    var onAdd: (FoodItemData) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Name", text: $name)
                    TextField("Serving Size", text: $servingSize)
                }

                Section(header: Text("Nutrition")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", value: $calories, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("cal")
                    }

                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0", value: $protein, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }

                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0", value: $carbs, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }

                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0", value: $fat, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                }
            }
            .navigationBarTitle("Add Food Item", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    let foodItem = FoodItemData(
                        name: name,
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fat: fat,
                        servingSize: servingSize
                    )
                    onAdd(foodItem)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

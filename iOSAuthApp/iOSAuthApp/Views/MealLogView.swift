import SwiftUI
import CoreData
import UIKit

struct MealLogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddMeal = false
    @State private var selectedDate = Date()

    // Fetch request for meals
    @FetchRequest(
        entity: NSEntityDescription.entity(forEntityName: "Meal", in: CoreDataStack.shared.viewContext)!,
        sortDescriptors: [NSSortDescriptor(keyPath: \Meal.date, ascending: false)],
        predicate: nil,
        animation: .default)
    private var meals: FetchedResults<Meal>

    // Filtered meals for the selected date
    private var filteredMeals: [Meal] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return meals.filter { meal in
            guard let mealDate = meal.date else { return false }
            return mealDate >= startOfDay && mealDate < endOfDay
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Date picker
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

                // Meal list
                if filteredMeals.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No meals logged for this date")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Button(action: {
                            showingAddMeal = true
                        }) {
                            Text("Add a Meal")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredMeals, id: \.self) { meal in
                            NavigationLink(destination: MealDetailView(meal: meal)) {
                                MealRowView(meal: meal)
                            }
                        }
                        .onDelete(perform: deleteMeals)
                    }
                }
            }
            .navigationBarTitle("Meal Log", displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                showingAddMeal = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            })
            .sheet(isPresented: $showingAddMeal) {
                AddMealView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    // Delete meals
    private func deleteMeals(at offsets: IndexSet) {
        for index in offsets {
            let meal = filteredMeals[index]
            MealManager.shared.deleteMeal(meal: meal, context: viewContext)
        }
    }
}

// Meal row view
struct MealRowView: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 15) {
            // Meal photo or placeholder
            if let photoData = meal.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding(15)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.title ?? "Untitled Meal")
                    .font(.headline)

                Text(meal.mealType ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if let date = meal.date {
                    Text(timeFormatter.string(from: date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("\(Int(meal.totalCalories)) cal")
                    .font(.headline)
                    .foregroundColor(.orange)

                if let foodItems = meal.foodItems, foodItems.count > 0 {
                    Text("\(foodItems.count) items")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // Time formatter
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// Placeholder for MealDetailView
struct MealDetailView: View {
    let meal: Meal
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Meal photo
                if let photoData = meal.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(30)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // Meal info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(meal.title ?? "Untitled Meal")
                            .font(.title)
                            .fontWeight(.bold)

                        Spacer()

                        Text("\(Int(meal.totalCalories)) cal")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                    }

                    Text(meal.mealType ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if let date = meal.date {
                        Text(dateFormatter.string(from: date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    if let notes = meal.notes, !notes.isEmpty {
                        Text("Notes")
                            .font(.headline)
                            .padding(.top, 8)

                        Text(notes)
                            .font(.body)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                // Food items
                VStack(alignment: .leading, spacing: 12) {
                    Text("Food Items")
                        .font(.headline)
                        .padding(.top, 8)

                    if let foodItems = meal.foodItems as? Set<FoodItem>, !foodItems.isEmpty {
                        ForEach(Array(foodItems), id: \.self) { item in
                            FoodItemRow(item: item)
                        }
                    } else {
                        Text("No food items added")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            isEditing = true
        }) {
            Text("Edit")
        })
        .sheet(isPresented: $isEditing) {
            EditMealView(meal: meal)
                .environment(\.managedObjectContext, viewContext)
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

// Food item row
struct FoodItemRow: View {
    let item: FoodItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? "Unknown Item")
                    .font(.headline)

                if let servingSize = item.servingSize, !servingSize.isEmpty {
                    Text(servingSize)
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



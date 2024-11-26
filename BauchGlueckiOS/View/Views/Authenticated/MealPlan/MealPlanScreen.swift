//
//  MealPlanScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth


struct MealPlanScreen: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var services: Services

    @State private var vm: MealPlanViewModel
    let currentDate: Date?

    init(currentDate: Date? = nil, services: Services) {
        self.currentDate = currentDate
        _vm = State(initialValue: MealPlanViewModel(service: services))
    }

    var body: some View {
        ZStack {
            theme.color.background.ignoresSafeArea()

            if !vm.dates.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: theme.layout.padding) {
                        currentDateSection
                        calendarSection
                        nutritionCard
                        mealSpotsSection
                        Spacer()
                    }
                    .contentMargins(.top, theme.layout.padding)
                }
                .onAppLifeCycle(appearAndActive: {
                    vm.loadMealPlans()
                })
                .onAppear {
                    if let currentDate = currentDate {
                        vm.currentDate = currentDate
                    }
                }
            }
        }
    }

    // MARK: - currentDateSection
    private var currentDateSection: some View {
        Text(DateFormatteUtil.formattedFullDate(vm.currentDate))
            .padding(.horizontal, theme.layout.padding)
    }

    private var calendarSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(vm.dates, id: \.self) { date in
                    DayItem(
                        date: date,
                        selectedDate: vm.currentDate,
                        currentMealCount: vm.countPlanedMealForDate(date: date),
                        targetMealCount: userViewModel.userProfile?.totalMeals ?? 0
                    ) { date in
                        vm.setCurrentDate(date: date)
                    }
                }
            }
            .padding(.vertical, theme.layout.padding)
        }
        .contentMargins(.leading, theme.layout.padding)
        .contentMargins(.trailing, theme.layout.padding)
    }

    private var nutritionCard: some View {
        if let surgeryDateTimeStamp = userViewModel.userProfile?.surgeryDateTimeStamp {
            return AnyView(
                CurrentCalorienLevel(
                    operationTimestamp: Int64(surgeryDateTimeStamp),
                    protein: vm.totalNutrition(for: .protein),
                    carbs: vm.totalNutrition(for: .carbs),
                    sugar: vm.totalNutrition(for: .sugar),
                    fat: vm.totalNutrition(for: .fat)
                )
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    private var mealSpotsSection: some View {
        if let count = userViewModel.userProfile?.totalMeals {
            return AnyView(
                ForEach(0..<count, id: \.self) { index in
                    if let mealPlan = vm.mealPlanForSelectedDate, mealPlan.slots.count > index {
                        let spot = mealPlan.slots[index]

                        if let recipe = spot.recipe {
                            MealPlanSpotCard(recipe: recipe)
                                .onLongPressGesture {
                                    vm.removeMealSpotFromPlan(mealPlanDay: mealPlan, mealPlanSpotId: spot.MealPlanSpotId.uuidString)
                                }
                        } else {
                            EmptyMealSpot(index: index, date: vm.currentDate)
                        }
                    } else {
                        EmptyMealSpot(index: index, date: vm.currentDate)
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

#Preview {
   MealPlanSpotCard(recipe: mockRecipe)
}

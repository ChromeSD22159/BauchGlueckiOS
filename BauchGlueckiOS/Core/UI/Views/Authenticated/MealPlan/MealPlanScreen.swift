//
//  MealPlanScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftUI

struct MealPlanScreen: View {
    let theme = Theme.shared
    
    let firebase: FirebaseService
    
    @State var viewModel = MealPlanViewModel()
    
    var body: some View {
       
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: theme.padding) {
                
                Text(formattedDate(viewModel.currentDate))
                    .padding(.horizontal, theme.padding)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.dates, id: \.self) { date in
                            DayItem(date: date, selectedDate: viewModel.currentDate) { date in
                                viewModel.currentDate = date
                            }
                        }
                    }
                    .padding(.vertical, theme.padding)
                }
                .contentMargins(.leading, theme.padding)
                .contentMargins(.trailing, theme.padding)
              
                if let surgeryDateTimeStamp = firebase.userProfile?.surgeryDateTimeStamp {
                    CurrentCalorienLevel(
                        operationTimestamp: Int64(surgeryDateTimeStamp),
                        protein: 0,
                        carbs: 0,
                        sugar: 0,
                        fat: 0
                    )
                }
                
                if let count = firebase.userProfile?.totalMeals {
                    ForEach(0..<count, id: \.self) { index in
                        if index == 0 {
                            MealPlanSpotCard(recipe: mockRecipe)
                        } else {
                            EmptyMealSpot(index: index)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .contentMargins(.top, theme.padding)
    }
    
    @ViewBuilder func EmptyMealSpot(
        index: Int,
        onClick: @escaping () -> Void = {}
    ) -> some View {
        HStack {
            Text("\(index + 1).")
            
            Text("Keine Mahlzeit zugewiesen")
            
            Spacer()
            
            Image(systemName: "plus")
                .padding(.horizontal, theme.padding)
                .padding(.vertical, theme.padding + 5)
                .background(theme.backgroundGradient)
                .foregroundStyle(theme.onPrimary)
                .cornerRadius(100)
                .onTapGesture { onClick() }
        }
        .font(.footnote)
        .padding(theme.padding)
        .sectionShadow()
        .padding(.horizontal, theme.padding)
    }
}

#Preview {
   MealPlanSpotCard(recipe: mockRecipe)
}



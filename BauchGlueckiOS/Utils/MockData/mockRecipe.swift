//
//  mockRecipe.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

let mockRecipe = Recipe(
    id: 4,
    mealId: "c6187c8f-7b1b-4b61-b266-661cc325d4a8",
    userId: "ipEn4nWseaU3IHrMV9Wy4Nio4wF2",
    name: "Frittata mit Spinat und Schinken",
    recipeDescription: "Mit diesem Rezept zauberst du im Handumdrehen kleine, herzhafte Spinat-Quiches, die sowohl kalt als auch warm schmecken. Die Kombination aus Blätterteig, Spinat, Schinken und der cremigen Füllung macht diese Quiches zu einem echten Genuss. Perfekt für alle, die schnelle und leckere Rezepte lieben.",
    preparation: "1. Ein Muffinblech, mit 12 Mulden, mit etwas Margarine bestreichen. Den Backofen vorheizen.\n2. 4 Filoteigblätter in 9 Quadrate schneiden und in jede Mulde 3 Quadrate legen.\n3. Den Spinat fein hacken und auf die Mulden verteilen.\n4. Den Schinken würfeln und auf den Spinat geben.\n5. Die Eier, Ziegenjoghurt und Gewürze mit dem Schneebesen zu einer Eiermilch verrühren und gleichmäßig verteilen.\n6. Lauchzwiebel in feine Ringe schneiden und auf die Eiermilch geben.\n7. Backzeit: 30 Minuten, mittlere Schiene, Ober/Unterhitze bei 180 Grad",
    preparationTimeInMinutes: 20,
    protein: 8,
    fat: 4,
    sugar: 5,
    kcal: 88,
    isSnack: false,
    isPrivate: false,
    isDeleted: false,
    updatedAtOnDevice: "1728634606862",
    ingredients: [
        Ingredient(id: 1, component: "", name: "Filoteig", amount: "4", unit: "Blätter"),
        Ingredient(id: 2, component: "", name: "Spinat", amount: "240", unit: "g"),
        Ingredient(id: 3, component: "", name: "Lauchzwiebeln", amount: "3", unit: "Stk"),
        Ingredient(id: 4, component: "", name: "Schinken", amount: "90", unit: "g"),
        Ingredient(id: 5, component: "", name: "Eier", amount: "5", unit: "Stk"),
        Ingredient(id: 6, component: "", name: "griechischer Joghurt", amount: "200", unit: "g")
    ],
    category: Category(id: 4, categoryId: "hauptgericht", name: "Hauptgericht")
)

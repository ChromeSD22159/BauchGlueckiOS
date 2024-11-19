//
//  mockRecipe.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

let mockRecipe = Recipe(
    id: 0,
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

let mockRecipes = [
    Recipe(
        id: 0,
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
    ),
    
    
    
    Recipe(
        id: 1,
        mealId: "6b5f8a7e-8d54-4c5d-9461-1c7e8d5a2b1a",
        userId: "user123",
        name: "Avocado-Toast mit pochiertem Ei",
        recipeDescription: "Ein einfaches, gesundes und leckeres Frühstück. Perfekt für den Start in den Tag.",
        preparation: "1. Avocado halbieren, Kern entfernen und das Fruchtfleisch mit einer Gabel zerdrücken.\n2. Brot toasten und mit Avocado bestreichen.\n3. Wasser aufkochen, Essig hinzufügen und ein Ei vorsichtig ins Wasser gleiten lassen. 3 Minuten pochieren.\n4. Ei auf den Avocado-Toast legen und mit Salz, Pfeffer und Chili bestreuen.",
        preparationTimeInMinutes: 15,
        protein: 12,
        fat: 15,
        sugar: 2,
        kcal: 250,
        isSnack: false,
        isPrivate: false,
        isDeleted: false,
        updatedAtOnDevice: "1728634606863",
        ingredients: [
            Ingredient(id: 1, component: "", name: "Avocado", amount: "1", unit: "Stk"),
            Ingredient(id: 2, component: "", name: "Brot", amount: "2", unit: "Scheiben"),
            Ingredient(id: 3, component: "", name: "Ei", amount: "1", unit: "Stk"),
            Ingredient(id: 4, component: "", name: "Essig", amount: "1", unit: "TL")
        ],
        category: Category(id: 1, categoryId: "fruehstueck", name: "Frühstück")
    ),
    
    
    Recipe(
        id: 2,
        mealId: "8c9b7a3f-45d8-41a5-96c3-bf678c4c1234",
        userId: "user123",
        name: "Griechischer Salat",
        recipeDescription: "Ein klassischer griechischer Salat mit frischem Gemüse, Feta und Oliven. Perfekt für den Sommer.",
        preparation: "1. Tomaten, Gurken und Paprika in Würfel schneiden.\n2. Zwiebel in dünne Ringe schneiden.\n3. Alles in eine Schüssel geben und mit Oliven, Feta und Dressing vermengen.",
        preparationTimeInMinutes: 10,
        protein: 6,
        fat: 10,
        sugar: 4,
        kcal: 150,
        isSnack: false,
        isPrivate: false,
        isDeleted: false,
        updatedAtOnDevice: "1728634606864",
        ingredients: [
            Ingredient(id: 1, component: "", name: "Tomaten", amount: "200", unit: "g"),
            Ingredient(id: 2, component: "", name: "Gurke", amount: "1", unit: "Stk"),
            Ingredient(id: 3, component: "", name: "Paprika", amount: "1", unit: "Stk"),
            Ingredient(id: 4, component: "", name: "Feta", amount: "100", unit: "g"),
            Ingredient(id: 5, component: "", name: "Oliven", amount: "50", unit: "g")
        ],
        category: Category(id: 2, categoryId: "salat", name: "Salat")
    ),
    
    
    Recipe(
        id: 3,
        mealId: "0a8c1f3e-9b34-4abc-947e-4c1234d5f678",
        userId: "user123",
        name: "Pasta Carbonara",
        recipeDescription: "Ein italienischer Klassiker mit Speck, Ei und Parmesan.",
        preparation: "1. Pasta in Salzwasser kochen.\n2. Speck in einer Pfanne anbraten.\n3. Eier mit Parmesan verrühren.\n4. Pasta abgießen, mit Speck und Ei-Parmesan-Mischung vermengen.",
        preparationTimeInMinutes: 20,
        protein: 15,
        fat: 12,
        sugar: 3,
        kcal: 350,
        isSnack: false,
        isPrivate: false,
        isDeleted: false,
        updatedAtOnDevice: "1728634606865",
        ingredients: [
            Ingredient(id: 1, component: "", name: "Pasta", amount: "200", unit: "g"),
            Ingredient(id: 2, component: "", name: "Speck", amount: "100", unit: "g"),
            Ingredient(id: 3, component: "", name: "Eier", amount: "2", unit: "Stk"),
            Ingredient(id: 4, component: "", name: "Parmesan", amount: "50", unit: "g")
        ],
        category: Category(id: 3, categoryId: "hauptgericht", name: "Hauptgericht")
    ),
    
    
    
    Recipe(
        id: 4,
        mealId: "7f5d3b2e-8a1f-4c23-95d7-c4f1236789ab",
        userId: "user123",
        name: "Veganes Curry",
        recipeDescription: "Ein einfaches, würziges Curry mit Kokosmilch und Gemüse.",
        preparation: "1. Zwiebeln und Knoblauch anbraten.\n2. Gemüse hinzufügen und kurz mitbraten.\n3. Mit Kokosmilch ablöschen, Gewürze hinzufügen und köcheln lassen.",
        preparationTimeInMinutes: 30,
        protein: 10,
        fat: 8,
        sugar: 6,
        kcal: 200,
        isSnack: false,
        isPrivate: false,
        isDeleted: false,
        updatedAtOnDevice: "1728634606866",
        ingredients: [
            Ingredient(id: 1, component: "", name: "Zwiebeln", amount: "1", unit: "Stk"),
            Ingredient(id: 2, component: "", name: "Knoblauchzehen", amount: "2", unit: "Stk"),
            Ingredient(id: 3, component: "", name: "Gemüse", amount: "300", unit: "g"),
            Ingredient(id: 4, component: "", name: "Kokosmilch", amount: "200", unit: "ml")
        ],
        category: Category(id: 4, categoryId: "hauptgericht", name: "Hauptgericht")
    ),
    
    
    Recipe(
        id: 5,
        mealId: "5d4f7a1b-8e23-4b4c-9d7a-bf6c4e123456",
        userId: "user123",
        name: "Bananen-Smoothie",
        recipeDescription: "Ein schneller, gesunder Smoothie für zwischendurch.",
        preparation: "1. Alle Zutaten in einen Mixer geben und fein pürieren.\n2. In ein Glas füllen und genießen.",
        preparationTimeInMinutes: 5,
        protein: 5,
        fat: 2,
        sugar: 15,
        kcal: 120,
        isSnack: true,
        isPrivate: false,
        isDeleted: false,
        updatedAtOnDevice: "1728634606867",
        ingredients: [
            Ingredient(id: 1, component: "", name: "Banane", amount: "1", unit: "Stk"),
            Ingredient(id: 2, component: "", name: "Milch", amount: "200", unit: "ml"),
            Ingredient(id: 3, component: "", name: "Honig", amount: "1", unit: "TL")
        ],
        category: Category(id: 5, categoryId: "getraenk", name: "Getränk")
    )
]

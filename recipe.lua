local ingredients = {}

ingredients.fileIdentities = {
    "startup.lua",
    "recipe.lua",
    "SystemCatalyst/beginTheAlchemy.lua",
    "SystemCatalyst/alchemyCore.lua",
    "SystemFiles/lastWillAndTestament.txt"
}

ingredients.localOnlyFiles = {
    ["SystemCatalyst/globals.lua"] = true
}

ingredients.version = "0.1.12d"

return ingredients
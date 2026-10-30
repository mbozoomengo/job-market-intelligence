// ref_CategoryMap
// Groupe de requêtes Power Query : 02_Reference
let
    Source = fnLoadRef("ref_category_map.csv"),
    Typed  = Table.TransformColumnTypes(Source, {{"CategoryRaw", type text}, {"OfferNatureCode", type text}})
in
    Typed

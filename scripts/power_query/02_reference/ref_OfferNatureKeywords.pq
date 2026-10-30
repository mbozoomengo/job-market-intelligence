// ref_OfferNatureKeywords
// Groupe de requêtes Power Query : 02_Reference
let
    Source = fnLoadRef("ref_offer_nature_keywords.csv"),
    Typed  = Table.TransformColumnTypes(Source, {{"Priority", Int64.Type}, {"Keyword", type text}, {"OfferNatureCode", type text}}),
    Lower  = Table.TransformColumns(Typed, {{"Keyword", Text.Lower, type text}})
in
    Lower

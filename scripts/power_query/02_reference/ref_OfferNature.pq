// ref_OfferNature
// Groupe de requêtes Power Query : 02_Reference
let
    Source = fnLoadRef("ref_offer_nature.csv"),
    Bool   = Table.TransformColumns(Source, {{"IsJobOffer", Logical.FromText, type logical}}),
    Typed  = Table.TransformColumnTypes(Bool, {{"OfferNatureCode", type text}, {"OfferNature", type text}, {"OfferGroup", type text}, {"SortOrder", Int64.Type}})
in
    Typed

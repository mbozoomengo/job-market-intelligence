// Table du modèle : Dim_Location (mode Import)
// Groupe de requêtes Power Query : 04_Model
let
    Ref  = Table.TransformColumnTypes(ref_Location,
             {{"LocationCode", type text}, {"City", type text}, {"Region", type text}, {"Scope", type text},
              {"Country", type text}, {"Latitude", Currency.Type}, {"Longitude", Currency.Type}}, "en-US"),
    Tech = #table(type table [LocationCode = text, City = text, Region = text, Scope = text,
                              Country = text, Latitude = Currency.Type, Longitude = Currency.Type],
             {{"NONE", "Description absente", "Unknown", "Unknown", null, null, null},
              {"UNMAPPED", "To map", "Unknown", "Unknown", null, null, null}}),
    Final = Table.Combine({Ref, Tech})
in
    Final

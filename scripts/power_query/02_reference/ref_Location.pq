// ref_Location
// Groupe de requêtes Power Query : 02_Reference
let
    Source  = fnLoadRef("ref_location.csv"),
    NoEmpty = Table.ReplaceValue(Source, "", null, Replacer.ReplaceValue, Table.ColumnNames(Source)),
    Lower   = Table.TransformColumns(NoEmpty, {{"LocationCode", Text.Lower, type text}})
in
    Lower

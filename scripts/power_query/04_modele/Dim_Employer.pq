// Table du modèle : Dim_Employer (mode Import)
// Groupe de requêtes Power Query : 04_Model
let
    Slugs   = Table.Distinct(Table.SelectColumns(int_Offres, {"EmployerSlug"})),
    Merged  = Table.NestedJoin(Slugs, {"EmployerSlug"}, ref_Employer, {"EmployerSlug"}, "Ref", JoinKind.LeftOuter),
    Exp     = Table.ExpandTableColumn(Merged, "Ref", {"EmployerName", "EmployerType"}, {"RefName", "RefType"}),
    AddMap  = Table.AddColumn(Exp, "IsMapped", each [RefName] <> null, type logical),
    AddName = Table.AddColumn(AddMap, "EmployerName", each [RefName] ??
                (if [EmployerSlug] = "unknown" then "Unknown"
                 else Text.Proper(Text.Replace([EmployerSlug], "-", " "))), type text),
    AddType = Table.AddColumn(AddName, "EmployerType", each [RefType] ?? "To classify", type text),
    Final   = Table.SelectColumns(AddType, {"EmployerSlug", "EmployerName", "EmployerType", "IsMapped"})
in
    Final

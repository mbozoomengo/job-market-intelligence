// ref_JobFamily
// Groupe de requêtes Power Query : 02_Reference
let
    Source = fnLoadRef("ref_job_family.csv"),
    Typed  = Table.TransformColumnTypes(Source, {{"JobFamilyCode", type text}, {"JobFamily", type text}, {"FamilyGroup", type text}, {"SortOrder", Int64.Type}})
in
    Typed

// ref_JobFamilyKeywords
// Groupe de requêtes Power Query : 02_Reference
let
    Source = fnLoadRef("ref_job_family_keywords.csv"),
    Typed  = Table.TransformColumnTypes(Source, {{"Priority", Int64.Type}, {"Keyword", type text}, {"JobFamilyCode", type text}}),
    Lower  = Table.TransformColumns(Typed, {{"Keyword", Text.Lower, type text}})
in
    Lower

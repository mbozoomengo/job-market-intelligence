// ref_JobFamilyOverride
// Groupe de requêtes Power Query : 02_Reference
let
    Source = fnLoadRef("ref_job_family_override.csv"),
    Typed  = Table.TransformColumnTypes(Source, {{"OfferID", Int64.Type}, {"JobFamilyCode", type text}, {"Reason", type text}})
in
    Typed

// ref_Employer
// Groupe de requêtes Power Query : 02_Reference
let
    Source = fnLoadRef("ref_employer.csv"),
    Typed  = Table.TransformColumnTypes(Source, {{"EmployerSlug", type text}, {"EmployerName", type text}, {"EmployerType", type text}})
in
    Typed

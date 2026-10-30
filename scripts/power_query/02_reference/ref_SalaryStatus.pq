// ref_SalaryStatus
// Groupe de requêtes Power Query : 02_Reference
let
    Source = fnLoadRef("ref_salary_status.csv"),
    Bool   = Table.TransformColumns(Source, {{"IsPayStated", Logical.FromText, type logical}}),
    Typed  = Table.TransformColumnTypes(Bool, {{"SalaryStatusCode", type text}, {"SalaryStatus", type text}, {"SortOrder", Int64.Type}})
in
    Typed

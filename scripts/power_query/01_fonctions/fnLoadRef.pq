// fnLoadRef
// Loads a UTF-8 reference CSV from pRefFolder with promoted headers (all columns text).
// Groupe de requêtes Power Query : 01_Functions
(fileName as text) as table =>
let
    Source   = Csv.Document(File.Contents(pRefFolder & fileName),
                 [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true])
in
    Promoted

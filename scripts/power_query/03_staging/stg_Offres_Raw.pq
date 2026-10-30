// stg_Offres_Raw
// Raw extract typed and cleaned (NBSP / zero-width removed), stamped with CollectionDate.
// Groupe de requêtes Power Query : 03_Staging
let
    Source    = Csv.Document(File.Contents(pSourcePath),
                  [Delimiter = ",", Columns = 3, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Promoted  = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // BOM safety: force the first header name
    Renamed   = Table.RenameColumns(Promoted, {{Table.ColumnNames(Promoted){0}, "titre"}}),
    Typed     = Table.TransformColumnTypes(Renamed,
                  {{"titre", type text}, {"lien", type text}, {"description", type text}}),
    CleanText = (t as nullable text) as nullable text =>
                  let x = Text.Trim(Text.Clean(
                            Text.Replace(Text.Replace(t ?? "", "#(00A0)", " "), "#(200B)", "")))
                  in if x = "" then null else x,
    Cleaned   = Table.TransformColumns(Typed,
                  {{"titre", CleanText, type nullable text},
                   {"lien", CleanText, type nullable text},
                   {"description", CleanText, type nullable text}}),
    NoBlankLink = Table.SelectRows(Cleaned, each [lien] <> null),
    AddCollect  = Table.AddColumn(NoBlankLink, "CollectionDate", each pCollectionDate, type date),
    AddDescLen  = Table.AddColumn(AddCollect, "DescLen", each Text.Length([description] ?? ""), Int64.Type),
    AddRowNo    = Table.AddIndexColumn(AddDescLen, "SourceRow", 1, 1, Int64.Type)
in
    AddRowNo

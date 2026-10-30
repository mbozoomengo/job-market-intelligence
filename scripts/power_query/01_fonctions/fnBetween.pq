// fnBetween
// Safe extraction of the trimmed text between two delimiters; null when start delimiter is missing or result is empty.
// Groupe de requêtes Power Query : 01_Functions
(txt as nullable text, startDelim as text, endDelim as text) as nullable text =>
let
    Result =
        if txt = null or not Text.Contains(txt, startDelim) then null
        else
            let
                after = Text.AfterDelimiter(txt, startDelim),
                raw   = if Text.Contains(after, endDelim)
                        then Text.BeforeDelimiter(after, endDelim)
                        else after,
                t     = Text.Trim(raw)
            in
                if t = "" then null else t
in
    Result

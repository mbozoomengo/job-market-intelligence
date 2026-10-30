// fnPositions
// Number of positions announced in a title: number before 'poste', else sum of standalone numbers, else 1; 0 for non-job ads.
// Groupe de requêtes Power Query : 01_Functions
(title as nullable text) as number =>
let
    s        = Text.Lower(title ?? ""),
    nonJob   = List.AnyTrue(List.Transform(
                 {"request for", "appel d’offres", "appel d'offres", "bourses",
                  "vip", "assurances", "spontan"},
                 each Text.Contains(s, _))),
    spaced   = Text.Replace(Text.Replace(Text.Replace(s, ",", " "), "(", " ( "), ")", " ) "),
    tokens   = List.Select(Text.Split(spaced, " "), each _ <> ""),
    numAt    = (i as number) => try Number.From(tokens{i}, "en-US") otherwise null,
    idx      = List.PositionOf(List.Transform(tokens, each Text.StartsWith(_, "poste")), true),
    before   = if idx > 0 then numAt(idx - 1) else null,
    loose    = List.RemoveNulls(List.Transform(List.Positions(tokens), each
                 let n = numAt(_) in
                 if n <> null and n >= 1 and n < 1000 and (_ = 0 or tokens{_ - 1} <> "(")
                 then n else null)),
    Result   = if nonJob then 0
               else if before <> null then before
               else if List.Count(loose) > 0 then List.Sum(loose)
               else 1
in
    Result

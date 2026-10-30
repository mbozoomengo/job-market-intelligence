// int_Offres
// One row per unique ad per collection: dedup on lien, URL keys, description fields, reference-driven classifications.
// Groupe de requêtes Power Query : 03_Staging
let
    Source   = stg_Offres_Raw,

    // 1. Deduplicate on lien, keep the richest row, count raw duplicates
    Grouped  = Table.Group(Source, {"lien", "CollectionDate"},
                 {{"RawRowCount", each Table.RowCount(_), Int64.Type},
                  {"Best", each Table.Max(_, "DescLen"), type record}}),
    Expanded = Table.ExpandRecordColumn(Grouped, "Best", {"titre", "description"}),

    // 2. Keys from the URL
    AddUrlTail   = Table.AddColumn(Expanded, "UrlTail",
                     each Text.AfterDelimiter([lien], "emplois-stage-recrutement/"), type text),
    AddOfferID   = Table.AddColumn(AddUrlTail, "OfferID",
                     each try Int64.From(Text.Split([UrlTail], "/"){0}) otherwise null, Int64.Type),
    AddSlug      = Table.AddColumn(AddOfferID, "UrlSlug",
                     each try Text.Split([UrlTail], "/"){1} otherwise null, type nullable text),
    AddEmpSlug   = Table.AddColumn(AddSlug, "EmployerSlug",
                     each if [UrlSlug] <> null and Text.Contains([UrlSlug], "-at-")
                          then Text.AfterDelimiter([UrlSlug], "-at-", {0, RelativePosition.FromEnd})
                          else "unknown", type text),

    // 3. Description flags and structured fields
    AddHasDesc   = Table.AddColumn(AddEmpSlug, "HasDescription", each [description] <> null, type logical),
    AddLocSlug   = Table.AddColumn(AddHasDesc, "LocationSlug",
                     each fnBetween([description], "Localisation :", " Date de publication"), type nullable text),
    AddPubDate   = Table.AddColumn(AddLocSlug, "PublicationDate",
                     each try Date.FromText(fnBetween([description], "Date de publication :", " Catégorie"),
                                            [Format = "dd/MM/yyyy", Culture = "fr-FR"]) otherwise null,
                     type nullable date),
    AddCategory  = Table.AddColumn(AddPubDate, "CategoryRaw",
                     each fnBetween([description], "Catégorie :", " Salaire"), type nullable text),
    AddSalary    = Table.AddColumn(AddCategory, "SalaryRaw",
                     each fnBetween([description], "Salaire :", "©"), type nullable text),

    // 4. Location code (first token of the slug)
    AddLocCode   = Table.AddColumn(AddSalary, "LocationCodeRaw",
                     each if [LocationSlug] = null then "NONE"
                          else Text.Lower(Text.BeforeDelimiter([LocationSlug], "-")), type text),
    RefLoc       = List.Buffer(ref_Location[LocationCode]),
    AddLocKey    = Table.AddColumn(AddLocCode, "LocationCode",
                     each if [LocationCodeRaw] = "NONE" then "NONE"
                          else if List.Contains(RefLoc, [LocationCodeRaw]) then [LocationCodeRaw]
                          else "UNMAPPED", type text),

    // 5. Job family (keyword dictionary, lowest priority number wins) + manual override
    KW           = Table.Buffer(ref_JobFamilyKeywords),
    AddFamAuto   = Table.AddColumn(AddLocKey, "JobFamilyAuto", each
                     let s = Text.Lower([titre] ?? ""),
                         hits = Table.SelectRows(KW, (r) => Text.Contains(s, r[Keyword]))
                     in if Table.IsEmpty(hits) then "UNC"
                        else Table.First(Table.Sort(hits, {{"Priority", Order.Ascending}}))[JobFamilyCode],
                     type text),
    MergeOvr     = Table.NestedJoin(AddFamAuto, {"OfferID"}, ref_JobFamilyOverride, {"OfferID"},
                     "Ovr", JoinKind.LeftOuter),
    ExpOvr       = Table.ExpandTableColumn(MergeOvr, "Ovr", {"JobFamilyCode"}, {"JobFamilyOvr"}),
    AddFamily    = Table.AddColumn(ExpOvr, "JobFamilyCode",
                     each [JobFamilyOvr] ?? [JobFamilyAuto], type text),

    // 6. Offer nature: title keywords first, then category mapping, then fallback
    NK           = Table.Buffer(ref_OfferNatureKeywords),
    CM           = Table.Buffer(ref_CategoryMap),
    AddNature    = Table.AddColumn(AddFamily, "OfferNatureCode", each
                     let s     = Text.Lower([titre] ?? ""),
                         cr    = [CategoryRaw],
                         hits  = Table.SelectRows(NK, (r) => Text.Contains(s, r[Keyword])),
                         byKw  = if Table.IsEmpty(hits) then null
                                 else Table.First(Table.Sort(hits, {{"Priority", Order.Ascending}}))[OfferNatureCode],
                         cat   = Table.SelectRows(CM, (r) => r[CategoryRaw] = cr),
                         byCat = if Table.IsEmpty(cat) then null else cat{0}[OfferNatureCode],
                         fallback = if Text.Contains(s, "stage") or Text.Contains(s, "stagiaire") then "INT"
                                    else if [HasDescription] then "OTH" else "JOB_UNK"
                     in byKw ?? byCat ?? fallback, type text),

    // 7. Salary status
    AddSalCode   = Table.AddColumn(AddNature, "SalaryStatusCode", each
                     let s = Text.Lower([SalaryRaw] ?? "") in
                     if [SalaryRaw] = null then "MISSING"
                     else if Text.Contains(s, "negocier") or Text.Contains(s, "négocier") then "NEG"
                     else if Text.Contains(s, "payant") then "FEE"
                     else if Text.Contains(s, "non r") then "UNP"
                     else if Text.Contains(s, "fonction publique") then "GRID"
                     else if Text.Contains(s, "fcfa") or Text.Contains(s, "brut")
                             or List.ContainsAny(Text.ToList(s), {"0".."9"}) then "AMT"
                     else "NA", type text),

    // 8. Positions and recency
    AddPositions = Table.AddColumn(AddSalCode, "PositionsCount", each fnPositions([titre]), Int64.Type),
    AddAge       = Table.AddColumn(AddPositions, "DaysSincePublication",
                     each if [PublicationDate] = null then null
                          else Duration.Days([CollectionDate] - [PublicationDate]), Int64.Type),
    AddRecent    = Table.AddColumn(AddAge, "IsRecent7d",
                     each [DaysSincePublication] <> null and [DaysSincePublication] < 7, type logical),
    AddDescStat  = Table.AddColumn(AddRecent, "DescriptionStatus",
                     each if [HasDescription] then "Described" else "Description absente", type text),

    Result = Table.RemoveColumns(AddDescStat, {"UrlTail", "JobFamilyAuto", "JobFamilyOvr", "LocationCodeRaw"})
in
    Result

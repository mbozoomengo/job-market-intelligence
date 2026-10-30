// Table du modèle : Fact_Offres (mode Import)
// Groupe de requêtes Power Query : 04_Model
let
    Source = int_Offres,
    AddKey = Table.AddColumn(Source, "OfferKey", each
               Text.From([OfferID] ?? -1) & "|" & Date.ToText([CollectionDate], "yyyyMMdd"), type text),
    Renamed = Table.RenameColumns(AddKey, {{"titre", "Title"}, {"lien", "OfferURL"}}),
    Selected = Table.SelectColumns(Renamed,
      {"OfferKey", "OfferID", "PublicationDate", "CollectionDate", "LocationCode", "EmployerSlug",
       "OfferNatureCode", "JobFamilyCode", "SalaryStatusCode", "Title", "OfferURL",
       "DescriptionStatus", "HasDescription", "PositionsCount", "RawRowCount",
       "DaysSincePublication", "IsRecent7d", "SalaryRaw"})
in
    Selected

// Table du modèle : Audit_Collection (mode Import)
// Groupe de requêtes Power Query : 04_Model
let
    Raw   = Table.Group(stg_Offres_Raw, {"CollectionDate"},
              {{"RawRows", each Table.RowCount(_), Int64.Type}}),
    Uniq  = Table.Group(int_Offres, {"CollectionDate"}, {
              {"UniqueAds",          each Table.RowCount(_), Int64.Type},
              {"AdsWithDescription", each List.Count(List.Select([HasDescription], each _)), Int64.Type},
              {"AdsWithLocation",    each List.Count(List.Select([LocationCode], each _ <> "NONE" and _ <> "UNMAPPED")), Int64.Type},
              {"AdsWithPubDate",     each List.Count(List.RemoveNulls([PublicationDate])), Int64.Type},
              {"AdsWithEmployer",    each List.Count(List.Select([EmployerSlug], each _ <> "unknown")), Int64.Type},
              {"AdsWithJobFamily",   each List.Count(List.Select([JobFamilyCode], each _ <> "UNC")), Int64.Type},
              {"DuplicateOfferIDs",  each List.Count([OfferID]) - List.Count(List.Distinct([OfferID])), Int64.Type}}),
    Joined = Table.NestedJoin(Raw, {"CollectionDate"}, Uniq, {"CollectionDate"}, "U", JoinKind.LeftOuter),
    Final  = Table.ExpandTableColumn(Joined, "U",
              {"UniqueAds", "AdsWithDescription", "AdsWithLocation", "AdsWithPubDate",
               "AdsWithEmployer", "AdsWithJobFamily", "DuplicateOfferIDs"}),
    Typed  = Table.TransformColumnTypes(Final, {{"UniqueAds", Int64.Type}, {"AdsWithDescription", Int64.Type},
              {"AdsWithLocation", Int64.Type}, {"AdsWithPubDate", Int64.Type}, {"AdsWithEmployer", Int64.Type},
              {"AdsWithJobFamily", Int64.Type}, {"DuplicateOfferIDs", Int64.Type}})
in
    Typed

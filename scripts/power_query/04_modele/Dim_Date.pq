// Table du modèle : Dim_Date (mode Import)
// Groupe de requêtes Power Query : 04_Model
let
    Dates   = List.RemoveNulls(int_Offres[PublicationDate] & int_Offres[CollectionDate]),
    StartD  = #date(Date.Year(List.Min(Dates)), 1, 1),
    EndD    = #date(Date.Year(List.Max(Dates)), 12, 31),
    DateList = List.Dates(StartD, Duration.Days(EndD - StartD) + 1, #duration(1, 0, 0, 0)),
    T       = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    Typed   = Table.TransformColumnTypes(T, {{"Date", type date}}),
    AddCols = Table.AddColumn(Typed, "Attrs", each
                let th = Date.AddDays([Date], 3 - Date.DayOfWeek([Date], Day.Monday)),
                    wk = Number.IntegerDivide(Date.DayOfYear(th) - 1, 7) + 1
                in [
                Year      = Date.Year([Date]),
                MonthNo   = Date.Month([Date]),
                Month     = Date.ToText([Date], "MMM", "en-GB"),
                YearMonth = Date.ToText([Date], "yyyy-MM"),
                ISOWeek   = wk,
                YearWeek  = Text.From(Date.Year(th)) & "-W" & Text.PadStart(Text.From(wk), 2, "0"),
                WeekdayNo = Date.DayOfWeek([Date], Day.Monday) + 1,
                Weekday   = Date.ToText([Date], "ddd", "en-GB")]),
    Expanded = Table.ExpandRecordColumn(AddCols, "Attrs",
                {"Year", "MonthNo", "Month", "YearMonth", "ISOWeek", "YearWeek", "WeekdayNo", "Weekday"}),
    Final    = Table.TransformColumnTypes(Expanded,
                {{"Year", Int64.Type}, {"MonthNo", Int64.Type}, {"Month", type text}, {"YearMonth", type text},
                 {"ISOWeek", Int64.Type}, {"YearWeek", type text}, {"WeekdayNo", Int64.Type}, {"Weekday", type text}})
in
    Final

// =============================================================================
//  Power Query (M) | load and type the Online Shoppers dataset
//  Home > Transform data > (right-click query) > Advanced Editor > paste this.
//  Rename the query to:  Shoppers
//  Update the file path in Source to match your machine.
//
//  Region, Browser, OperatingSystems and TrafficType are CATEGORY CODES, so
//  they are typed as Text. Left numeric, Power BI would try to sum them.
// =============================================================================
let
    Source = Csv.Document(
        File.Contents("C:\path\to\data\online_shoppers_intention.csv"),
        [Delimiter = ",", Columns = 18, Encoding = 65001, QuoteStyle = QuoteStyle.None]
    ),

    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    ChangedTypes = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"Administrative", Int64.Type},
            {"Administrative_Duration", type number},
            {"Informational", Int64.Type},
            {"Informational_Duration", type number},
            {"ProductRelated", Int64.Type},
            {"ProductRelated_Duration", type number},
            {"BounceRates", type number},
            {"ExitRates", type number},
            {"PageValues", type number},
            {"SpecialDay", type number},
            {"Month", type text},
            {"OperatingSystems", type text},
            {"Browser", type text},
            {"Region", type text},
            {"TrafficType", type text},
            {"VisitorType", type text},
            {"Weekend", type logical},
            {"Revenue", type logical}
        },
        "en-US"
    )
in
    ChangedTypes

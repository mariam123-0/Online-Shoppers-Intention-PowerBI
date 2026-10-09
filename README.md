# 🛒 E-Commerce Conversion Dashboard

An interactive **Power BI** dashboard to answer that question using 12,330 e-commerce sessions (UCI Online Shoppers Purchasing Intention dataset), where roughly 15.5% of sessions ended in a purchase.


---

## 📌 Table of Contents

1. [Project Overview](#-project-overview)
2. [Business Questions](#-business-questions)
3. [Dataset](#-dataset)
4. [Dashboard Pages](#-dashboard-pages)
5. [Key Insights](#-key-insights)
6. [Data Preparation (Power Query)](#-data-preparation-power-query)
7. [Data Model & DAX](#-data-model--dax)
8. [Design System](#-design-system)
9. [Interactivity](#-interactivity)
10. [Repository Structure](#-repository-structure)
11. [Dataset Citation](#-dataset-citation)

---

## 🎯 Project Overview

Online stores attract thousands of visitors, but only a small share ever buy. This project analyzes **12,330 browsing sessions** to find out *which behaviors and traffic sources separate buyers from non-buyers*.

The result is a 3-page, dark-themed dashboard that moves from the big picture (KPIs and trend) to behavioral drivers (engagement metrics) to acquisition context (traffic, region, device).

| Metric | Value |
|---|---|
| Sessions analyzed | **12,330** |
| Purchases | **1,908** |
| Overall conversion rate | **≈ 15.5%** |
| Dashboard pages | 3 |
| Canvas size | 1280 × 720 |

**Skills demonstrated:** data cleaning with Power Query · data modeling · DAX (measures, calculated columns, binning, dynamic formatting) · dashboard UX design · custom theming · interactive filtering.

---

## ❓ Business Questions

1. How many sessions turn into purchases, and how does conversion change month by month?
2. Do **new** visitors convert differently from **returning** visitors?
3. Does spending **more time on product pages** increase conversion?
4. Do sessions with a **low bounce rate** convert more often?
5. How do **exit rate** and **page values** relate to purchasing?
6. Which **traffic types, regions, browsers and operating systems** convert best?
7. Is there a **weekend** effect?

---

## 📊 Dataset

**Online Shoppers Purchasing Intention Dataset** (UCI Machine Learning Repository). Each row is one browsing session.

| Column | Type | Description |
|---|---|---|
| `Administrative`, `Informational`, `ProductRelated` | Integer | Number of pages visited per category |
| `*_Duration` | Decimal | Seconds spent on each page category |
| `BounceRates` | Decimal | Share of visits that left after one page (stored as a fraction, `0.02` = 2%) |
| `ExitRates` | Decimal | Share of pageviews that were the last in the session |
| `PageValues` | Decimal | Average value of pages visited before a transaction |
| `SpecialDay` | Decimal | Closeness of the visit to a special day |
| `Month` | Text | Month of the visit (no Jan or Apr in the data) |
| `OperatingSystems`, `Browser`, `Region`, `TrafficType` | Text (code) | **Category codes**, not quantities |
| `VisitorType` | Text | New, Returning or Other |
| `Weekend` | Boolean | Visit happened on a weekend |
| `Revenue` | Boolean | **Target**: session ended in a purchase |

> **Gotcha:** `Region`, `Browser`, `OperatingSystems` and `TrafficType` are numbers in the CSV but are really *labels*. They are converted to Text, otherwise Power BI sums them.

---

## 🖥 Dashboard Pages

### 1️⃣ Executive Overview
![image alter](https://github.com/mariam123-0/Online-Shoppers-Intention-PowerBI/blob/f1332c75c2fde855640af202e5f2a8124b6834f3/design/screenshots/Overview.png)

- **KPI cards:** Sessions · Purchases · Conversion Rate · Avg Page Value
- **Monthly Conversion Rate:** smoothed area chart
- **Conversion by Visitor Type** and **by Weekend:** pill-style bars

### 2️⃣ Customer Behavior
![image alter](https://github.com/mariam123-0/Online-Shoppers-Intention-PowerBI/blob/1e98b88538e8653bf73175aa3788e5b15526d6ef/design/screenshots/Behavior.png)

- **3 range sliders:** Product duration · Bounce rate · Page values
- **6 binned charts:** Visitor Type, Product Pages, Product Duration, Bounce Rate, Exit Rate, Page Values, each against conversion rate

Raw numbers are **grouped into bins** (for example `0–10`, `11–20`, `21–30`, `31+` product pages) so the relationship with conversion is readable.

### 3️⃣ Traffic Analysis
![image alter](https://github.com/mariam123-0/Online-Shoppers-Intention-PowerBI/blob/f1332c75c2fde855640af202e5f2a8124b6834f3/design/screenshots/Traffic.png)

- **Visitor type tile slicer** (All / Returning / New / Other)
- **6 charts:** Traffic Type (Top 6), Region, Browser (Top 6), Operating System (Top 5), Month, Weekend

---

## 💡 Key Insights

> ✏️ **Replace the placeholders below with your own findings and numbers from the dashboard.**

1. **Seasonality:** `[e.g. November converts at X%, compared with Y% in February]`
2. **Page Values:** `[e.g. sessions with PageValues above 50 convert at X%, versus Y% when PageValues is 0]`
3. **Visitor type:** `[e.g. new visitors convert X points higher than returning visitors]`
4. **Engagement:** `[e.g. sessions with 0% bounce rate convert at X%]`
5. **Traffic:** `[e.g. traffic type N is the strongest source, but check its session volume]`

---

## 🧹 Data Preparation (Power Query)

Full script: [`powerquery/transform.m`](powerquery/transform.m)

Steps performed:
1. Imported the CSV and promoted headers.
2. Renamed the query to `Shoppers`.
3. Set numeric types for the behavioral metrics.
4. Set **`Region`, `Browser`, `OperatingSystems`, `TrafficType` to Text** and *Don't summarize*.
5. Set `Weekend` and `Revenue` to True/False.

```m
{"OperatingSystems", type text},
{"Browser", type text},
{"Region", type text},
{"TrafficType", type text},
{"Weekend", type logical},
{"Revenue", type logical}
```

---

## 🧮 Data Model & DAX

A **single flat table** (`Shoppers`) with a separate `_Measures` table for measures. No relationships are needed.

All DAX lives in one file: **[`dax/dax_reference.dax`](dax/dax_reference.dax)**. The highlights:

### Core KPIs
```dax
Sessions = COUNTROWS ( Shoppers )

Purchases =
CALCULATE ( COUNTROWS ( Shoppers ), Shoppers[Revenue] = TRUE () )

Conversion Rate = DIVIDE ( [Purchases], [Sessions] )

Avg Page Value = AVERAGE ( Shoppers[PageValues] )
```

### Chronological month sorting
The dataset stores months as text, which sorts alphabetically. A helper column fixes it (then *Sort by column*):
```dax
Month Num =
SWITCH (
    TRUE (),
    Shoppers[Month] = "Feb", 2,
    Shoppers[Month] = "Mar", 3,
    Shoppers[Month] = "May", 5,
    Shoppers[Month] IN { "Jun", "June" }, 6,
    Shoppers[Month] = "Jul", 7,
    Shoppers[Month] = "Aug", 8,
    Shoppers[Month] = "Sep", 9,
    Shoppers[Month] = "Oct", 10,
    Shoppers[Month] = "Nov", 11,
    Shoppers[Month] = "Dec", 12
)
```

### Binning continuous metrics
Each bin has a label column and an order column (used with *Sort by column*):
```dax
Pages Bin =
SWITCH (
    TRUE (),
    Shoppers[ProductRelated] <= 10, "0–10",
    Shoppers[ProductRelated] <= 20, "11–20",
    Shoppers[ProductRelated] <= 30, "21–30",
    "31+"
)
```

| Bin column | Buckets |
|---|---|
| `Pages Bin` | 0–10 · 11–20 · 21–30 · 31+ |
| `Duration Bin` | ≤100s · ≤500s · ≤1500s · 1500s+ |
| `Bounce Bin` | 0% · 0–1% · 1–5% · 5%+ |
| `Exit Bin` | 0–2% · 2–5% · 5–10% · 10%+ |
| `PageValue Bin` | 0 · 0–10 · 10–50 · 50+ |

> Bounce and exit rates are tiny fractions (mostly under 0.2), so the bins are narrow on purpose. Wide bins would put almost every session in one bucket.

### A usable duration slider
`ProductRelated_Duration` reaches ~63,974 seconds, but nearly all sessions are under ~3,000. A capped helper column keeps the slider usable:
```dax
Duration Capped = MIN ( Shoppers[ProductRelated_Duration], 3000 )
```

### Dynamic highlight color
The tallest bar in each chart is pink, computed per filter context:
```dax
Color Month =
IF (
    [Conversion Rate]
        = MAXX ( ALLSELECTED ( Shoppers[Month] ), [Conversion Rate] ),
    "#E879F9",
    "#A855F7"
)
```
Applied via *Columns → Colors → fx → Field value*.

---

## 🎨 Design System

Custom theme: [`theme/numolo_dark_purple_theme.json`](theme/numolo_dark_purple_theme.json) (*View → Themes → Browse for themes*).

| Role | Color |
|---|---|
| Page background | `#0B0716` |
| Cards | `#1A1233` |
| Borders and gridlines | `#2E2352` |
| Primary accent | `#A855F7` |
| Highlight | `#E879F9` |
| Secondary text | `#C4B5FD` |
| Text | `#FFFFFF` |

- **Canvas:** 1280 × 720 (16:9)
- **Font:** Segoe UI / Segoe UI Semibold
- **Layout:** card-based with 16 px rounded corners
- Reference mockups for each page are in [`design/`](design/)

---

## 🕹 Interactivity

| Feature | Where | Detail |
|---|---|---|
| **Page navigator** | All pages | Overview · Behavior · Traffic, active page highlighted |
| **Range sliders** | Behavior | Product duration (capped), Bounce rate, Page values (slicer style *Between*) |
| **Tile slicer** | Traffic | Visitor type with a *Select all* button |
| **Top N filters** | Traffic | Traffic Type (6), Browser (6), Operating System (5) by Sessions |
| **Tooltips** | All charts | Sessions and Purchases shown on hover for sample size |

---

## 📁 Repository Structure

```
Shoppers-Conversion-Dashboard/
├── README.md
├── .gitignore
├── Shoppers_Conversion_Dashboard.pbix      ← the Power BI report
├── data/
│   └── online_shoppers_intention.csv       ← raw dataset
├── powerquery/
│   └── transform.m                         ← data loading and typing
├── dax/
│   └── dax_reference.dax                   ← every column and measure
├── theme/
│   └── numolo_dark_purple_theme.json       ← custom Power BI theme
├── design/                                 ← design mockups (1280×720)
│   ├── page1_executive_overview_1280x720.png
│   ├── page2_customer_behavior_1280x720.png
│   └── page3_traffic_1280x720.png
└── screenshots/                            ← screenshots of the final report
    ├── overview.png
    ├── behavior.png
    └── traffic.png
```

--

## 📚 Dataset Citation

Sakar, C. O., Polat, S. O., Katircioglu, M., & Kastro, Y. (2019). *Real-time prediction of online shoppers' purchasing intention using multilayer perceptron and LSTM recurrent neural networks.* Neural Computing and Applications.
Dataset: [UCI Machine Learning Repository, Online Shoppers Purchasing Intention Dataset](https://archive.ics.uci.edu/dataset/468/online+shoppers+purchasing+intention+dataset). See the UCI page for license terms.

---


*If you found this project useful, a ⭐ on the repo is appreciated.*

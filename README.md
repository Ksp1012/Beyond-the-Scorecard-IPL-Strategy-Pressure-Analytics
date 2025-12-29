# 🏏 IPL Advanced Cricket Analytics using SQL

## 📌 Project Overview

This project presents an end-to-end analytical study of the Indian Premier League (IPL) using **pure SQL**.  
The objective is to uncover **match strategies, pressure performance, and clutch player impact** across **18 seasons of IPL data** by transforming raw ball-by-ball data into meaningful cricket intelligence.

Designed with **interview readiness** in mind, the project demonstrates strong capabilities in data modeling, advanced SQL analytics, and insight-driven storytelling.

---

## 🧩 Dataset

**Source:** Kaggle (Cricsheet-derived IPL dataset, 2008–2025)  (link : https://www.kaggle.com/datasets/chaitu20/ipl-dataset2008-2025?resource=download )
**Records:** 200,000+ ball-by-ball events with 64 columns

### Core Tables
- `ipl_data` → raw imported dataset  
- `ipl_data_stage` → staging table for cleaning  
- `matches` → one row per match  
- `deliveries` → ball-by-ball analytics  
- `team_dim` → standardized team names  
- `venue_dim` → standardized venue names  
- `matches_clean` → cleaned & standardized match data  

---

## 🛠️ Data Engineering & Modeling

### 🔄 Data Processing Pipeline

1. Imported raw CSV into `ipl_data_stage`
2. Cleaned and standardized data:
   - Converted invalid numeric values (`''`, `Unknown`) → `NULL`
   - Standardized boolean values (`TRUE/FALSE` → `1/0`)
   - Corrected date formats and numeric inconsistencies
3. Built analytical tables:
   - `matches` for match-level insights
   - `deliveries` for ball-by-ball analysis
4. Created dimension tables:
   - `team_dim` and `venue_dim`
   - Standardized historical naming inconsistencies  
     *(e.g., Delhi Daredevils → Delhi Capitals, Feroz Shah Kotla → Arun Jaitley Stadium)*

This modeling enables consistent joins, reproducible analytics, and scalable analysis.

---

## 🧱 LEVEL 1 — Foundational Cricket Insights

**Key Questions**
- How many matches & seasons are covered?
- Which venues hosted the most matches?
- Which teams have won the most matches?

**Sample Insight**

> The dataset spans **18 IPL seasons**, with **Wankhede Stadium** hosting the most matches, and **Mumbai Indians** emerging as the most successful franchise.

---

## ⚙️ LEVEL 2 — Match Strategy & Performance

| Strategic Question | Key Finding |
|------------------|-----------|
Does winning the toss matter? | Toss winners win **~50.56%** of matches |
Is chasing or defending better? | **Chasing wins ~53%** of matches |
Which venues favor chasing? | Sharjah (64.29%), Jaipur (64.06%) |
Which teams chase best? | Delhi Daredevils, Rajasthan Royals |
Which teams defend best? | Lucknow Super Giants, MI, CSK |
Which venues are hardest to defend? | Sharjah, Jaipur, Abu Dhabi |

**Insight**

> Venue conditions strongly influence outcomes. Sharjah and Jaipur heavily favor chasing, while Chepauk remains one of the toughest grounds for chases.

---

## 🚀 LEVEL 3 — Advanced Cricket Analytics

### 🧨 1. Best Teams Under High-Pressure Chases

**Pressure Conditions**
- Second innings  
- Required Run Rate ≥ 9  
- Balls Remaining ≤ 30  

**Finding**

> **Gujarat Titans dominate pressure chases (~60% success)**, reflecting exceptional finishing depth, particularly during their 2022–23 peak.  
> **Pune Warriors (~9.5%)** show the weakest performance, highlighting how temperament and squad depth determine success in tight finishes.

---

### 🏏 2. Best Finishers Under Extreme Pressure

**Finisher Definition**
- ≤ 18 balls remaining  
- ≤ 30 runs required  
- Required Run Rate ≥ 8.5  
- Batter not dismissed during pressure phase  
- Strike Rate ≥ 150  

**Elite Finishers Identified**

| Batter | Team | Avg Pressure SR | Win Involvement |
|------|------|---------------|---------------|
AT Rayudu | MI | 208.93 | 87.5% |
David Miller | GT | 151.01 | 87.5% |
SK Raina | CSK | 173.89 | 83.3% |
MS Dhoni | CSK | 231.11 | 58.3% |

> MS Dhoni leads with **36 clutch situations**, reinforcing his reputation as IPL’s most reliable finisher.

---

### 🎯 3. Best Bowlers at Defending Tight Finishes

**Death Pressure Conditions**
- ≤ 18 balls remaining  
- ≤ 30 runs required  
- Required Run Rate ≥ 8.5  

**Metrics**
- Pressure economy  
- Pressure wickets  
- Matches defended  
- Defense success %

**Insight**

> Several bowlers appear frequently in high-pressure overs but still show **0% defense success**, proving that death-over performance must be judged within full match context — not by individual economy alone.

---

## 🧪 Technical Highlights

- Complex multi-CTE queries
- Advanced conditional aggregations
- Window-based pressure modeling
- Fully normalized analytical schema
- End-to-end SQL-driven storytelling


---

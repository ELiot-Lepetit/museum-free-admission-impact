# Museum Free Admission Reform — Causal Impact Evaluation (DiD)

## Overview

This project evaluates the causal impact of France's 2009 free museum 
admission policy for young people (18–25) on museum attendance, using 
a **Difference-in-Differences (DiD)** framework.

The analysis draws on five waves of the French Cultural Practices Survey 
(*Enquête sur les Pratiques Culturelles des Français*, DEPS/Ministère de 
la Culture): 1973, 1981, 1997, 2008, and 2018.

**Main finding:** The reform had no statistically significant effect on 
museum attendance among 18–25 year-olds relative to the 26–33 control 
group. Sociodemographic factors — CSP, education level, agglomeration 
type — are the dominant drivers of attendance.

---
## Repository Structure
```text
├── Scripts/
│   ├── Clean_1973.do      # Data cleaning - 1973 survey
│   ├── Clean_1981.do      # Data cleaning - 1981 survey
│   ├── Clean_1997.do      # Data cleaning - 1997 survey
│   ├── Clean_2008.do      # Data cleaning - 2008 survey
│   ├── Clean_2018.do      # Data cleaning - 2018 survey
│   └── analysis_main.do   # Main Difference-in-Differences regressions & figures
├── Outputs/
│   ├── parallel_trends.pdf  # Parallel trends test plots
│   └── *_distribution.pdf   # Distribution and impact outputs
├── Memoire_Lepetit_Eliot.pdf # Full research paper 
└── README.md
```
---

## Methodology

- **Strategy:** Difference-in-Differences (DiD)
- **Treatment group:** Individuals aged 18–25 (eligible for free admission post-2009)
- **Control group:** Individuals aged 26–33
- **Pre-reform period:** 2008 | **Post-reform period:** 2018
- **Parallel trends validation:** Visual inspection across 1973–2008 waves
- **Robustness:** Multiple imputation of missing values (see Table 4 in paper)
- **Controls:** Gender, education (head of household), agglomeration type, 
  CSP, number of books read

---

## Data Availability

> ⚠️ **Raw data files (`.csv`) are not included in this repository.**

The microdata come from the *Enquête sur les Pratiques Culturelles des 
Français* (DEPS), distributed by [Progedo-Adisp](https://progedo-adisp.fr). 
Access is subject to a research license agreement and redistribution is 
not permitted under its terms.

To replicate this analysis, request access directly via the 
[Progedo-Adisp data catalogue](https://adisp.progedo.fr). 
Once obtained, place the raw files in a `/Data` directory and run the 
cleaning scripts in chronological order before executing `Do_analyse_EL.do`.

---

## Requirements

- **Stata** (developed on Stata 17 — earlier versions likely compatible)
- Packages used: `estout`, `coefplot` *(install via `ssc install` if needed)*

# Clinical Trial Survival Analysis — NMIMS Hackathon 2026

## Team
**Group Name: Stat Attack**
- Jigar Rambhiya
- Sumit Patil
- Aarchi Rastogi

---

## Problem Statement

A pharmaceutical company conducted a single-arm clinical trial 
to assess the efficacy of their drug on 200 lung cancer patients. 
The primary endpoint of interest was the 24-month event-free 
survival rate. A patient was defined to have experienced an event 
only if disease progression occurred or death was recorded.

The standard of care for this diagnosis was widely assumed to have 
a 24-month event-free survival rate of 50%. The trial began on 
01 Jan 2020, and patients were recruited over a period of 24 months. 
The final analysis was conducted with a data cut-off date of 
01 Jan 2024.

Two exercises were solved as part of this project:

**Exercise 1:** Determine whether the study drug's 24-month 
event-free survival rate is significantly better than the 50% 
standard of care, using real trial data.

**Exercise 2:** Simulate a future single-arm trial for liver cancer 
patients using the same drug, where the standard of care has a 
24-month survival rate of 40% and the drug is expected to achieve 
60%. Estimate the probability that the trial will successfully 
demonstrate the drug's superiority.

---

## Dataset Description

The dataset contains records for 200 patients with the following 
variables:

| Variable | Description |
|---|---|
| subject_id | Unique identifier for each patient |
| recruitment_date | Date patient was enrolled in the trial |
| event_or_withdrawal_date | Date of event or withdrawal (blank if neither occurred) |
| reason | Reason for trial discontinuation (blank if completed or lost to follow-up) |

---

## Methodology

### Exercise 1 — Real Data Analysis

**Data Processing:**
- Calculated follow-up duration in months from recruitment date 
  to event or withdrawal date
- Missing end dates were treated as censored observations
- Withdrawal of consent cases were also treated as censored
- Created binary indicators for event status and 24-month outcome

**Statistical Method: Kaplan-Meier Survival Analysis**

The Kaplan-Meier estimator was chosen because:
- It is a non-parametric method requiring no distributional assumptions
- It correctly handles right-censored observations
- It estimates survival probability at each event time point

Confidence intervals were constructed using Greenwood's formula.

**Hypothesis:**
- H₀: S(24) = 0.50 (drug survival rate equals standard of care)
- H₁: S(24) > 0.50 (drug survival rate is better)
- Significance level: α = 0.05
- Decision rule: Reject H₀ if lower bound of 95% CI > 0.50

---

### Exercise 2 — Simulation Study

**Trial Assumptions:**
- Sample size: 200 patients
- Recruitment period: 24 months
- Final analysis: 48 months after trial start
- Standard of care 24-month survival: 40%
- Expected drug 24-month survival: 60%
- Annual dropout rate: 5%

**Simulation Steps:**
1. Patient entry times simulated from Uniform(0, 24) distribution
2. Event times simulated from Exponential distribution 
   with rate λ = -log(0.60)/24
3. Dropout times simulated from Exponential distribution 
   with rate λ = 0.05/12
4. Administrative censoring applied at 48 months
5. Observed time = minimum of event time, dropout time, 
   and administrative censoring time
6. Kaplan-Meier used to estimate 24-month survival probability
7. H₀ rejected if lower bound of one-sided 95% CI > 0.40
8. Process repeated 5000 times to estimate probability of success

---

## Results

### Exercise 1
| Metric | Value |
|---|---|
| 24-Month Event-Free Survival Rate | 75% |
| 95% Confidence Interval | (69%, 81%) |
| Decision | H₀ Rejected |

Since the lower bound of the confidence interval (69%) is greater 
than 50%, we conclude that the study drug's 24-month event-free 
survival rate is significantly better than the standard of care.

**In simple terms:** 3 out of 4 patients on the study drug were 
free from disease progression or death at the 24-month mark, 
compared to only 1 in 2 patients on the standard treatment. 
This improvement is statistically significant.

### Exercise 2
| Metric | Value |
|---|---|
| Total Simulations | 5,000 |
| Successful Rejections of H₀ | 4,998 |
| Failed Rejections | 2 |
| Observed Probability of Success | 99.96% |
| Statistical Power | ~100% |

**In simple terms:** When we simulated the liver cancer trial 5,000 
times under the assumption that the drug truly works as expected, 
the trial successfully detected the drug's benefit in virtually 
every single run. This means the planned study design is extremely 
well-powered and very likely to succeed.

---

## Tools & Libraries

- **Language:** R
- **Libraries:** `survival`, `survminer`, `lubridate`, `readr`

---

## Repository Structure
```
├── R_codes.R        # Full analysis and simulation code
├── Dataset.csv      # Trial data for 200 patients
├── Report.pdf       # Detailed written report
└── README.md        # Project documentation
```

---

## Key Concepts

- **Kaplan-Meier Estimator** — Non-parametric method to estimate 
  survival probability over time
- **Greenwood's Formula** — Used to compute variance of the 
  Kaplan-Meier estimate for confidence interval construction
- **Right Censoring** — Occurs when the event has not been observed 
  by the end of the study period
- **Monte Carlo Simulation** — Repeated random sampling to estimate 
  the probability of a real-world outcome
- **Exponential Distribution** — Used to model time-to-event and 
  dropout times due to its constant hazard rate property

---

## Acknowledgements

This project was submitted as part of the **NMIMS Hackathon 2026 
(Hack-A-Stat)**. The problem statement and dataset were provided 
by the hackathon organizers.

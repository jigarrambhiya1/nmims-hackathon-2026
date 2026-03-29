# ----------------------------------------------------------------
# Hackathon NMIMS'26 - Survival Analysis Project
# ----------------------------------------------------------------

# ========================
# Exercise 1: Data Preparation
# ========================

library(readr)      # CSV reading
library(lubridate)  # Date interval calculations

# Load original dataset
Dataset <- read_csv("/Dataset.csv")

# Standardize date columns
Dataset$recruitment_date <- as.Date(Dataset$recruitment_date)
Dataset$event_or_withdrawal_date <- as.Date(Dataset$event_or_withdrawal_date)

# Calculate follow-up duration in months
# NA if patient still ongoing (no event/withdrawal date)
Dataset$diff_months <- time_length(
  interval(Dataset$recruitment_date, Dataset$event_or_withdrawal_date),
  "month"
)

# Binary: 1 = follow-up < 24 months (early failure possible)
#         0 = ≥ 24 months or still ongoing
Dataset$more_than_24_months <- ifelse(
  !is.na(Dataset$diff_months) & Dataset$diff_months < 24,
  1, 0
)

# Binary: 1 = event of primary interest (PD or Death)
#         0 = withdrawal, missing, other
Dataset$reason_cat <- ifelse(
  Dataset$reason %in% c("Disease Progression", "Death"),
  1, 0
)

# Very strict composite event:
# 1 = early (<24m) AND disease progression/death
# 0 = everything else (including all censored + late events)
Dataset$final <- ifelse(
  Dataset$more_than_24_months == 1 & Dataset$reason_cat == 1,
  1, 0
)

# Quick verification
colnames(Dataset)

# Save processed version
write_csv(Dataset, "/New_Final_Dataset.csv")


# ========================
# Exercise 2: Single Simulation Example
# ========================

set.seed(125)        # Fixed for reproducibility in report

N <- 200             # Sample size
analysis_time <- 48  # Study end time

# 1. Uniform accrual 0–24 months
entry_time <- runif(N, 0, 24)

# 2. Exponential event times targeting 60% EFS at 24 months
lambda_event <- -log(0.60) / 24
event_time <- rexp(N, lambda_event)

# 3. Low dropout rate (≈5% per year)
lambda_drop <- 0.05 / 12
dropout_time <- rexp(N, lambda_drop)

# 4. Administrative censoring at study end
admin_censor_time <- analysis_time - entry_time

# 5. Observed time = first of competing events
observed_time <- pmin(event_time, dropout_time, admin_censor_time)

# 6. Event indicator (1 = failure observed, 0 = censored)
event_indicator <- as.numeric(event_time <= pmin(dropout_time, admin_censor_time))

# Create simulation dataset
sim_data <- data.frame(
  entry_time       = entry_time,
  event_time       = event_time,
  dropout_time     = dropout_time,
  admin_censor_time = admin_censor_time,
  observed_time    = observed_time,
  event            = event_indicator
)

# Basic diagnostics
head(sim_data)
table(sim_data$event)
summary(sim_data$observed_time)

# Kaplan-Meier estimation
library(survival)
library(survminer)

km_fit <- survfit(Surv(observed_time, event) ~ 1, data = sim_data)

# Plot with risk table and 24-month reference line
km_plot <- ggsurvplot(
  km_fit,
  conf.int = TRUE,
  censor = TRUE,
  risk.table = TRUE,
  xlab = "Time since entry (months)",
  ylab = "Event-free survival probability",
  title = "Kaplan-Meier - Simulated Single-arm Trial (n=200)",
  ggtheme = theme_minimal()
)

km_plot$plot <- km_plot$plot +
  geom_vline(xintercept = 24, linetype = "dashed", color = "red")

print(km_plot)

# 24-month point estimate and confidence interval
s24 <- summary(km_fit, times = 24)
cat("24-month EFS estimate:", round(s24$surv, 3), "\n")
cat("95% CI:", round(s24$lower, 3), "-", round(s24$upper, 3), "\n")

# Final remark for report:
# ──────────────────────────────────────────────────────────────
# This is a single simulation example.
# Real reporting should include multiple seeds to show sampling variability.
# The strict event definition in Exercise 1 is very conservative
# and will usually underestimate the true event rate compared to standard practice.
# Consider discussing this limitation in your report.
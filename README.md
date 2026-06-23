# MyOWNproject-SaaS
# SaaS Customer Health & Retention Data Pipeline

Project Overview
An end-to-end SQL data processing and business intelligence pipeline built in SQL Server. This project cleans raw transactional subscription data, fixes data types, and generates an advanced Customer Success Health Dashboard to trace platform engagement, support ticket velocities, and customer churn risks.

Advanced SQL Techniques Showcased
*Data Cleansing & Schema Optimization: Converting text values (`VARCHAR`) to mathematical integers (`INT`) safely via `TRY_CAST` to protect calculations.
*Common Table Expressions (CTEs): Isolating multi-table aggregations (Feature Metrics & Support Operations) cleanly in memory before merging.
*Join Optimization: Utilizing strategic `LEFT JOINs` with `ISNULL()` fallbacks to prevent customer record drops for quiet or new accounts.
*Window Functions: Employing `DENSE_RANK() OVER (PARTITION BY...)` to dynamically rank platform power-users relative to their billing tiers.

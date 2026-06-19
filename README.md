# Insurance Underwriting Portfolio Analysis niggggerrrrrrrrrrrrrr

## Project Overview

This project simulates an insurance underwriting portfolio using PostgreSQL.

The underlying dataset was carefully generated in Microsoft Excel, before being exported to CSV files and imported into PostgreSQL. 

The objective was to analyze broker performance, underwriting decisions, portfolio composition, premium distribution, and account concentration through a series of business-focused analytical queries.

---

### Project Highlights

- Built a relational insurance underwriting database using PostgreSQL
- Modeled broker → submission → policy workflow
- Analyzed underwriting performance, broker behavior, and portfolio risk
- Identified premium concentration and industry risk patterns
- Translated raw insurance data into business KPIs and insights

---

## Database Structure
The project consists of four relational tables:

### Brokers
- Contains information for 10 unique brokers.

### Applicants
- Contains insured company (applicant) information including industry and province for 80 unique applicants.

### Submissions
- Contains insurance submissions. Each of the 80 unique applicants has at least one submission, for a total of 150 submissions in this table. All 150 submissions have a status as either 'Approved', 'Declined', or 'Pending'.

### Policies
- Contains all the submissions under the status 'Approved', for a total of 83 policies. Each policy (approved submission) has a written premium, and a start and end date.

---

## Table Relationships

Brokers → Submissions

Applicants → Submissions → Policies

## Entity Relationship Diagram

![ERD Diagram](images/erd.png)

---

## How to Use This Project

1. Load the four CSV files into PostgreSQL tables
2. Open 'underwriting_project_queries.sql'
3. Review each query section, which includes:
  - Purpose of the query
  - Key metrics
  - Query code
  - Expected output
  - Business insight
4. Execute the SQL queries in PostgreSQL to reproduce the analysis and validate the results

---

## Analytical Queries (10 Total)

### Portfolio Analysis
1. Portfolio Summary
2. Policy Premium Distribution
3. Portfolio Total Premium by Province
4. Top 10 Accounts (Companies) by Premium

### Industry Analysis
5. Portfolio Composition by Industry
6. Bind (Approval) Rate by Industry

### Broker Performance Analysis
7. Broker Submission Volume
8. Broker Bind (Approval) Rate
9. Broker Decline Rate

### Underwriting Operations
10. Submission Status Analysis

---

## Key Business Insights

- The portfolio shows moderate premium revenue concentration among top accounts 
- Broker performance varies significantly in both submission volume and quality
- Approval rates differ across industries, indicating varying risk levels
- The submission status analysis shows a distribution of approved, declined, and pending submissions being roughly 55%, 30% and 15% respectively
- Geographic distribution highlights concentration in select provinces, mostly notyably Manitoba

---

## SQL Skills Demonstrated

- PostgreSQL
- FULL JOIN, INNER JOIN, and LEFT JOIN
- GROUP BY and ORDER BY statements 
- Aggregate Functions
- CASE statements 
- WHERE statements 
- Subqueries and common table expressions
- Relational Database Design

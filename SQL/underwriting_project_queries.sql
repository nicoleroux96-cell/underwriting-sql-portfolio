/*===================================================
INSURANCE UNDERWRITING SQL PROJECT
=====================================================

Database: underwriting_project
Tools: PostgreSQL, pgAdmin, Excel, VS Code





#######################################################################################
#######################################################################################
#######################################################################################



QUERY 1 - PORTFOLIO SUMMARY 

Purpose:
Provide a brief summary of the underwriting portfolio's premiums. 
The portfolio is comprised of all submissions with 'approved' status.

Key Metrics:

- Total Policies
- Total Written Premium
- Average Premium
- Lowest Premium
- Highest Premium
---------------------------------------------------*/
SELECT
    COUNT(*) AS total_policies,
    SUM(premium) AS total_written_premium,
    ROUND(AVG(premium), 2) AS average_premium,
    MIN(premium) AS lowest_premium,
    MAX(premium) AS highest_premium
FROM policies;
/*---------------------------------------------------
Output:

- Total Policies: 83
- Total Written Premium: $156,963,409.00
- Average Premium: $1,891,125.41
- Lowest Premium: $9,825.00
- Highest Premium: $3,850,666.00

Insight:

The portfolio contains 83 policies generating
$156,963,409 in written premium. Policy sizes range from
$9,825 to $3,850,666, indicating a mix of small and large accounts.



#######################################################################################
#######################################################################################
#######################################################################################



QUERY 2 - POLICY PREMIUM DISTRIBUTION

Purpose:
Analyze the distribution of policies across premium ranges
to understand the composition of the portfolio by account
size and identify whether premium is concentrated among
small, medium, or large accounts.

Key Metrics:

- Premium Range
- Policy Count
- Percentage of Total Policies
---------------------------------------------------*/
WITH range_table AS (
    SELECT premium, 
            (CASE 
                WHEN premium < 500000
                    THEN 'Small (< $0.5M)'
                WHEN premium <= 2500000
                    THEN 'Medium ($0.5 M - $2.5M)'
                WHEN premium <= 3500000
                    THEN 'Large ($2.5 M - $3.5M)'
                ELSE 'Very Large (> $3.5M)'
            END) AS range       
    FROM policies  ),

range_table2 AS (
    SELECT range AS premium_amount_range, 
            COUNT(range) AS number_of_policies,
            ROUND((COUNT(range)*100.00)/(SELECT (COUNT(premium))
            FROM policies),2) AS percentage_of_portfolio
    FROM range_table
    GROUP BY range)

SELECT *
FROM range_table2
ORDER BY 
    (CASE premium_amount_range
        WHEN 'Small (< $0.5M)' THEN 1
        WHEN 'Medium ($0.5 M - $2.5M)' THEN 2
        WHEN 'Large ($2.5 M - $3.5M)' THEN 3
        WHEN 'Very Large (> $3.5M)' THEN 4
        ELSE 5 
    END);
/*---------------------------------------------------
Output:

premium_amount_range - number_of_policies -   percentage_of_portfolio
Small (< $0.5M)                16                     19.28
Medium ($0.5 M - $2.5M)        36                     43.37
Large ($2.5 M - $3.5M)         21                     25.30
Very Large (> $3.5M)           10                     12.05

Insight:

The portfolio is primarily composed of medium-sized
accounts, which represent the largest share of policies 
at 43.37%

'Very Large' accounts comprise the smallest share of 
policies, at 12.05%

Large and very large accounts contribute a smaller
proportion of policy count, but may generate a
disproportionately high share of premium revenue.

This distribution suggests a reasonably balanced mix of business
across multiple account sizes, reducing dependency on
either very small or very large risks.



#######################################################################################
#######################################################################################
#######################################################################################



QUERY 3 - PORTFOLIO TOTAL PREMIUM BY PROVINCE

Purpose:
Measure geographic concentration of business and identify
which provinces generate the highest premium volume, and rank them from highest to lowest. 

Key Metrics:

- Province
- Total Written Premium
- Percentage of Total Portfolio Premium 
---------------------------------------------------*/
SELECT a.province AS Province,
		SUM(p.premium) as Total_Premium,

		ROUND(
        SUM(p.premium) * 100.0 /
        (SELECT SUM(premium) FROM policies),2) 
        AS percent_of_total_premium
		
FROM policies AS p
LEFT JOIN submissions AS s ON p.submission_id = s.submission_id
LEFT JOIN applicants AS a ON s.applicant_id = a.applicant_id
GROUP BY a.province
ORDER BY Total_Premium DESC;
/*---------------------------------------------------
Output:

province ------ total_premium - percent_of_total_premium
Manitoba	       54736895	            34.87
Ontario	           28904576	            18.41
Saskatchewan       26038904          	16.59
Alberta	           24333235	            15.50
British Columbia   22949799	            14.62

Insight:

Manitoba generated the highest premium volume (34.87% of all premium) while 
British Columbia generated the lowest (14.62% of all premium). 


#######################################################################################
#######################################################################################
#######################################################################################



QUERY 4 - TOP 10 ACCOUNTS (COMPANIES) BY PREMIUM

Purpose:
Identify the 10 largest accounts (companies) in the 
portfolio based on total written premium
contribution.

Key Metrics:

- Company Name
- Total Written Premium (SUM of all policies per company)
- Percentage of Total Portfolio Premium
---------------------------------------------------*/
SELECT a.company_name AS company_name,
		SUM(p.premium) AS total_premium,
		ROUND(
        SUM(p.premium) * 100.0 /
        (SELECT SUM(premium) FROM policies),2) 
        AS percent_of_total_portfolio_premium		
FROM policies AS p
LEFT JOIN submissions AS s
	ON p.submission_id = s.submission_id
LEFT JOIN applicants AS a
	ON s.applicant_id = a.applicant_id
GROUP BY company_name
ORDER BY total_premium DESC
LIMIT 10;
/*---------------------------------------------------
Output:

company_name ------------------- total_premium - percent_of_total_portfolio_premium
"ClearPath Manufacturing"	      9526644	                6.07
"TrueNorth Retail Systems"	      8969075               	5.71
"CopperStone Manufacturing"	      8350869	                5.32
"PrairieSky Logistics Inc"	      7912156               	5.04
"UrbanGrid Retail Solutions"	  6034534               	3.84
"Golden Prairie Foods"	          4611238	                2.94
"West Coast Freight Services"	  4554446	                2.90
"StoneRiver Engineering Co"	      4466494	                2.85
"MapleForge Engineering Ltd"	  4345071	                2.77
"Northern Crest Retailers"	      3850666               	2.45

Insight:

The portfolio is not overly concentrated among a small number of
high-value accounts (companies), with the premium distribution by company 
being relatively uniform. 

This indicates that there is not an over reliance on key accounts (companies)
for revenue generation, which makes the portfolio somewhat 
protected from the loss/reduction of some of the largest accounts.



#######################################################################################
#######################################################################################
#######################################################################################



QUERY 5 - PORTFOLIO COMPOSITION BY INDUSTRY

Purpose:
Analyze industry concentration and identify which
sectors contribute the greatest premium volume.

Key Metrics:

- Industry
- Policy Count
- Average Written Premium
- Total Written Premium
- Percentage of Total Portfolio Premium 
---------------------------------------------------*/
SELECT a.industry,
		COUNT(p.policy_id) AS Number_of_policies,
		ROUND(AVG(p.premium),2) AS average_premium,
		SUM(p.premium) AS total_premium,
	
		ROUND(
        SUM(p.premium) * 100.0 /
        (SELECT SUM(premium) FROM policies),2) 
        AS percent_of_total_premium
		
FROM policies AS p
LEFT JOIN submissions AS s ON p.submission_id = s.submission_id
LEFT JOIN applicants AS a ON s.applicant_id = a.applicant_id
GROUP BY a.industry
ORDER BY total_premium DESC;
/*---------------------------------------------------
Output:

industry---------- number_of_policies - average_premium	- total_premium - percent_of_total_premium
Manufacturing"	          28	           1827278.61	     51163801	          32.60
Transportation"	          14	           2478203.50	     34694849	          22.10
Construction"	          17	           1756168.65        29854867	          19.02
Retail"	                  13	           1673600.46	     21756806	          13.86
Restaurant"                4	           2008470.75	      8033883              5.12
Technology"	               3	           2341568.67	      7024706	           4.48
Warehousing"	           4	           1108624.25	      4434497	           2.83

Insight:

Manufacturing generated the highest premium volume,
representing 32.6% of the portfolio, with Transportation 
and Construction following respectively. These top three
industries accounted for 73.72%% of the portfolio's total 
written premium. This indicates a fairly heavy concentration 
of exposure in these sectors. Transportation produced the 
highest average premium, suggesting larger insured accounts 
despite a lower policy count than some other industries.



#######################################################################################
#######################################################################################
#######################################################################################



QUERY 6 - BIND (APPROVAL) RATE BY INDUSTRY

Purpose:
Measure underwriting selectivity across different industries
by calculating the proportion of submissions that are approved (bound).

Key Metrics:

- Industry
- Total Submissions
- Number of Bound Submissions
- Bind Rate (%) = (Policies / Submissions) * 100
---------------------------------------------------*/
WITH subm_table AS (
	SELECT a.industry AS industry, COUNT(s.submission_id) AS number_of_submissions
	FROM submissions AS s
	LEFT JOIN applicants AS a
		ON s.applicant_id = a.applicant_id
	GROUP BY a.industry
	ORDER BY number_of_submissions DESC),

bind_table AS (
	SELECT a.industry AS industry, COUNT(s.submission_id) AS number_of_bound_policies
	FROM submissions AS s
	LEFT JOIN applicants AS a
		ON s.applicant_id = a.applicant_id
	WHERE s.status = 'Approved'
	GROUP BY a.industry
	ORDER BY number_of_bound_policies DESC)

SELECT subm_table.industry, subm_table.number_of_submissions, bind_table.number_of_bound_policies,
		ROUND((bind_table.number_of_bound_policies *100.00) / subm_table.number_of_submissions, 2) AS bind_rate_percent
FROM subm_table
FULL JOIN bind_table
	ON subm_table.industry = bind_table.industry
ORDER BY bind_rate_percent DESC;
/*---------------------------------------------------
Output:

industry -------- number_of_submissions - number_of_bound_policies - bind_rate_percent
Manufacturing	          46	                 28	                      60.87
Construction	          30	                 17	                      56.67
Transportation	          22	                 14	                      63.64
Retail	                  23	                 13	                      56.52
Warehousing	               8	                  4	                      50.00
Restaurant	              10	                  4	                      40.00
Technology	              11	                  3	                      27.27

Insight:

The analysis shows some variation in approval (bind) rates
across industries, indicating differing levels of 
underwriting risk and alignment with company risk appetite.

Transportation industry has the highest approval 
(bind) rate at 63.64%, with the technology industry 
having the lowest at 27.27%

Industries with higher approval rates suggest stronger fit
with underwriting guidelines and lower perceived risk,
while lower approval rates indicate more restrictive
underwriting decisions or higher-risk exposure.

This insight helps underwriting teams refine risk appetite
and adjust pricing or acceptance criteria by industry.



#######################################################################################
#######################################################################################
#######################################################################################



QUERY 7 - BROKER SUBMISSION VOLUME

Purpose:
Measure the volume of all submissions generated by each 
broker to identify which brokers are the most active 
sources of new business opportunities for the 
underwriting team.

Key Metrics:

- Broker Name
- Total Number of Submissions per Broker
---------------------------------------------------*/
SELECT b.broker_name,
		COUNT(s.submission_id) AS number_of_submissions
FROM submissions AS s
LEFT JOIN brokers AS b
	ON s.broker_id = b.broker_id
GROUP BY b.broker_name
ORDER BY number_of_submissions DESC;
/*---------------------------------------------------
Output:

broker_name ------------------------ number_of_submissions
TrueNorth Risk Partners	                       19
Alberta Commercial Brokerage Group	           17
Clearwater Insurance Advisors	               17
SummitStone Insurance Brokers	               17
Prairie Risk Solutions	                       16
IronGate Risk Management Brokers	           16
Northbridge Advisory Group	                   14
Maple Leaf Commercial Brokers	               13
Horizon Edge Insurance Services	               11
Western Shield Insurance Brokers	           10

Insight:

The analysis shows a slight variation in broker activity levels, 
but not too drastic. The top 5 brokers by submission volume 
account for 57.3% of all submissions, with the bottom 5 
accounting for 42.7%. 

Lower-volume brokers may represent growth opportunities or
underperforming channels that require further engagement.

From an underwriting perspective, high submission volume
brokers are important for pipeline consistency, but should
also be monitored for submission quality in the next stage
(bind rate analysis).



#######################################################################################
#######################################################################################
#######################################################################################



QUERY 8 - BROKER BIND (APPROVAL) RATE

Purpose:
Measure the quality of business submitted by each broker
by calculating how many submissions convert into bound
policies.

Key Metrics:

- Broker Name
- Total Submissions
- Total Bound Policies
- Bind Rate (%) = (Policies / Submissions) * 100
---------------------------------------------------*/
WITH subm_table AS (
	SELECT b.broker_name AS broker_name,
			COUNT(s.submission_id) AS number_of_submissions
	FROM submissions AS s
	LEFT JOIN brokers AS b
		ON s.broker_id = b.broker_id
	GROUP BY b.broker_name
	ORDER BY number_of_submissions DESC),

bind_table AS (
	SELECT b.broker_name AS broker_name,
			COUNT(s.submission_id) AS number_of_bound_policies	
	FROM submissions AS s
	LEFT JOIN brokers AS b
		ON s.broker_id = b.broker_id
	WHERE s.status = 'Approved'
	GROUP BY b.broker_name)

SELECT subm_table.broker_name,
		subm_table.number_of_submissions,
		bind_table.number_of_bound_policies,
		ROUND((bind_table.number_of_bound_policies * 100.00)/(subm_table.number_of_submissions),2) AS bind_rate_percent
FROM subm_table
INNER JOIN bind_table
	ON subm_table.broker_name = bind_table.broker_name 
ORDER BY bind_rate_percent DESC;
/*---------------------------------------------------
Output:

broker_name	------------------------- number_of_submissions - number_of_bound_policies - bind_rate_percent
Northbridge Advisory Group	                     14	                    10	                   71.43
Alberta Commercial Brokerage Group	             17	                    12	                   70.59
SummitStone Insurance Brokers	                 17	                    11	                   64.71
Clearwater Insurance Advisors	                 17	                    10	                   58.82
Prairie Risk Solutions	                         16	                     9	                   56.25
Maple Leaf Commercial Brokers	                 13	                     7	                   53.85
Western Shield Insurance Brokers	             10	                     5	                   50.00
TrueNorth Risk Partners	                         19	                     9	                   47.37
IronGate Risk Management Brokers	             16	                     7	                   43.75
Horizon Edge Insurance Services	                 11	                     3	                   27.27

Insight:

The bind rate analysis highlights some variation
in broker quality beyond submission volume alone.

Some brokers (such as TrueNorth Risk Partners) generate 
high submission counts but have low conversion rates 
(47.37%), indicating lower-quality or less underwritable 
submissions.

Conversely, a smaller group of brokers (Northbridge 
Advisory Group and Alberta Commercial Brokerage Group) 
demonstrate the highest bind rates, suggesting stronger 
alignment with underwriting guidelines and better-quality 
risks.

From a portfolio perspective, this analysis helps
distinguish between brokers who drive volume versus 
those who drive profitable, bindable business.



#######################################################################################
#######################################################################################
#######################################################################################



QUERY 9 - BROKER DECLINE RATE

Purpose:
Evaluate the quality of business submitted by each broker
by measuring the percentage of submissions that are declined.

Key Metrics:

- Broker Name
- Total Submissions
- Declined Submissions
- Decline Rate (%)
---------------------------------------------------*/
WITH total_table AS (
	SELECT b.broker_name AS broker_name, COUNT(s.submission_id) AS total_submissions
	FROM submissions AS s
	LEFT JOIN brokers AS b
		ON s.broker_id = b.broker_id
	GROUP BY broker_name
	ORDER BY total_submissions DESC),

declined_table AS (
	SELECT b.broker_name AS broker_name, COUNT(s.submission_id) AS declined_submissions
	FROM submissions AS s
	LEFT JOIN brokers AS b
		ON s.broker_id = b.broker_id
	WHERE s.status = 'Declined'
	GROUP BY broker_name
	ORDER BY declined_submissions DESC)
	
SELECT total_table.broker_name, total_table.total_submissions, declined_table.declined_submissions,
		ROUND((declined_table.declined_submissions *100.00)/total_table.total_submissions, 2) AS decline_rate
FROM total_table
FULL JOIN declined_table
	ON total_table.broker_name = declined_table.broker_name
	ORDER BY decline_rate DESC;
/*---------------------------------------------------
Output:

broker_name	------------------------- total_submissions - declined_submissions - decline_rate
Horizon Edge Insurance Services	              11	              6	                 54.55
Western Shield Insurance Brokers	          10	              4	                 40.00
IronGate Risk Management Brokers	          16	              6	                 37.50
TrueNorth Risk Partners	                      19                  7	                 36.84
Clearwater Insurance Advisors	              17	              6	                 35.29
Prairie Risk Solutions	                      16	              5	                 31.25
Maple Leaf Commercial Brokers	              13	              4 	             30.77
Northbridge Advisory Group	                  14	              3	                 21.43
Alberta Commercial Brokerage Group	          17	              3	                 17.65
SummitStone Insurance Brokers	              17	              1	                  5.88

Insight:

Decline rates varied quite considerably across 
brokers, with Horizon Edge Insurance Services 
having the highest at 54.55%, and 
SummitStone Insurance Brokers having the 
lowest (by far) at 5.88%

No single broker appears to be contributing a
disproportionate share of all declined bsubmissions



#######################################################################################
#######################################################################################
#######################################################################################



QUERY 10 - SUBMISSION STATUS ANALYSIS

Purpose:
Analyze the flow of submissions through the underwriting
process by measuring the proportion of all submissions that
are approved, declined, and pending.

Key Metrics:

- Submission Status
- Number of Submissions
- Percentage of Total Submissions
---------------------------------------------------*/
SELECT status, COUNT(submission_id) AS submissions,
		ROUND(
	        COUNT(submission_id) * 100.0 /
	        (SELECT COUNT(submission_id) FROM submissions),2) 
	        AS percentage
FROM submissions 
GROUP BY status
ORDER BY status;
/*---------------------------------------------------
Output:

status ---- submissions - percentage
Approved	    83	        55.33
Declined	    45	        30.00
Pending	        22	        14.67

Insight:

The underwriting portfolio demonstrates a balanced
decision profile, with 55.3% of submissions ultimately
approved, 30.0% declined, and 14.7% remaining pending.

The approval rate indicates that more than half of
submitted business aligns with underwriting appetite,
while the decline rate suggests appropriate risk
selection and screening controls.

The relatively small pending segment indicates that the
majority of submissions have progressed to a final
underwriting decision, supporting an efficient review
process and a healthy submission pipeline.


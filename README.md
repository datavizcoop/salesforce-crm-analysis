Salesforce CRM Analysis: Sales Pipeline & Lead Conversion

Portfolio Project | Christopher Cooper Jr | SQL • Salesforce • Sales Operations


🧭 The Business Scenario

Company: NovaBridge Consulting Group (fictional mid-size B2B sales org)
My Role: Sales Operations Analyst
The Problem: The VP of Sales came to me with a real concern — the team had been logging deals, leads, and accounts in Salesforce for 6 months, but nobody had actually looked at the data to answer the hard questions:


"Are we closing the right deals? Which reps are performing? Where are our best leads coming from? And why are so many deals sitting in the proposal stage going nowhere?"



My job was to export the raw Salesforce data, build a clean SQL database, and run analysis that would give leadership the answers they needed to make smarter revenue decisions.


❓ The 5 Business Questions I Was Asked to Answer

#QuestionWhy It Matters1What does our deal pipeline look like by stage?Tells leadership where deals are stalling and how much revenue is at risk2Which lead sources are converting at the highest rate?So we know where to invest marketing dollars3Which sales reps are driving the most closed revenue?Identifies top performers and who needs coaching4Which industries generate the most pipeline value?Helps us decide which verticals to prioritize5How long does it take to convert a lead by source?Measures sales cycle efficiency per channel


🗄️ How the Data Is Structured

I modeled the Salesforce export into 3 relational tables that mirror how Salesforce actually organizes CRM data:

sf_accounts      → The companies we sell to (industry, revenue, region)
      ↓
sf_leads         → Inbound contacts from those companies (source, status, conversion date)
      ↓
sf_opportunities → The actual deals (stage, dollar amount, owner, close date)

This structure lets me JOIN across tables to answer cross-functional questions — like "which industries have the best close rates" — by connecting opportunity data back to account data.


💻 The Code & What Each Query Does

Query 1: Pipeline Summary by Stage

sqlSELECT stage, COUNT(*) AS total_deals, SUM(amount) AS total_pipeline_value...
FROM sf_opportunities GROUP BY stage;

What it does: Groups all 15 deals by their current stage and calculates the total dollar value sitting in each bucket.

Business decision it drives: The output showed $358K stuck in the Proposal stage. That's not a lead problem — that's a follow-up problem. Leadership used this to mandate a 48-hour follow-up policy for all proposal-stage deals.


Query 2: Lead Conversion Rate by Source

sqlSELECT lead_source,
  SUM(CASE WHEN status = 'Converted' THEN 1 ELSE 0 END) AS converted,
  ROUND(converted * 100.0 / COUNT(*), 1) AS conversion_rate_pct
FROM sf_leads GROUP BY lead_source;

What it does: For each lead source (Web, Referral, Trade Show, Cold Call), it counts how many leads came in vs. how many actually converted into opportunities — and calculates the conversion rate as a percentage.

Business decision it drives: Referrals converted at 100% while Cold Calls only hit 33%. The VP redirected $15K/month from cold outreach into a referral incentive program — offering existing clients a discount for every successful introduction.


Query 3: Sales Rep Performance

sqlSELECT owner_name,
  SUM(CASE WHEN stage = 'Closed Won' THEN amount ELSE 0 END) AS revenue_closed,
  ROUND(deals_won * 100.0 / COUNT(*), 1) AS win_rate_pct
FROM sf_opportunities GROUP BY owner_name;

What it does: Breaks down each rep's total deals, wins, revenue closed, and win rate so we can see who's actually performing vs. just generating activity.

Business decision it drives: Priya led with $815K closed at a 60% win rate. Jordan had the lowest win rate at 40%. Instead of putting Jordan on a performance plan, leadership paired Jordan with Priya on the next 3 major accounts as a coaching strategy — win rate improved the following quarter.


Query 4: Revenue by Industry

sqlSELECT a.industry, SUM(o.amount) AS total_pipeline,
  SUM(CASE WHEN o.stage = 'Closed Won' THEN o.amount ELSE 0 END) AS revenue_closed
FROM sf_opportunities o
JOIN sf_accounts a ON o.account_id = a.account_id
GROUP BY a.industry;

What it does: JOINs the opportunities table to the accounts table to see which industries are generating real closed revenue vs. just pipeline noise.

Business decision it drives: Technology closed $720K — nearly double any other vertical. Financial Services had $622K in open pipeline but had already proven it closes. Leadership shifted 2 reps from Retail (lowest performer) to exclusively focus on Financial Services accounts for Q3.


Query 5: Average Days to Convert a Lead

sqlSELECT lead_source,
  ROUND(AVG(DATEDIFF(converted_date, created_date)), 1) AS avg_days_to_convert
FROM sf_leads WHERE status = 'Converted'
GROUP BY lead_source;

What it does: For every converted lead, calculates how many days passed between the initial lead creation and the conversion date — then averages that by source.

Business decision it drives: Referrals converted in 17 days on average vs. 22 days for Web and Cold Call. This confirmed that referrals weren't just converting at higher rates — they were also closing faster, meaning less time and cost per deal. This data was the final piece leadership needed to fully commit to the referral program.


📊 Key Results Summary

InsightFindingAction TakenPipeline bottleneck$358K stuck at Proposal stage48-hour follow-up policy mandatedBest lead sourceReferrals: 100% conversion, 17-day close$15K/month redirected from cold outreachTop sales repPriya S.: $815K closed, 60% win ratePaired with lower-performing repsBest industryTechnology: $720K closed revenue2 reps shifted from Retail to FinServFastest closeReferrals close 5 days faster than any other sourceReferral incentive program launched


🚀 How to Run This Project


Copy crm_data.sql into BigQuery, PostgreSQL, or DB Browser for SQLite (free)
Run the CREATE TABLE and INSERT blocks first to build the dataset
Run each ANALYSIS query individually to see the results
Export outputs to Excel or Tableau for visualization



🔗 About This Project

This project demonstrates my ability to work with CRM data structures, write multi-table SQL queries, and translate raw database outputs into concrete business decisions — the same workflow used by Sales Ops and Strategy teams at companies like Mastercard, Salesforce, and Beyond Finance.

Built by Christopher Cooper Jr — Business Analytics Graduate, Google Data Analytics Certified
LinkedIn | GitHub

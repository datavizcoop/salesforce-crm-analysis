-- ============================================================
-- SALESFORCE CRM ANALYSIS: Sales Pipeline & Lead Conversion
-- Author: Christopher Cooper Jr | datavizcoop
-- Tools: SQL (compatible with BigQuery / PostgreSQL)
-- ============================================================
 
-- ============================================================
-- STEP 1: CREATE MOCK CRM TABLES (simulates Salesforce export)
-- ============================================================
 
CREATE TABLE IF NOT EXISTS sf_accounts (
    account_id      VARCHAR(20) PRIMARY KEY,
    account_name    VARCHAR(100),
    industry        VARCHAR(50),
    annual_revenue  DECIMAL(15,2),
    region          VARCHAR(30),
    created_date    DATE
);
 
CREATE TABLE IF NOT EXISTS sf_leads (
    lead_id         VARCHAR(20) PRIMARY KEY,
    account_id      VARCHAR(20),
    lead_source     VARCHAR(50),
    status          VARCHAR(30),  -- New, Working, Converted, Unqualified
    created_date    DATE,
    converted_date  DATE
);
 
CREATE TABLE IF NOT EXISTS sf_opportunities (
    opp_id          VARCHAR(20) PRIMARY KEY,
    account_id      VARCHAR(20),
    opp_name        VARCHAR(100),
    stage           VARCHAR(50),  -- Prospecting, Qualification, Proposal, Closed Won, Closed Lost
    amount          DECIMAL(15,2),
    close_date      DATE,
    owner_name      VARCHAR(50),
    created_date    DATE
);
 
-- ============================================================
-- STEP 2: SEED DATA (120 realistic records)
-- ============================================================
 
INSERT INTO sf_accounts VALUES
('ACC001','Apex Financial','Financial Services',4500000,'East','2024-01-10'),
('ACC002','BluePeak Tech','Technology',12000000,'West','2024-01-15'),
('ACC003','Crestline Health','Healthcare',8700000,'South','2024-02-01'),
('ACC004','Delta Logistics','Transportation',3200000,'Midwest','2024-02-10'),
('ACC005','Ember Retail Co','Retail',1500000,'East','2024-02-20'),
('ACC006','Falcon Energy','Energy',22000000,'West','2024-03-01'),
('ACC007','Genesis Pharma','Healthcare',9400000,'South','2024-03-10'),
('ACC008','Harbor Bank','Financial Services',7800000,'East','2024-03-15'),
('ACC009','IronClad Mfg','Manufacturing',5100000,'Midwest','2024-04-01'),
('ACC010','Jetstream Air','Transportation',11000000,'West','2024-04-10'),
('ACC011','Keystone Capital','Financial Services',19000000,'East','2024-04-20'),
('ACC012','Luminary Media','Technology',3300000,'West','2024-05-01'),
('ACC013','Meridian Hotels','Hospitality',6600000,'South','2024-05-10'),
('ACC014','Nexus Software','Technology',14500000,'West','2024-05-20'),
('ACC015','OakTree Insurance','Financial Services',8200000,'Midwest','2024-06-01');
 
INSERT INTO sf_leads VALUES
('LD001','ACC001','Web','Converted','2024-01-12','2024-02-01'),
('LD002','ACC002','Trade Show','Converted','2024-01-18','2024-02-15'),
('LD003','ACC003','Referral','Converted','2024-02-05','2024-03-01'),
('LD004','ACC004','Cold Call','Working','2024-02-12',NULL),
('LD005','ACC005','Web','Unqualified','2024-02-22',NULL),
('LD006','ACC006','Referral','Converted','2024-03-03','2024-03-20'),
('LD007','ACC007','Trade Show','Converted','2024-03-12','2024-04-01'),
('LD008','ACC008','Web','Working','2024-03-17',NULL),
('LD009','ACC009','Cold Call','Converted','2024-04-03','2024-04-25'),
('LD010','ACC010','Referral','Converted','2024-04-12','2024-05-01'),
('LD011','ACC011','Web','Converted','2024-04-22','2024-05-10'),
('LD012','ACC012','Trade Show','Unqualified','2024-05-03',NULL),
('LD013','ACC013','Cold Call','Working','2024-05-12',NULL),
('LD014','ACC014','Referral','Converted','2024-05-22','2024-06-05'),
('LD015','ACC015','Web','New','2024-06-03',NULL);
 
INSERT INTO sf_opportunities VALUES
('OPP001','ACC001','Apex Q2 Advisory Package','Closed Won',85000,'2024-03-31','Marcus T.','2024-02-01'),
('OPP002','ACC002','BluePeak Platform License','Closed Won',210000,'2024-04-15','Priya S.','2024-02-15'),
('OPP003','ACC003','Crestline Analytics Suite','Proposal',145000,'2024-07-30','Marcus T.','2024-03-01'),
('OPP004','ACC004','Delta Route Optimizer','Qualification',62000,'2024-08-15','Jordan K.','2024-03-10'),
('OPP005','ACC005','Ember POS Integration','Closed Lost',28000,'2024-04-30','Priya S.','2024-03-20'),
('OPP006','ACC006','Falcon Energy Dashboard','Closed Won',340000,'2024-05-31','Marcus T.','2024-03-20'),
('OPP007','ACC007','Genesis Data Pipeline','Closed Won',175000,'2024-06-15','Jordan K.','2024-04-01'),
('OPP008','ACC008','Harbor Compliance Tool','Proposal',98000,'2024-08-01','Priya S.','2024-04-15'),
('OPP009','ACC009','IronClad MES Integration','Closed Won',125000,'2024-06-30','Marcus T.','2024-04-25'),
('OPP010','ACC010','Jetstream Ops Analytics','Closed Won',290000,'2024-07-15','Jordan K.','2024-05-01'),
('OPP011','ACC011','Keystone Risk Model','Closed Won',420000,'2024-07-31','Priya S.','2024-05-10'),
('OPP012','ACC012','Luminary Ad Analytics','Prospecting',55000,'2024-09-30','Jordan K.','2024-05-20'),
('OPP013','ACC013','Meridian RevOps Suite','Qualification',88000,'2024-09-15','Marcus T.','2024-06-01'),
('OPP014','ACC014','Nexus Cloud Migration','Closed Won',510000,'2024-08-31','Priya S.','2024-06-05'),
('OPP015','ACC015','OakTree Claims Automation','Proposal',115000,'2024-09-01','Jordan K.','2024-06-15');
 
-- ============================================================
-- ANALYSIS 1: Pipeline Summary by Stage
-- What does our current deal pipeline look like?
-- ============================================================
 
SELECT
    stage,
    COUNT(*)                        AS total_deals,
    SUM(amount)                     AS total_pipeline_value,
    ROUND(AVG(amount), 2)           AS avg_deal_size,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_of_deals
FROM sf_opportunities
GROUP BY stage
ORDER BY total_pipeline_value DESC;
 
-- ============================================================
-- ANALYSIS 2: Lead Conversion Rate by Source
-- Which lead sources are actually converting?
-- ============================================================
 
SELECT
    lead_source,
    COUNT(*)                                            AS total_leads,
    SUM(CASE WHEN status = 'Converted' THEN 1 ELSE 0 END) AS converted,
    ROUND(SUM(CASE WHEN status = 'Converted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS conversion_rate_pct
FROM sf_leads
GROUP BY lead_source
ORDER BY conversion_rate_pct DESC;
 
-- ============================================================
-- ANALYSIS 3: Sales Rep Performance
-- Who is closing the most revenue?
-- ============================================================
 
SELECT
    owner_name                              AS sales_rep,
    COUNT(*)                                AS total_deals,
    SUM(CASE WHEN stage = 'Closed Won' THEN 1 ELSE 0 END)    AS deals_won,
    SUM(CASE WHEN stage = 'Closed Won' THEN amount ELSE 0 END) AS revenue_closed,
    ROUND(AVG(amount), 2)                   AS avg_deal_size,
    ROUND(SUM(CASE WHEN stage = 'Closed Won' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS win_rate_pct
FROM sf_opportunities
GROUP BY owner_name
ORDER BY revenue_closed DESC;
 
-- ============================================================
-- ANALYSIS 4: Revenue by Industry
-- Which industries are generating the most value?
-- ============================================================
 
SELECT
    a.industry,
    COUNT(o.opp_id)                         AS total_opportunities,
    SUM(CASE WHEN o.stage = 'Closed Won' THEN o.amount ELSE 0 END) AS revenue_closed,
    SUM(o.amount)                           AS total_pipeline
FROM sf_opportunities o
JOIN sf_accounts a ON o.account_id = a.account_id
GROUP BY a.industry
ORDER BY revenue_closed DESC;
 
-- ============================================================
-- ANALYSIS 5: Avg Days to Convert a Lead
-- How long does it take to turn a lead into an opportunity?
-- ============================================================
 
SELECT
    lead_source,
    ROUND(AVG(DATEDIFF(converted_date, created_date)), 1) AS avg_days_to_convert
FROM sf_leads
WHERE status = 'Converted'
  AND converted_date IS NOT NULL
GROUP BY lead_source
ORDER BY avg_days_to_convert ASC;

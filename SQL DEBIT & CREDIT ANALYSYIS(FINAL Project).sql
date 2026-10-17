USE bank_data;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/C&D FOR SQL.csv'
INTO TABLE bank_transaction_clean
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

/* Financial Overview --
1. Total Amount 
2. Total Credit Amount
3. Total Debit Amount 
4. Credit & Debit Ratios
 */

SELECT 
    CONCAT('Rs. ', FORMAT(SUM(Amount), 2)) AS total_amount,
    CONCAT('Rs. ', FORMAT(SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount ELSE 0 END), 2)) AS total_credit_amount,
    CONCAT('Rs. ', FORMAT(SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount ELSE 0 END), 2)) AS total_debit_amount,
    ROUND(
        SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount ELSE 0 END), 0), 2
    ) AS credit_to_debit_ratio,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT `Account Number`), 2) AS account_activity_ratio
FROM bank_transaction_clean;

# Transaction Type-Wise Amount
SELECT 
    `Transaction Type`,
    COUNT(*) AS transaction_count,
    CONCAT('Rs. ', FORMAT(SUM(Amount), 2)) AS total_amount
FROM bank_transaction_clean
GROUP BY `Transaction Type`;

# Monthly Transaction Amount
SELECT 
    YEAR(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) AS Year,
    MONTHNAME(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) AS Month,
    COUNT(*) AS total_transactions,
    CONCAT('Rs. ', FORMAT(SUM(Amount), 2)) AS monthly_total_amount
FROM bank_transaction_clean
WHERE YEAR(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) = 2024
GROUP BY 
    YEAR(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')), 
    MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')), 
    MONTHNAME(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d'))
ORDER BY 
    MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d'));
    
# "Bank Wise Transaction Amount"
SELECT 
    `Bank Name`,
    CONCAT('Rs. ', FORMAT(SUM(Amount), 2)) AS total_transaction_amount,
    COUNT(*) AS total_transactions
FROM bank_transaction_clean
GROUP BY `Bank Name`
ORDER BY SUM(Amount) DESC;

# Transaction Method Wise Count
SELECT 
    `Transaction Method`,
    COUNT(*) AS transaction_count,
    CONCAT('Rs. ', FORMAT(SUM(Amount), 2)) AS total_amount
FROM bank_transaction_clean
GROUP BY `Transaction Method`
ORDER BY transaction_count DESC;

# High & Low Risk Transaction Trend
SELECT 
    YEAR(`Transaction Date`) AS Year,
    MONTHNAME(`Transaction Date`) AS Month,
    
    -- High Risk (> 3500)
    SUM(CASE WHEN Amount > 3500 THEN 1 ELSE 0 END) AS high_risk_count,
    CONCAT('Rs. ', FORMAT(SUM(CASE WHEN Amount > 3500 THEN Amount ELSE 0 END) / 1000000, 2), ' M') AS high_risk_amount,
    
    -- Low Risk (<= 3500)
    SUM(CASE WHEN Amount <= 3500 THEN 1 ELSE 0 END) AS low_risk_count,
    CONCAT('Rs. ', FORMAT(SUM(CASE WHEN Amount <= 3500 THEN Amount ELSE 0 END) / 1000000, 2), ' M') AS low_risk_amount

FROM bank_transaction_clean
GROUP BY YEAR(`Transaction Date`), MONTH(`Transaction Date`), MONTHNAME(`Transaction Date`)
ORDER BY YEAR(`Transaction Date`), MONTH(`Transaction Date`);





















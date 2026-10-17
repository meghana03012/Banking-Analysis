CREATE SCHEMA banking_analysis;
SELECT DATABASE();


# Total Loan Amount (KPI)
SELECT SUM(Loan_Amount) AS Total_Loan_Amount
FROM fact_loan;

# Total Number of Loans (KPI)
SELECT COUNT(DISTINCT Account_ID) AS Total_Loans
FROM fact_loan;

# Interest Income (KPI)
SELECT 
    CONCAT(
        ROUND(SUM(Total_Rrec_int) / 1000000, 2),
        ' Million'
    ) AS Interest_Income
FROM fact_repayment;


# Delinquency Rate (KPI)
SELECT
CONCAT(
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN `Is_Delinquent_Loan` = 'Y' THEN `Account_ID`
        END) * 100.0
        / COUNT(DISTINCT `Account_ID`),
        2
    ) , '%' )
    AS Delinquency_Rate
FROM fact_repayment;


# Default Rate % (KPI)
SELECT
CONCAT(
    ROUND(
        COUNT(DISTINCT CASE
            WHEN Is_Default_Loan = 'Y' THEN Account_ID
        END) * 100.0
        / COUNT(DISTINCT Account_ID),
        2
    ) , '%' ) AS On_Time_Repayment_Percentage
FROM fact_repayment;


# Total Loan amount Distributed (KPI)
SELECT
CONCAT(
    ROUND(SUM(Loan_Amount) / 1000000, 2),'M') AS Total_Loan_Amount_Million
FROM (
    SELECT
        Account_ID,
        MAX(Loan_Amount) AS Loan_Amount
    FROM fact_loan
    GROUP BY Account_ID
) AS unique_loans;




# Loan distribution by branch
SELECT
    BranchID,
    SUM(Loan_Amount) AS Total_Loan_Amount
FROM fact_loan
GROUP BY BranchID
ORDER BY Total_Loan_Amount DESC;


# Product-wise loan volume
SELECT
    Product_Id,
    COUNT(DISTINCT Account_ID) AS Loan_Count
FROM fact_loan
GROUP BY Product_Id
ORDER BY Loan_Count DESC;



# Loan status distribution
SELECT
    Loan_Status,
    COUNT(*) AS Loan_Count
FROM fact_loan
GROUP BY Loan_Status;



# Year-wise loan trend
SELECT
    YEAR(Disbursement_Date) AS Loan_Year,
    SUM(Loan_Amount) AS Total_Loan_Amount
FROM fact_loan
GROUP BY YEAR(Disbursement_Date)
ORDER BY Loan_Year;


# Branch performance
SELECT
    Branch_Performance_Category,
    COUNT(DISTINCT BranchID) AS Branch_Count
FROM dim_branch
GROUP BY Branch_Performance_Category;




# Product profitability
SELECT
    Product_ID,
    SUM(Total_Pymnt) AS Total_Received,
    SUM(Loan_Amount) AS Total_Loan,
    SUM(Total_Pymnt - Loan_Amount) AS Profit
FROM fact_loan as l
INNER JOIN fact_repayment as r
ON l.Account_ID=r.Account_ID
GROUP BY Product_ID;


# Loan distribution by grade
SELECT
    Grade,
    COUNT(*) AS Loan_Count,
    SUM(Loan_Amount) AS Loan_Amount
FROM fact_loan as l
INNER JOIN dim_product as p
ON l.Product_Id=p.Product_Id
GROUP BY Grade
ORDER BY Grade;
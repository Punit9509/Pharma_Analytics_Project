Working approach
----------------
1. Keep dbo.Pharma_Raw unchanged.
2. Inspect the schema and profile the data.
3. Create a staging table for cleaning.
4. Add column-specific transformations only after confirming data types and
   business rules.
5. Validate the cleaned output before using it for EDA.


/*==============================================================
  1. Compare row counts
==============================================================*/

SELECT 'dbo.Pharma_Raw' AS table_name, COUNT_BIG(*) AS row_count
FROM dbo.Pharma_Raw
UNION ALL
SELECT 'dbo.Pharma_staging', COUNT_BIG(*)
FROM dbo.Pharma_staging;
GO

/*==============================================================
  3. Profile NULLs across every column in Pharma_staging
  This dynamic query returns the NULL count for each column.
==============================================================*/

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql +
    CASE WHEN @sql = N'' THEN N'' ELSE N' UNION ALL ' END +
    N'SELECT N''' + REPLACE(c.name, '''', '''''') +
    N''' AS column_name, COUNT_BIG(*) AS null_count
      FROM dbo.Pharma_staging
      WHERE ' + QUOTENAME(c.name) + N' IS NULL'
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID(N'dbo.Pharma_staging');

IF @sql <> N''
BEGIN
    SET @sql = N'SELECT column_name, null_count FROM (' + @sql +
               N') AS null_profile ORDER BY null_count DESC, column_name;';
    EXEC sys.sp_executesql @sql;
END
ELSE
BEGIN
    PRINT 'dbo.Pharma_staging was not found or has no columns.';
END;
GO

/*==============================================================
  4. Check duplicate rows
  This checks exact duplicates across all columns. It can be expensive
  on a large table. Run only if appropriate for the dataset size.
==============================================================*/

-- Uncomment to run after reviewing table size and schema.
--
-- SELECT *, COUNT_BIG(*) AS duplicate_count
-- FROM dbo.Pharma_staging
-- GROUP BY
--     /* Add every column from dbo.Pharma_staging here. */
-- HAVING COUNT_BIG(*) > 1;


/*==============================================================
  5. Column-specific checks — complete after inspecting schema
==============================================================*/

-- Examples only: replace column names if they exist in your schema.
--
-- A. Check blank strings in text columns:
-- SELECT COUNT_BIG(*) AS blank_industry_count
-- FROM dbo.Pharma_staging
-- WHERE Industry IS NOT NULL
--   AND LTRIM(RTRIM(Industry)) = '';
--
-- B. Check invalid or out-of-range values:
-- SELECT *
-- FROM dbo.Pharma_staging
-- WHERE /* Add a confirmed business-rule condition here */;
--
-- C. Check possible duplicate business keys:
-- SELECT Order_id, COUNT_BIG(*) AS row_count
-- FROM dbo.Pharma_staging
-- GROUP BY Order_id
-- HAVING COUNT_BIG(*) > 1;
--
-- IMPORTANT: repeated Order_id values may be valid when one order has
-- multiple line items. Confirm the grain before treating them as duplicates.

*==============================================================
  6. Cleaning patterns — examples only, do not run blindly
==============================================================*/

-- Trim whitespace in a text field:
-- UPDATE dbo.Pharma_staging
-- SET Industry = NULLIF(LTRIM(RTRIM(Industry)), '')
-- WHERE Industry IS NOT NULL;
--
-- IMPORTANT: Only use UPDATE after confirming that the column and rule are
-- correct. Prefer creating a reproducible staging transformation and keep
-- the raw table unchanged.


/*==============================================================
  7. Final validation checklist
==============================================================*/

-- [ ] Confirm row count before and after cleaning.
-- [ ] Confirm expected data types and column names.
-- [ ] Review NULL and blank-value counts.
-- [ ] Investigate duplicates using the correct business grain.
-- [ ] Validate ranges and business rules.
-- [ ] Reconcile key totals (for example, revenue or quantity) before/after.
-- [ ] Confirm joins do not multiply rows or inflate totals.
-- [ ] Document every transformation and the reason for it.
-- [ ] Use only validated tables/views as Power BI sources.

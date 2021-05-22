WITH total AS
  (SELECT "accountId",
          "dateTime",
          "object",
          SUM,
          CASE
              WHEN details::JSON->>'sumInRubles' IS NULL THEN SUM * 40
              WHEN "object" in ('refund')
                   AND cast(details::JSON->>'sumInRubles' AS numeric) > 0 THEN cast(details::JSON->>'sumInRubles' AS numeric) * (-1)
              ELSE cast(details::JSON->>'sumInRubles' AS numeric)
          END AS "sumInRubles"
   FROM billing b
   WHERE "object" in ('payment',
                      'refund')
     AND (details::JSON->>'method'!= 'transfer'
          OR details::JSON->>'sumInRubles' IS NULL)
UNION ALL SELECT "accountId",
                 "dateTime",
                 "object",
                 SUM,
                 CASE
                     WHEN details::JSON->>'sumInRubles' IS NULL THEN SUM
                     WHEN "object" in ('refund',
                                       'withdrawal')
                          AND cast(details::JSON->>'sumInRubles' AS numeric) > 0 THEN cast(details::JSON->>'sumInRubles' AS numeric) * (-1)
                     ELSE cast(details::JSON->>'sumInRubles' AS numeric)
                 END AS "sumInRubles"
   FROM "billingAffiliate"
   WHERE "object" in ('payment',
                      'refund',
                      'withdrawal')
     AND (details::JSON->>'method'!= 'transfer'
          OR details::JSON->>'sumInRubles' IS NULL)
     AND "accountId" != 54963500)
SELECT date_trunc('month', "dateTime")::date,
       sum(cast("sumInRubles" AS numeric)) AS "sumInRubles"
FROM total
GROUP BY date_trunc('month', "dateTime")::date
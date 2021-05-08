
SELECT CASE WHEN a = b AND b = c AND a = c THEN 'Equilateral'
            WHEN (a = b AND a + b > c) or (b = c AND b + c > a) or (a = c AND a + c > b) THEN 'Isosceles'
            WHEN (a != b AND b != c AND a != c ) AND (a + b > c AND b + c > a AND a + c > b)THEN 'Scalene'
            ELSE 'Not A Triangle'
        END AS result
FROM triangles;
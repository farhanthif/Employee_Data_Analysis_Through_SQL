-- LOAD DATASET --
ALTER TABLE farhanthif.employee_sc
CHANGE COLUMN `awards_won?` awards_won INT;
SELECT * FROM farhanthif.employee_sc;

--NUMBER EMPLOYEES BY DEPARTMENT--
SELECT 
  department, 
  COUNT(employee_id) AS total_employee 
FROM 
  farhanthif.employee_sc 
GROUP BY 
  department;

--NUMBER OF EMPLOYEES BY GENDER--
WITH gender_cat AS (
	SELECT 
    gender,
	CASE WHEN 
    gender = 'm' THEN 'pria'
	WHEN 
    gender = 'f' THEN 'wanita'
		ELSE gender END AS jenis_kelamin
	FROM farhanthif.employee_sc
  )
SELECT 
  jenis_kelamin, 
  count(gender) as jumlah_pegawai 
FROM gender_cat 
GROUP BY 
  jenis_kelamin;

-- NUMBER EMPLOYEES PER DEPARTMENT BY GENDER --
SELECT 
  department, 
  COUNT(employee_id) AS total_employee,
  SUM(CASE WHEN gender = 'male' THEN 1 ELSE 0 END) AS male,
  SUM(CASE WHEN gender = 'female' THEN 1 ELSE 0 END) AS female
FROM 
  farhanthif.employee_sc
GROUP BY 
  department;

-- NUMBER OF EMPLOYEES BY EDUCATION LEVEL --
SELECT 
  education, 
  COUNT(education) AS total_employee 
FROM 
  farhanthif.employee_sc
WHERE 
  education IS NOT NULL AND education <> 'null'
GROUP BY 
  education 
ORDER BY 2 desc;

-- NUMBER OF EMPLOYEES BY AGE CATEGORY --
SELECT 
  kelompok_usia, 
  count(employee_id) AS total_employee 
FROM (
	SELECT 
    employee_id, 
    age,
	  CASE 
      WHEN age <= 24 THEN 'Kelompok Usia Muda'
		  WHEN age > 24 AND age <= 34 THEN 'Kelompok Usia Pekerja Awal'
	  	WHEN age > 34 AND age <= 44 THEN 'Kelompok Usia Paruh Baya'
		  WHEN age > 44 AND age <= 54 THEN 'Kelompok Usia Pra-Pensiun'
		  ELSE 'Kelompok Usia Pensiun' END AS kelompok_usia
	FROM 
    farhanthif.employee_sc) AS kelompok_usia
  GROUP BY kelompok_usia;

-- TOP 10 EMPLOYEE --
SELECT 
  *, 
  ((awards_won * 0.5) +
    (previous_year_rating * 0.3) +
    (avg_training_score * 0.2)
    ) AS overall_score
FROM 
  farhanthif.employee_sc 
ORDER BY 
  overall_score DESC LIMIT 10;

-- TOP EMPLOYEE BY DEPARTMENT --
WITH RankedEmployees AS (
    SELECT
        *,
        (
            (awards_won * 0.5) +
            (previous_year_rating * 0.3) +
            (avg_training_score * 0.2)
        ) AS overall_score,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY 
            (awards_won * 0.5) +
            (previous_year_rating * 0.3) +
            (avg_training_score * 0.2) DESC
        ) AS row_num
    FROM
        farhanthif.employee_sc
)
SELECT
    employee_id,
    department,
    awards_won,
    previous_year_rating,
    avg_training_score,
    overall_score
FROM
    RankedEmployees
WHERE
    row_num = 1;
    
-- TOP 3 DEPARTMENT --
WITH score_employee AS (
	SELECT *, (
		(awards_won * 0.5) +
		(previous_year_rating * 0.3) +
		(avg_training_score * 0.2)
		) AS overall_score
	FROM 
    farhanthif.employee_sc 
  ORDER BY 
    overall_score
  )
SELECT 
  department, 
  AVG(overall_score) AS score_rate 
FROM 
  score_employee 
GROUP BY 
  department
ORDER BY 
  score_rate DESC LIMIT 3;

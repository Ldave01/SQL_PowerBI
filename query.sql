----------------------------------------------------------------------------------------------------
-------------------------------------------MySQL Query----------------------------------------------
----------------------------------------------------------------------------------------------------

--* Question 2. Calculate the number of health facilities per commune.
SELECT commune.adm2_en AS Commune ,count(spa.factype) AS NumberOfFacilities
FROM spa INNER JOIN commune on commune.adm2code=spa.adm2code INNER JOIN factype on spa.factype=factype.factype
GROUP BY commune.adm2_en
--OR--
SELECT commune.adm2_en AS Commune, count(spa.factype) AS NumberOfFacilities
FROM commune, factype, spa
WHERE commune.adm2code=spa.adm2code AND spa.factype=factype.factype
GROUP BY commune.adm2_en


--* Question 3. Calculate the number of health facilities by commune and by type of health facility.
SELECT commune.adm2_en AS Commune, factype.facdesc_1 AS HealthFacility , count(spa.factype) AS NumberOfFacilities
FROM commune INNER JOIN spa on commune.adm2code=spa.adm2code INNER JOIN factype on spa.factype=factype.factype
GROUP BY commune.adm2_en,factype.facdesc_1


--* Question 4. Calculate the number of health facilities by municipality and by department.
SELECT departement.adm1_en AS Departement, commune.adm2_en AS Commune, factype.facdesc_1 AS HealthFacility , count(spa.factype) AS NumberOfFacilities
FROM commune, departement, spa, factype 
WHERE commune.adm2code=spa.adm2code AND departement.adm1code=commune.adm1code AND spa.factype=factype.factype
GROUP BY departement.adm1_en , commune.adm2_en, factype.facdesc_1

--* Question 5: Calculate the number of sites by type (mga) and by department.
SELECT departement.adm1_en AS Departement, spa.mga, count(factype.factype) AS NumberOfFacilities
FROM departement, spa, factype, commune
WHERE commune.adm2code=spa.adm2code AND spa.factype=factype.factype AND commune.adm1code=departement.adm1code
GROUP BY departement.adm1_en, spa.mga

--* Question 6: Calculate the number of sites with an ambulance by commune and by department (ambulance = 1.0).
SELECT departement.adm1_en AS Departement, commune.adm2_en AS Commune, count(spa.factype) AS Number_Of_Facility_With_Ambulance
FROM departement, spa, factype, commune
WHERE commune.adm2code=spa.adm2code AND spa.factype=factype.factype AND departement.adm1code=commune.adm1code AND spa.ambulance='1.0'
GROUP BY departement.adm1_en, commune.adm2_en

--* Question 7. Calculate the number of hospitals per 10k inhabitants by department.
SELECT adm1_en AS Departement, ROUND((COUNT(spa.factype)*10000/(departement.IHSI_UNFPA_2019)),3) AS Number_of_hospitals_per_10k_habitants  
FROM departement, spa,commune,factype
WHERE commune.adm2code=spa.adm2code AND spa.factype=factype.factype AND departement.adm1code=commune.adm1code 
GROUP BY departement.adm1_en, departement.IHSI_UNFPA_2019


--* Question 8. Calculate the number of sites per 10k inhabitants per department.
SELECT adm1_en AS Departement, ROUND((COUNT(spa.factype)*10000/(departement.IHSI_UNFPA_2019)),3) AS Number_of_hospitals_per_10k_habitants  
FROM departement, spa, factype,commune
WHERE commune.adm2code=spa.adm2code AND spa.factype=factype.factype AND departement.adm1code=commune.adm1code  AND factype.facdesc_1='HOPITAL'
GROUP BY departement.adm1_en, departement.IHSI_UNFPA_2019

--* Question 9: Calculate the number of beb per 1,000 inhabitants per department.
SELECT adm1_en AS Departement, ROUND((SUM(spa.num_beds)*1000/(departement.IHSI_UNFPA_2019)),3) AS Number_Of_Bed 
FROM Departement, spa,commune
WHERE commune.adm2code=spa.adm2code  AND departement.adm1code=commune.adm1code
GROUP BY departement.adm1_en 

--* Question 10. How many communes have fewer dispensaries than hospitals?
CREATE VIEW Dispensaire AS
SELECT commune.adm2_en as Commune, factype.facdesc_1 AS Health_Facility, COUNT(spa.factype) AS Num_Of_Dispensaire
FROM spa INNER JOIN commune on commune.adm2code=spa.adm2code INNER JOIN  factype on spa.factype=factype.factype
WHERE (factype.facdesc_1)='DISPENSAIRE'
GROUP BY commune.adm2_en, factype.facdesc_1;

CREATE VIEW Hopital AS
SELECT commune.adm2_en as Commune, factype.facdesc_1 AS Health_Facility, COUNT(spa.factype) AS Num_Of_Hopital
FROM spa INNER JOIN commune on commune.adm2code=spa.adm2code INNER JOIN  factype on spa.factype=factype.factype
WHERE (factype.facdesc_1)='HOPITAL'
GROUP BY commune.adm2_en, factype.facdesc_1;

SELECT * FROM Hopital LEFT JOIN Dispensaire on hopital.Commune=Dispensaire.Commune
WHERE Hopital.Num_Of_Hopital > Dispensaire.Num_Of_Dispensaire
UNION 
SELECT * FROM Hopital RIGHT JOIN Dispensaire on Hopital.Commune=Dispensaire.Commune
WHERE Hopital.Num_Of_Hopital > Dispensaire.Num_Of_Dispensaire

--* Question 11 How many  Letality rate per month
SELECT monthname(covid_case.document_date) AS Month , ROUND(SUM(covid_case.deces)/SUM(covid_case.cas_confirmes),3)  AS Letality_Rate FROM covid_case
GROUP BY monthname(covid_case.document_date)


--* Question 12 How many Death rate per month
SELECT monthname(covid_case.document_date) AS Month , ROUND(SUM(covid_case.deces)/SUM(covid_case.cas_confirmes),3)  AS Letality_Rate FROM covid_case
GROUP BY monthname(covid_case.document_date) 

--* Question 13 How many Prevalence per month
SELECT monthname(covid_case.document_date) AS Month , ROUND(SUM(covid_case.cas_confirmes)/SUM(departement.IHSI_UNFPA_2019),10) AS Prevalence_Rate 
FROM covid_case INNER JOIN departement on departement.adm1code=covid_case.adm1code
GROUP BY monthname(covid_case.document_date)

--* Question 14 How many Prevalence by department
SELECT monthname(covid_case.document_date) AS Month , departement.adm1_en AS Departement, ROUND(SUM(covid_case.cas_confirmes)/SUM(departement.IHSI_UNFPA_2019),10) AS Prevalence_Rate 
FROM covid_case INNER JOIN departement on departement.adm1code=covid_case.adm1code
GROUP BY monthname(covid_case.document_date), departement.adm1_en

--* Question 15 What is the variation of the prevalence per week
SELECT week(covid_case.document_date) AS Week , ROUND(SUM(covid_case.cas_confirmes)/SUM(departement.IHSI_UNFPA_2019),10) AS Prevalence_Rate 
FROM covid_case INNER JOIN departement on departement.adm1code=covid_case.adm1code
GROUP BY week(covid_case.document_date)
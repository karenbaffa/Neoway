
-- Análise Base COVID --
-- Dados Gerais --

USE PRODUCAO
GO
SELECT TOP 15 UPPER(A.name) AS ATRIBUTOS, A.column_id INTO Producao..BASE_COVID_COLUNAS
  FROM sys.columns A WHERE object_id = object_id('BASE_COVID')

CREATE TABLE Producao..BASE_COVID_RESUMO (
NRO_REGISTROS INT, 
NRO_ATRIBUTOS INT,
NRO_REGISTROS_DISTINTOS INT)

INSERT INTO Producao..BASE_COVID_RESUMO (NRO_REGISTROS, NRO_ATRIBUTOS, NRO_REGISTROS_DISTINTOS) 
VALUES (

(SELECT COUNT(*) AS TOTAL_REGISTROS
  FROM Producao..BASE_COVID), -- 10.499

(SELECT COUNT(*)
  FROM Producao..BASE_COVID_COLUNAS), -- 15

(SELECT COUNT(DISTINCT A.source_id) 
   FROM Producao..BASE_COVID A) --10.489
); 

-- Atributo SOURCE_ID --

SELECT * INTO Producao..BASE_COVID_REP FROM 
(SELECT A.source_id, COUNT(*) AS Qtde_Rep
 FROM Producao..BASE_COVID A 
 GROUP BY A.source_id
 HAVING COUNT(*) > 1)X

SELECT DISTINCT A.* FROM Producao..BASE_COVID A
WHERE EXISTS (SELECT 1 FROM Producao..BASE_COVID_REP B
               WHERE B.source_id = A.source_id)
ORDER BY 1

-- Atributo SINTOMAS --

  SELECT DISTINCT TRIM(VALUE)
  FROM Producao..BASE_COVID A
  CROSS APPLY string_split(SINTOMAS,',')
  ORDER BY 1

  SELECT DISTINCT TRIM(VALUE)
  FROM Producao..BASE_COVID A
  CROSS APPLY string_split(outrosSintomas,',')
  ORDER BY 1

  ALTER TABLE Producao..BASE_COVID ADD ASSINTOMATICO INT
  ALTER TABLE Producao..BASE_COVID ADD CORIZA INT 
  ALTER TABLE Producao..BASE_COVID ADD DISPNEIA INT 
  ALTER TABLE Producao..BASE_COVID ADD DIST_GUSTATIVOS INT 
  ALTER TABLE Producao..BASE_COVID ADD DIST_OLFATIVOS INT 
  ALTER TABLE Producao..BASE_COVID ADD DOR_DE_CABECA INT 
  ALTER TABLE Producao..BASE_COVID ADD DOR_DE_GARGANTA INT 
  ALTER TABLE Producao..BASE_COVID ADD FEBRE INT 
  ALTER TABLE Producao..BASE_COVID ADD OUTROS INT 
  ALTER TABLE Producao..BASE_COVID ADD TOSSE INT 

  UPDATE A 
     SET A.ASSINTOMATICO = 0,
	     A.CORIZA = 0,
		 A.DISPNEIA = 0,
		 A.DIST_GUSTATIVOS = 0,
		 A.DIST_OLFATIVOS = 0,
		 A.DOR_DE_CABECA = 0,
		 A.DOR_DE_GARGANTA = 0,
		 A.FEBRE = 0,
		 A.OUTROS = 0,
		 A.TOSSE = 0
	 FROM Producao..BASE_COVID A
  
  UPDATE A 
     SET A.ASSINTOMATICO = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas = 'Assintomático'

  UPDATE A 
     SET A.CORIZA = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas LIKE ('%Coriza%')

  UPDATE A 
     SET A.DISPNEIA = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas LIKE ('%Dispneia%')

  UPDATE A 
     SET A.DIST_GUSTATIVOS = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas LIKE ('%Distúrbios Gustativos%')

 UPDATE A 
     SET A.DIST_OLFATIVOS = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas LIKE ('%Distúrbios Olfativos%')

 UPDATE A 
     SET A.DOR_DE_CABECA = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas LIKE ('%Dor de Cabeça%')

 UPDATE A 
     SET A.DOR_DE_GARGANTA = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas LIKE ('%Dor de Garganta%')

 UPDATE A 
     SET A.FEBRE = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas LIKE ('%Febre%')

 UPDATE A 
     SET A.OUTROS = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas LIKE ('%Outros%')

 UPDATE A 
     SET A.TOSSE = 1
	 FROM Producao..BASE_COVID A
  WHERE A.sintomas LIKE ('%Tosse%')


SELECT A.*, A.sintomas
  FROM Producao..BASE_COVID A

-- Abrangência --

CREATE TABLE Producao..BASE_UF (UF VARCHAR(2),REGIAO VARCHAR(50))
INSERT INTO Producao..BASE_UF (UF,REGIAO) VALUES 
 ('AC','Norte'),('AL','Nordeste'),('AM','Norte'),('AP','Norte'),
 ('BA','Nordeste'),('CE','Nordeste'),('DF','Centro-Oeste'),('ES','Sudeste'),
 ('GO','Centro-Oeste'),('MA','Nordeste'),('MG','Sudeste'),('MS','Centro-Oeste'),
 ('MT','Centro-Oeste'),('PA','Norte'),('PB','Nordeste'),('PE','Nordeste'),
 ('PI','Nordeste'),('PR','Sul'),('RJ','Sudeste'),('RN','Nordeste'),('RO','Norte'),
 ('RR','Norte'),('RS','Sul'),('SC','Sul'),('SE','Nordeste'),('SP','Sudeste'),('TO','Norte');
 
SELECT C.*, B.QTD_CPF 
  INTO Producao..BASE_COVID_UF
  FROM Producao..BASE_UF C
LEFT JOIN 
(SELECT UF, COUNT(*) AS QTD_CPF
FROM Producao..BASE_COVID A
GROUP BY A.UF)B
ON B.UF = C.UF

SELECT * 
  FROM Producao..BASE_COVID
WHERE UF <> '' --5415

SELECT A.UF, COUNT(*)
FROM Producao..BASE_COVID A
GROUP BY A.UF

-- Preenchimento --

SELECT A.IDADE, COUNT(*)
FROM Producao..BASE_COVID A
GROUP BY A.IDADE
ORDER BY CAST(IDADE AS INT)

SELECT 
  CASE WHEN A.idade < 18 THEN 'Menores de 18'
       WHEN A.idade BETWEEN 18 AND 25 THEN 'De 18 a 25'
	   WHEN A.idade BETWEEN 26 AND 35 THEN 'De 26 a 35'
       WHEN A.idade BETWEEN 36 AND 45 THEN 'De 36 a 45'
	   WHEN A.idade BETWEEN 46 AND 55 THEN 'De 46 a 55'
	   WHEN A.idade BETWEEN 56 AND 65 THEN 'De 56 a 65'
	   WHEN A.idade > 65 THEN 'Maiores de 65' END AS FAIXA,
  COUNT(*) AS QTD_CPF
INTO Producao..BASE_COVID_IDADE
FROM Producao..BASE_COVID A
WHERE A.idade <> ''
GROUP BY CASE WHEN A.idade < 18 THEN 'Menores de 18'
       WHEN A.idade BETWEEN 18 AND 25 THEN 'De 18 a 25'
	   WHEN A.idade BETWEEN 26 AND 35 THEN 'De 26 a 35'
       WHEN A.idade BETWEEN 36 AND 45 THEN 'De 36 a 45'
	   WHEN A.idade BETWEEN 46 AND 55 THEN 'De 46 a 55'
	   WHEN A.idade BETWEEN 56 AND 65 THEN 'De 56 a 65'
	   WHEN A.idade > 65 THEN 'Maiores de 65' END 

SELECT A.SEXO, COUNT(*) QTDE
FROM Producao..BASE_COVID A
GROUP BY A.SEXO
ORDER BY QTDE DESC

SELECT CASE WHEN A.SEXO IN ('Feminino','F','Mulher') THEN 'Feminino'
            WHEN A.SEXO IN ('Masculino','M','Mulher') THEN 'Masculino'
			ELSE 'Indefinido' END AS GENERO,
COUNT(*) QTDE
INTO Producao..BASE_COVID_SEXO
FROM Producao..BASE_COVID A
WHERE A.SEXO <> ''
GROUP BY CASE WHEN A.SEXO IN ('Feminino','F','Mulher') THEN 'Feminino'
              WHEN A.SEXO IN ('Masculino','M','Mulher') THEN 'Masculino'
			  ELSE 'Indefinido' END

SELECT A.racaCor, COUNT(*) QTDE
INTO Producao..BASE_COVID_RACACOR
FROM Producao..BASE_COVID A
GROUP BY A.racaCor
ORDER BY QTDE DESC

SELECT A.profissionalSaude, COUNT(*) QTDE
INTO Producao..BASE_COVID_PSAUDE
FROM Producao..BASE_COVID A
GROUP BY A.profissionalSaude
ORDER BY QTDE DESC

SELECT A.municipio AS Municipio, COUNT(*) AS Qtd_CPFs
INTO Producao..BASE_COVID_MUNICIPIO
FROM Producao..BASE_COVID A
GROUP BY A.municipio
ORDER BY Qtd_CPFs DESC

SELECT A.codigoLaboratorioPrimeiraDose, COUNT(*) QTDE
FROM Producao..BASE_COVID A
GROUP BY A.codigoLaboratorioPrimeiraDose
ORDER BY QTDE DESC

SELECT CASE WHEN A.codigoLaboratorioPrimeiraDose IN ('SINOVAC/BUTANTAN','Sinovac') THEN 'Sinovac'
            WHEN A.codigoLaboratorioPrimeiraDose = 'ASTRAZENECA/FIOCRUZ' THEN 'Astrazeneca' 
			WHEN A.codigoLaboratorioPrimeiraDose = 'JANSSEN' THEN 'Janssen' 
			WHEN A.codigoLaboratorioPrimeiraDose = 'PFIZER' THEN 'Pfizer'
			ELSE '' END AS Laboratório,
 COUNT(*) QTDE
 INTO Producao..BASE_COVID_LAB_D1
 FROM Producao..BASE_COVID A
 GROUP BY CASE WHEN A.codigoLaboratorioPrimeiraDose IN ('SINOVAC/BUTANTAN','Sinovac') THEN 'Sinovac'
            WHEN A.codigoLaboratorioPrimeiraDose = 'ASTRAZENECA/FIOCRUZ' THEN 'Astrazeneca' 
			WHEN A.codigoLaboratorioPrimeiraDose = 'JANSSEN' THEN 'Janssen' 
			WHEN A.codigoLaboratorioPrimeiraDose = 'PFIZER' THEN 'Pfizer'
			ELSE '' END
ORDER BY QTDE DESC

SELECT A.codigoLaboratorioSegundaDose, COUNT(*) QTDE
FROM Producao..BASE_COVID A
GROUP BY A.codigoLaboratorioSegundaDose
ORDER BY QTDE DESC

SELECT CASE WHEN A.codigoLaboratorioSegundaDose IN ('SINOVAC/BUTANTAN','Sinovac') THEN 'Sinovac'
            WHEN A.codigoLaboratorioSegundaDose = 'ASTRAZENECA/FIOCRUZ' THEN 'Astrazeneca' 
			WHEN A.codigoLaboratorioSegundaDose = 'JANSSEN' THEN 'Janssen' 
			WHEN A.codigoLaboratorioSegundaDose IN ('PFIZER','PFIZER/BIONTECH') THEN 'Pfizer'
			ELSE '' END AS Laboratório,
 COUNT(*) QTDE
 INTO Producao..BASE_COVID_LAB_D2
 FROM Producao..BASE_COVID A
 GROUP BY CASE WHEN A.codigoLaboratorioSegundaDose IN ('SINOVAC/BUTANTAN','Sinovac') THEN 'Sinovac'
            WHEN A.codigoLaboratorioSegundaDose = 'ASTRAZENECA/FIOCRUZ' THEN 'Astrazeneca' 
			WHEN A.codigoLaboratorioSegundaDose = 'JANSSEN' THEN 'Janssen' 
			WHEN A.codigoLaboratorioSegundaDose IN ('PFIZER','PFIZER/BIONTECH') THEN 'Pfizer'
			ELSE '' END
ORDER BY QTDE DESC

SELECT A.dataNotificacao, COUNT(*) QTDE
FROM Producao..BASE_COVID A
GROUP BY A.dataNotificacao
ORDER BY QTDE DESC

SELECT A.dataInicioSintomas, COUNT(*) QTDE
FROM Producao..BASE_COVID A
GROUP BY A.dataInicioSintomas
ORDER BY QTDE DESC

SELECT A.dataPrimeiraDose, COUNT(*) QTDE
FROM Producao..BASE_COVID A
GROUP BY A.dataPrimeiraDose
ORDER BY QTDE DESC

SELECT A.dataSegundaDose, COUNT(*) QTDE
FROM Producao..BASE_COVID A
GROUP BY A.dataSegundaDose
ORDER BY QTDE DESC
  
SELECT *
FROM Producao..BASE_COVID A
WHERE sintomas IS NULL OR sintomas = '' --32
  
CREATE TABLE Producao..BASE_COVID_SINTOMAS( Descricao varchar(50), Sim int, Nao int, Total int)

INSERT INTO Producao..BASE_COVID_SINTOMAS(Descricao,Sim, Nao, Total) Values 
('Assintomatico',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0),
	
(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '')),

('Coriza',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.CORIZA = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.CORIZA = 0),
	
(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.ASSINTOMATICO = 0)),

('Dispneia',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DISPNEIA = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DISPNEIA = 0),
	
(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.ASSINTOMATICO = 0)),

('Dist_Gustativos',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DIST_GUSTATIVOS = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DIST_GUSTATIVOS = 0),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.ASSINTOMATICO = 0)),

('Dist_Olfativos',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DIST_OLFATIVOS = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DIST_OLFATIVOS = 0),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.ASSINTOMATICO = 0)),

('Dor_de_Cabeca',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DOR_DE_CABECA = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DOR_DE_CABECA = 0),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.ASSINTOMATICO = 0)),

('Dor_de_Garganta',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DOR_DE_GARGANTA = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.DOR_DE_GARGANTA = 0),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.ASSINTOMATICO = 0)),

('Febre',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.FEBRE = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.FEBRE = 0),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.ASSINTOMATICO = 0)),

('Outros',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.OUTROS = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.OUTROS = 0),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.ASSINTOMATICO = 0)),

('Tosse',

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.TOSSE = 1),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> '' 
    AND A.ASSINTOMATICO = 0
    AND A.TOSSE = 0),

(SELECT COUNT(*) QTDE
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.ASSINTOMATICO = 0))

CREATE TABLE Producao..BASE_COVID_DOSES (Dose VARCHAR(50),Qtd_CPF int)

INSERT INTO Producao..BASE_COVID_DOSES(Dose, Qtd_CPF) VALUES

('Nenhuma',

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose = '' 
   AND A.dataSegundaDose = '')),

('Primeira Dose',

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose = '')),

('Segunda Dose',

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose <> ''))

CREATE TABLE Producao..BASE_COVID_DOSES_X_SINTOMAS (Dose VARCHAR(50), Sim int, Nao int, Total int)

INSERT INTO Producao..BASE_COVID_DOSES_X_SINTOMAS(Dose, Sim, Nao, Total) VALUES

('Nenhuma',

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose = '' 
   AND A.dataSegundaDose = ''
   AND A.ASSINTOMATICO = 0),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose = '' 
   AND A.dataSegundaDose = ''
   AND A.ASSINTOMATICO = 1),
   
(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose = '' 
   AND A.dataSegundaDose = '')),

('Primeira Dose',

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose = ''
   AND A.ASSINTOMATICO = 0),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose = ''
   AND A.ASSINTOMATICO = 1),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose = '')),

('Segunda Dose',

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose <> ''
   AND A.ASSINTOMATICO = 0),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose <> ''
   AND A.ASSINTOMATICO = 1),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose <> ''))


SELECT A.racaCor,COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose <> ''
GROUP BY A.racaCor

SELECT A.racaCor,COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '' 
   AND A.dataSegundaDose = ''
GROUP BY A.racaCor

SELECT A.racaCor,COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose = '' 
   AND A.dataSegundaDose = ''
GROUP BY A.racaCor


-- Padronização --

SELECT * FROM Producao..BASE_COVID_REP

CREATE TABLE Producao..BASE_COVID_F_DATA(Atributo VARCHAR(50), Nulos_Brancos int, 
        Fora_Formatacao int, Fora_Intervalo_Min int, Fora_Intervalo_Max int, Fora_Regra int,
		Padronizado int, Total int, Total_N_Nulo int)

SET DATEFORMAT YMD;

INSERT INTO Producao..BASE_COVID_F_DATA(Atributo, Nulos_Brancos, Fora_Formatacao, 
  Fora_Intervalo_Min, Fora_Intervalo_Max, Fora_Regra, Padronizado, Total, Total_N_Nulo) VALUES

('Data_Notificacao',

(SELECT COUNT(*) AS Qtd_Nulo
  FROM Producao..BASE_COVID A
 WHERE A.dataNotificacao = ''
    OR A.dataNotificacao IS NULL),

(SELECT COUNT(*) 
   FROM Producao..BASE_COVID A
  WHERE A.dataNotificacao <> ''
    AND ISDATE(a.dataNotificacao) = 0),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataNotificacao <> ''
   AND A.dataNotificacao < '2020-01-04'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataNotificacao <> ''
   AND A.dataNotificacao > '2022-07-22'),

0,

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.dataNotificacao <> ''
    AND ISDATE(a.dataNotificacao) = 1
    AND A.dataNotificacao BETWEEN '2020-01-04' AND '2022-07-22'),
   
(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataNotificacao <> '')),

('Data_Inicio_Sintomas',

(SELECT COUNT(*) AS Qtd_Nulo
  FROM Producao..BASE_COVID A
 WHERE A.dataInicioSintomas = ''
    OR A.dataInicioSintomas IS NULL),

(SELECT COUNT(*) 
   FROM Producao..BASE_COVID A
  WHERE A.dataInicioSintomas <> ''
    AND ISDATE(a.dataInicioSintomas) = 0),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataInicioSintomas <> ''
   AND A.dataInicioSintomas < '2020-01-04'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataInicioSintomas <> ''
   AND A.dataInicioSintomas > '2022-07-22'),

0,

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.dataInicioSintomas <> ''
    AND ISDATE(a.dataInicioSintomas) = 1
    AND A.dataInicioSintomas BETWEEN '2020-01-04' AND '2022-07-22'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataInicioSintomas <> '')),

('Data_Primeira_Dose',

(SELECT COUNT(*) AS Qtd_Nulo
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose = ''
    OR A.dataPrimeiraDose IS NULL),

(SELECT COUNT(*) 
   FROM Producao..BASE_COVID A
  WHERE A.dataPrimeiraDose <> ''
    AND ISDATE(a.dataPrimeiraDose) = 0),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> ''
   AND A.dataPrimeiraDose < '2020-03-23'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> ''
   AND A.dataPrimeiraDose > '2022-07-22'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> ''
   AND A.dataSegundaDose <> ''
   AND A.dataPrimeiraDose >= A.dataSegundaDose),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.dataPrimeiraDose <> ''
    AND ISDATE(a.dataPrimeiraDose) = 1
    AND A.dataPrimeiraDose BETWEEN '2020-03-23' AND '2022-07-22'
	AND ((A.dataSegundaDose = '') OR (A.dataSegundaDose <> '' AND A.dataPrimeiraDose < A.dataSegundaDose))),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose <> '')),

('Data_Segunda_Dose',

(SELECT COUNT(*) AS Qtd_Nulo
  FROM Producao..BASE_COVID A
 WHERE A.dataSegundaDose = ''
    OR A.dataSegundaDose IS NULL),

(SELECT COUNT(*) 
   FROM Producao..BASE_COVID A
  WHERE A.dataSegundaDose <> ''
    AND ISDATE(a.dataSegundaDose) = 0),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataSegundaDose <> ''
   AND A.dataSegundaDose < '2020-08-19'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataSegundaDose <> ''
   AND A.dataSegundaDose > '2022-07-22'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataSegundaDose <> ''
   AND A.dataPrimeiraDose <> ''
   AND A.dataSegundaDose <= A.dataPrimeiraDose),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.dataSegundaDose <> ''
    AND ISDATE(a.dataSegundaDose) = 1
    AND A.dataSegundaDose BETWEEN '2020-08-19' AND '2022-07-22'
	AND ((A.dataPrimeiraDose = '') OR (A.dataPrimeiraDose <> '' AND A.dataPrimeiraDose < A.dataSegundaDose))),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A
 WHERE A.dataSegundaDose <> ''))


SELECT * FROM Producao..BASE_COVID_F_DATA

--SELECT MIN(LEN(A.dataNotificacao)) AS Tam_Min,MAX(LEN(A.dataNotificacao)) AS Tam_Max
-- FROM Producao..BASE_COVID A
--WHERE A.dataNotificacao <> ''

--SELECT DISTINCT SUBSTRING(A.dataNotificacao,1,4) AS ANO, COUNT(*)
-- FROM Producao..BASE_COVID A
--WHERE A.dataNotificacao <> ''
--GROUP BY SUBSTRING(A.dataNotificacao,1,4)
--ORDER BY 1

--SELECT DISTINCT SUBSTRING(A.dataNotificacao,5,1)
-- FROM Producao..BASE_COVID A
--WHERE A.dataNotificacao <> ''

--SELECT DISTINCT SUBSTRING(A.dataNotificacao,6,2) AS MES, COUNT(*)
-- FROM Producao..BASE_COVID A
--WHERE A.dataNotificacao <> ''
--GROUP BY SUBSTRING(A.dataNotificacao,6,2)
--ORDER BY 1

--SELECT DISTINCT SUBSTRING(A.dataNotificacao,8,1)
-- FROM Producao..BASE_COVID A
--WHERE A.dataNotificacao <> ''

--SELECT DISTINCT SUBSTRING(A.dataNotificacao,9,2) AS DIA, COUNT(*)
-- FROM Producao..BASE_COVID A
--WHERE A.dataNotificacao <> ''
--GROUP BY SUBSTRING(A.dataNotificacao,9,2)
--ORDER BY 1

--SELECT MIN(LEN(A.dataInicioSintomas)) AS Tam_Min,MAX(LEN(A.dataInicioSintomas)) AS Tam_Max
-- FROM Producao..BASE_COVID A
--WHERE A.dataInicioSintomas <> ''

--SELECT DISTINCT SUBSTRING(A.dataInicioSintomas,1,4) AS ANO, COUNT(*)
-- FROM Producao..BASE_COVID A
--WHERE A.dataInicioSintomas <> ''
--GROUP BY SUBSTRING(A.dataInicioSintomas,1,4)
--ORDER BY 1

--SELECT DISTINCT SUBSTRING(A.dataInicioSintomas,5,1)
-- FROM Producao..BASE_COVID A
--WHERE A.dataInicioSintomas <> ''

--SELECT DISTINCT SUBSTRING(A.dataInicioSintomas,6,2) AS MES, COUNT(*)
-- FROM Producao..BASE_COVID A
--WHERE A.dataInicioSintomas <> ''
--GROUP BY SUBSTRING(A.dataInicioSintomas,6,2)
--ORDER BY 1

--SELECT DISTINCT SUBSTRING(A.dataInicioSintomas,8,1)
-- FROM Producao..BASE_COVID A
--WHERE A.dataInicioSintomas <> ''

--SELECT DISTINCT SUBSTRING(A.dataInicioSintomas,9,2) AS DIA, COUNT(*)
-- FROM Producao..BASE_COVID A
--WHERE A.dataInicioSintomas <> ''
--GROUP BY SUBSTRING(A.dataInicioSintomas,9,2)
--ORDER BY 1

SELECT X.*
INTO Producao..BASE_COVID_F_DATA_CASOS
FROM
(
SELECT 'DataNotificacao' AS Atributo, dataNotificacao AS Data, COUNT(*) AS Qtd_Registros
  FROM Producao..BASE_COVID A
 WHERE A.dataNotificacao <> ''
   AND A.dataNotificacao < '2020-01-04'
 GROUP BY A.dataNotificacao

UNION ALL

SELECT 'DataInicioSintomas' AS Atributo, dataInicioSintomas AS Data, COUNT(*) AS Qtd_Registros
  FROM Producao..BASE_COVID A
 WHERE A.dataInicioSintomas <> ''
   AND A.dataInicioSintomas < '2020-01-04'
 GROUP BY A.dataInicioSintomas

UNION ALL

SELECT 'DataInicioSintomas' AS Atributo, dataInicioSintomas AS Data, COUNT(*) AS Qtd_Registros
  FROM Producao..BASE_COVID A
 WHERE A.dataInicioSintomas <> ''
   AND A.dataInicioSintomas > '2022-07-22'
 GROUP BY A.dataInicioSintomas)X
 

SELECT X.dataPrimeiraDose, X.dataSegundaDose, COUNT(*) AS Qtd_Registros
INTO Producao..BASE_COVID_F_DATA_CASOS_2
FROM
(
SELECT dataPrimeiraDose, dataSegundaDose
   FROM Producao..BASE_COVID A
  WHERE A.dataPrimeiraDose <> ''
    AND ( ISDATE(a.dataPrimeiraDose) = 0
         OR A.dataPrimeiraDose NOT BETWEEN '2020-03-23' AND '2022-07-22')
UNION ALL

SELECT dataPrimeiraDose, dataSegundaDose
   FROM Producao..BASE_COVID A
  WHERE A.dataSegundaDose <> ''
    AND ( ISDATE(a.dataSegundaDose) = 0
         OR A.dataSegundaDose NOT BETWEEN '2020-08-19' AND '2022-07-22')
)X
GROUP BY X.dataPrimeiraDose, X.dataSegundaDose

CREATE TABLE Producao..BASE_COVID_F_1(Atributo VARCHAR(50), Nulos_Brancos int, 
        Contem_Numeros int, Acentuacao int, Caracteres_Especiais int, Letras_Minusculas int,
		Valores_N_Definidos int, Padronizado int, Total int, Total_N_Nulo int)

INSERT INTO Producao..BASE_COVID_F_1(Atributo, Nulos_Brancos, Contem_Numeros, Acentuacao,
            Caracteres_Especiais, Letras_Minusculas, Valores_N_Definidos, Padronizado, Total, Total_N_Nulo) VALUES

('Sintomas',

(SELECT COUNT(*) FROM Producao..BASE_COVID A
  WHERE A.sintomas IS NULL OR A.sintomas = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.sintomas <> ''
   AND CAST(A.sintomas AS VARCHAR(500)) LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND A.sintomas <> CAST(A.sintomas AS VARCHAR(500)) COLLATE sql_latin1_general_cp1251_ci_as),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.sintomas <> ''
   AND CAST(A.sintomas AS VARCHAR(500)) LIKE '%[^A-Z0-9, ]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.sintomas <> ''
   AND UPPER(A.sintomas) <> A.sintomas COLLATE latin1_general_cs_ai),

0,

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND CAST(A.sintomas AS VARCHAR(500)) NOT LIKE '%[0-9]%'
    AND A.sintomas = CAST(A.sintomas AS VARCHAR(500)) COLLATE sql_latin1_general_cp1251_ci_as
	AND UPPER(A.sintomas) = A.sintomas COLLATE latin1_general_cs_ai
	AND CAST(A.sintomas AS VARCHAR(500)) NOT LIKE '%[^A-Z, ]%'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.sintomas <> '')),

('Outros_Sintomas',

(SELECT COUNT(*) FROM Producao..BASE_COVID A
  WHERE A.outrosSintomas IS NULL OR A.outrosSintomas = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.outrosSintomas <> ''
   AND CAST(A.outrosSintomas AS VARCHAR(2000)) LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.outrosSintomas <> ''
    AND A.outrosSintomas <> CAST(A.outrosSintomas AS VARCHAR(2000)) COLLATE sql_latin1_general_cp1251_ci_as),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.outrosSintomas <> ''
   AND CAST(A.outrosSintomas AS VARCHAR(2000)) LIKE '%[^A-Z0-9, ]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.outrosSintomas <> ''
   AND UPPER(A.outrosSintomas) <> A.outrosSintomas COLLATE latin1_general_cs_ai),

0,

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.outrosSintomas <> ''
    AND CAST(A.outrosSintomas AS VARCHAR(2000)) NOT LIKE '%[0-9]%'
    AND A.outrosSintomas = CAST(A.outrosSintomas AS VARCHAR(2000)) COLLATE sql_latin1_general_cp1251_ci_as
	AND UPPER(A.outrosSintomas) = A.outrosSintomas COLLATE latin1_general_cs_ai
	AND CAST(A.outrosSintomas AS VARCHAR(2000)) NOT LIKE '%[^A-Z, ]%'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.outrosSintomas <> '')),

('Municipio',

(SELECT COUNT(*) FROM Producao..BASE_COVID A
  WHERE A.municipio IS NULL OR A.municipio = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.municipio <> ''
   AND CAST(A.municipio AS VARCHAR(200)) LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.municipio <> ''
    AND A.municipio <> CAST(A.municipio AS VARCHAR(200)) COLLATE sql_latin1_general_cp1251_ci_as),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.municipio <> ''
    AND CAST(A.municipio AS VARCHAR(200)) LIKE '%[^A-Z0-9 ]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.municipio <> ''
   AND UPPER(A.municipio) <> A.municipio COLLATE latin1_general_cs_ai),

0,

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.municipio <> ''
    AND CAST(A.municipio AS VARCHAR(200)) NOT LIKE '%[0-9]%'
    AND A.municipio = CAST(A.municipio AS VARCHAR(200)) COLLATE sql_latin1_general_cp1251_ci_as
	AND UPPER(A.municipio) = A.municipio COLLATE latin1_general_cs_ai
	AND CAST(A.municipio AS VARCHAR(200)) NOT LIKE '%[^A-Z ]%'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.municipio <> '')),

('Profissional_Saude',

(SELECT COUNT(*) FROM Producao..BASE_COVID A
  WHERE A.profissionalSaude IS NULL OR A.profissionalSaude = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.profissionalSaude <> ''
   AND CAST(A.profissionalSaude AS VARCHAR(50)) LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.profissionalSaude <> ''
    AND A.profissionalSaude <> CAST(A.profissionalSaude AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.profissionalSaude <> ''
    AND CAST(A.profissionalSaude AS VARCHAR(50)) LIKE '%[^A-Z0-9 ]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.profissionalSaude <> ''
    AND UPPER(A.profissionalSaude) <> A.profissionalSaude COLLATE latin1_general_cs_ai),

0,

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.profissionalSaude <> ''
    AND CAST(A.profissionalSaude AS VARCHAR(50)) NOT LIKE '%[0-9]%'
    AND A.profissionalSaude = CAST(A.profissionalSaude AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as
	AND UPPER(A.profissionalSaude) = A.profissionalSaude COLLATE latin1_general_cs_ai
	AND CAST(A.profissionalSaude AS VARCHAR(50)) NOT LIKE '%[^A-Z ]%'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.profissionalSaude <> '')),

('Raca_Cor',

(SELECT COUNT(*) FROM Producao..BASE_COVID A
  WHERE A.racaCor IS NULL OR A.racaCor = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.racaCor <> ''
   AND CAST(A.racaCor AS VARCHAR(50)) LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.racaCor <> ''
    AND A.racaCor <> CAST(A.racaCor AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.racaCor <> ''
    AND CAST(A.racaCor AS VARCHAR(50)) LIKE '%[^A-Z0-9 ]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.racaCor <> ''
    AND UPPER(A.racaCor) <> A.racaCor COLLATE latin1_general_cs_ai),

0,

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.racaCor <> ''
    AND CAST(A.racaCor AS VARCHAR(50)) NOT LIKE '%[0-9]%'
    AND A.racaCor = CAST(A.racaCor AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as
	AND UPPER(A.racaCor) = A.racaCor COLLATE latin1_general_cs_ai
	AND CAST(A.racaCor AS VARCHAR(50)) NOT LIKE '%[^A-Z ]%'),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.racaCor <> '')),

('Gênero',

(SELECT COUNT(*) FROM Producao..BASE_COVID A
  WHERE A.sexo IS NULL OR A.sexo = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.sexo <> ''
    AND CAST(A.sexo AS VARCHAR(50)) LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.sexo <> ''
    AND A.sexo <> CAST(A.sexo AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.sexo <> ''
    AND CAST(A.sexo AS VARCHAR(50)) LIKE '%[^A-Z0-9 ]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.sexo <> ''
    AND UPPER(A.sexo) <> A.sexo COLLATE latin1_general_cs_ai),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.sexo <> ''
    AND A.sexo NOT IN ('MASCULINO','FEMININO','INDEFINIDO')),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.sexo <> ''
    AND CAST(A.sexo AS VARCHAR(50)) NOT LIKE '%[0-9]%'
    AND A.sexo = CAST(A.sexo AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as
	AND UPPER(A.sexo) = A.sexo COLLATE latin1_general_cs_ai
	AND CAST(A.sexo AS VARCHAR(50)) NOT LIKE '%[^A-Z ]%'
    AND A.sexo IN ('MASCULINO','FEMININO','INDEFINIDO')),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.sexo <> '')),

('UF',

(SELECT COUNT(*) FROM Producao..BASE_COVID A
  WHERE A.uf IS NULL OR A.uf = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.uf <> ''
    AND CAST(A.uf AS VARCHAR(50)) LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.uf <> ''
    AND A.uf <> CAST(A.uf AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.uf <> ''
    AND CAST(A.uf AS VARCHAR(50)) LIKE '%[^A-Z0-9 ]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.uf <> ''
    AND UPPER(A.uf) <> A.uf COLLATE latin1_general_cs_ai),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.uf <> ''
    AND NOT EXISTS (SELECT 1 FROM Producao..BASE_UF B
	                 WHERE B.UF = A.UF)),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.uf <> ''
    AND CAST(A.uf AS VARCHAR(50)) NOT LIKE '%[0-9]%'
    AND A.uf = CAST(A.uf AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as
	AND UPPER(A.uf) = A.uf COLLATE latin1_general_cs_ai
	AND CAST(A.uf AS VARCHAR(50)) NOT LIKE '%[^A-Z ]%'
    AND EXISTS (SELECT 1 FROM Producao..BASE_UF B
	                 WHERE B.UF = A.UF)),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.uf <> '')),

('Laboratorio_PrimeiraDose',

(SELECT COUNT(*) FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioPrimeiraDose IS NULL OR A.codigoLaboratorioPrimeiraDose = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioPrimeiraDose <> ''
    AND CAST(A.codigoLaboratorioPrimeiraDose AS VARCHAR(100)) LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioPrimeiraDose <> ''
    AND A.codigoLaboratorioPrimeiraDose <> CAST(A.codigoLaboratorioPrimeiraDose AS VARCHAR(100)) COLLATE sql_latin1_general_cp1251_ci_as),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioPrimeiraDose <> ''
    AND CAST(A.codigoLaboratorioPrimeiraDose AS VARCHAR(100)) LIKE '%[^A-Z0-9/ ]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioPrimeiraDose <> ''
    AND UPPER(A.codigoLaboratorioPrimeiraDose) <> A.codigoLaboratorioPrimeiraDose COLLATE latin1_general_cs_ai),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioPrimeiraDose <> ''
    AND A.codigoLaboratorioPrimeiraDose NOT IN ('ASTRAZENECA/FIOCRUZ','JANSSEN','SINOVAC/BUTANTAN','PFIZER')),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioPrimeiraDose <> ''
    AND CAST(A.codigoLaboratorioPrimeiraDose AS VARCHAR(100)) NOT LIKE '%[0-9]%'
    AND A.codigoLaboratorioPrimeiraDose = CAST(A.codigoLaboratorioPrimeiraDose AS VARCHAR(100)) COLLATE sql_latin1_general_cp1251_ci_as
	AND UPPER(A.codigoLaboratorioPrimeiraDose) = A.codigoLaboratorioPrimeiraDose COLLATE latin1_general_cs_ai
	AND CAST(A.codigoLaboratorioPrimeiraDose AS VARCHAR(100)) NOT LIKE '%[^A-Z/ ]%'
    AND A.codigoLaboratorioPrimeiraDose IN ('ASTRAZENECA/FIOCRUZ','JANSSEN','SINOVAC/BUTANTAN','PFIZER')),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.codigoLaboratorioPrimeiraDose <> '')),

('Laboratorio_SegundaDose',

(SELECT COUNT(*) FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioSegundaDose IS NULL OR A.codigoLaboratorioSegundaDose = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioSegundaDose <> ''
    AND CAST(A.codigoLaboratorioSegundaDose AS VARCHAR(100)) LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioSegundaDose <> ''
    AND A.codigoLaboratorioSegundaDose <> CAST(A.codigoLaboratorioSegundaDose AS VARCHAR(100)) COLLATE sql_latin1_general_cp1251_ci_as),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioSegundaDose <> ''
    AND CAST(A.codigoLaboratorioSegundaDose AS VARCHAR(100)) LIKE '%[^A-Z0-9/ ]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioSegundaDose <> ''
    AND UPPER(A.codigoLaboratorioSegundaDose) <> A.codigoLaboratorioSegundaDose COLLATE latin1_general_cs_ai),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioSegundaDose <> ''
    AND A.codigoLaboratorioSegundaDose NOT IN ('ASTRAZENECA/FIOCRUZ','JANSSEN','SINOVAC/BUTANTAN','PFIZER')),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioSegundaDose <> ''
    AND CAST(A.codigoLaboratorioSegundaDose AS VARCHAR(100)) NOT LIKE '%[0-9]%'
    AND A.codigoLaboratorioSegundaDose = CAST(A.codigoLaboratorioSegundaDose AS VARCHAR(100)) COLLATE sql_latin1_general_cp1251_ci_as
	AND UPPER(A.codigoLaboratorioSegundaDose) = A.codigoLaboratorioSegundaDose COLLATE latin1_general_cs_ai
	AND CAST(A.codigoLaboratorioSegundaDose AS VARCHAR(100)) NOT LIKE '%[^A-Z/ ]%'
    AND A.codigoLaboratorioSegundaDose IN ('ASTRAZENECA/FIOCRUZ','JANSSEN','SINOVAC/BUTANTAN','PFIZER')),

(SELECT COUNT(*)
  FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
 WHERE A.codigoLaboratorioSegundaDose <> ''))

SELECT X.*
INTO Producao..BASE_COVID_F_1_CASOS
FROM
(
 SELECT 'Sintomas' AS Atributo, A.sintomas AS Valor, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.sintomas <> ''
    AND (CAST(A.sintomas AS VARCHAR(500)) LIKE '%[0-9]%'
         OR A.sintomas <> CAST(A.sintomas AS VARCHAR(500)) COLLATE sql_latin1_general_cp1251_ci_as
	     OR UPPER(A.sintomas) <> A.sintomas COLLATE latin1_general_cs_ai
	     OR CAST(A.sintomas AS VARCHAR(500)) LIKE '%[^A-Z, ]%')
 GROUP BY A.sintomas

UNION ALL

SELECT 'Outros_Sintomas' AS Atributo, A.outrosSintomas AS Valor, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.outrosSintomas <> ''
    AND (CAST(A.outrosSintomas AS VARCHAR(2000)) LIKE '%[0-9]%'
         OR A.outrosSintomas <> CAST(A.outrosSintomas AS VARCHAR(2000)) COLLATE sql_latin1_general_cp1251_ci_as
	     OR UPPER(A.outrosSintomas) <> A.outrosSintomas COLLATE latin1_general_cs_ai
	     OR CAST(A.outrosSintomas AS VARCHAR(2000)) LIKE '%[^A-Z, ]%')
 GROUP BY A.outrosSintomas

UNION ALL

SELECT 'Municipio' AS Atributo, A.municipio AS Valor, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.municipio <> ''
    AND (CAST(A.municipio AS VARCHAR(200)) LIKE '%[0-9]%'
         OR A.municipio <> CAST(A.municipio AS VARCHAR(200)) COLLATE sql_latin1_general_cp1251_ci_as
	     OR UPPER(A.municipio) <> A.municipio COLLATE latin1_general_cs_ai
	     OR CAST(A.municipio AS VARCHAR(200)) LIKE '%[^A-Z ]%')
  GROUP BY A.municipio

UNION ALL

SELECT 'Profissional_Saude' AS Atributo, A.profissionalSaude AS Valor, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.profissionalSaude <> ''
    AND (CAST(A.profissionalSaude AS VARCHAR(50)) LIKE '%[0-9]%'
         OR A.profissionalSaude <> CAST(A.profissionalSaude AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as
	     OR UPPER(A.profissionalSaude) <> A.profissionalSaude COLLATE latin1_general_cs_ai
	     OR CAST(A.profissionalSaude AS VARCHAR(50)) LIKE '%[^A-Z ]%')
  GROUP BY A.profissionalSaude

UNION ALL

SELECT 'Raca_Cor' AS Atributo, A.racaCor AS Valor, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.racaCor <> ''
    AND (CAST(A.racaCor AS VARCHAR(50)) LIKE '%[0-9]%'
         OR A.racaCor <> CAST(A.racaCor AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as
	     OR UPPER(A.racaCor) <> A.racaCor COLLATE latin1_general_cs_ai
	     OR CAST(A.racaCor AS VARCHAR(50)) LIKE '%[^A-Z ]%')
  GROUP BY A.racaCor

UNION ALL

SELECT 'Gênero' AS Atributo, A.sexo AS Valor, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.sexo <> ''
    AND (CAST(A.sexo AS VARCHAR(50)) LIKE '%[0-9]%'
         OR A.sexo <> CAST(A.sexo AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as
         OR UPPER(A.sexo) <> A.sexo COLLATE latin1_general_cs_ai
	     OR CAST(A.sexo AS VARCHAR(50)) LIKE '%[^A-Z ]%'
         OR A.sexo NOT IN ('MASCULINO','FEMININO','INDEFINIDO'))
  GROUP BY A.sexo

UNION ALL

SELECT 'UF' AS Atributo, A.uf AS Valor, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.uf <> ''
    AND (CAST(A.uf AS VARCHAR(50)) LIKE '%[0-9]%'
         OR A.uf <> CAST(A.uf AS VARCHAR(50)) COLLATE sql_latin1_general_cp1251_ci_as
	     OR UPPER(A.uf) <> A.uf COLLATE latin1_general_cs_ai
	     OR CAST(A.uf AS VARCHAR(50)) LIKE '%[^A-Z ]%'
         OR NOT EXISTS (SELECT 1 FROM Producao..BASE_UF B
	                     WHERE B.UF = A.UF))
  GROUP BY A.UF

UNION ALL

SELECT 'Laboratorio_PrimeiraDose' AS Atributo, A.codigoLaboratorioPrimeiraDose AS Valor, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioPrimeiraDose <> ''
    AND (CAST(A.codigoLaboratorioPrimeiraDose AS VARCHAR(100)) LIKE '%[0-9]%'
         OR A.codigoLaboratorioPrimeiraDose <> CAST(A.codigoLaboratorioPrimeiraDose AS VARCHAR(100)) COLLATE sql_latin1_general_cp1251_ci_as
	     OR UPPER(A.codigoLaboratorioPrimeiraDose) <> A.codigoLaboratorioPrimeiraDose COLLATE latin1_general_cs_ai
	     OR CAST(A.codigoLaboratorioPrimeiraDose AS VARCHAR(100)) LIKE '%[^A-Z/ ]%'
         OR A.codigoLaboratorioPrimeiraDose NOT IN ('ASTRAZENECA/FIOCRUZ','JANSSEN','SINOVAC/BUTANTAN','PFIZER'))
  GROUP BY A.codigoLaboratorioPrimeiraDose

UNION ALL

SELECT 'Laboratorio_SegundaDose' AS Atributo, A.codigoLaboratorioSegundaDose AS Valor, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.codigoLaboratorioSegundaDose <> ''
    AND (CAST(A.codigoLaboratorioSegundaDose AS VARCHAR(100)) LIKE '%[0-9]%'
         OR A.codigoLaboratorioSegundaDose <> CAST(A.codigoLaboratorioSegundaDose AS VARCHAR(100)) COLLATE sql_latin1_general_cp1251_ci_as
	     OR UPPER(A.codigoLaboratorioSegundaDose) <> A.codigoLaboratorioSegundaDose COLLATE latin1_general_cs_ai
	     OR CAST(A.codigoLaboratorioSegundaDose AS VARCHAR(100)) LIKE '%[^A-Z/ ]%'
         OR A.codigoLaboratorioSegundaDose NOT IN ('ASTRAZENECA/FIOCRUZ','JANSSEN','SINOVAC/BUTANTAN','PFIZER'))
  GROUP BY A.codigoLaboratorioSegundaDose

)X

CREATE TABLE Producao..BASE_COVID_F_INT(Atributo VARCHAR(50), Nulos_Brancos int, 
        Contem_Caracteres int, Valores_N_Definidos int, Padronizado int, Total int, Total_N_Nulo int)

INSERT INTO Producao..BASE_COVID_F_INT(Atributo, Nulos_Brancos, Contem_Caracteres, 
            Valores_N_Definidos, Padronizado, Total, Total_N_Nulo) VALUES

('Idade',

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.idade = ''),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.idade <> ''
    AND CAST(A.idade AS VARCHAR(500)) NOT LIKE '%[0-9]%'),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.idade <> ''
    AND CAST(A.idade AS int) > 122),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.idade <> ''
   AND CAST(A.idade AS VARCHAR(500)) LIKE '%[0-9]%'
   AND CAST(A.idade AS int) <= 122),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A),

(SELECT COUNT(*)
   FROM Producao..BASE_COVID A
  WHERE A.idade <> ''))


SELECT X.*
INTO Producao..BASE_COVID_F_INT_CASOS
FROM
(
 SELECT A.idade AS Idade, COUNT(*) AS Qtd_Registros
   FROM Producao..BASE_COVID A
  WHERE A.idade <> ''
    AND (CAST(A.idade AS VARCHAR(500)) NOT LIKE '%[0-9]%'
         OR CAST(A.idade AS int) > 122)
 GROUP BY A.idade)X

 SELECT * INTO Producao..BASE_COVID_ASSINTOMATICOS
   FROM (

 SELECT 'Data Válida' AS Data_InicioSintomas, COUNT(*) AS Qtde_CPFs
  FROM Producao..BASE_COVID A
 WHERE A.sintomas = 'Assintomático' --830
   AND A.dataInicioSintomas <> '' 

UNION ALL

 SELECT 'Data Inexistente' AS Data_InicioSintomas, COUNT(*) AS Qtde_CPFs
  FROM Producao..BASE_COVID A
 WHERE A.sintomas = 'Assintomático' --830
   AND A.dataInicioSintomas = '')X

SELECT A.dataNotificacao, A.dataInicioSintomas
  INTO Producao..BASE_COVID_NOTIFICACAO_X_SINTOMA
  FROM Producao..BASE_COVID A
 WHERE A.dataNotificacao <> ''
   AND A.dataInicioSintomas <> ''
   AND A.dataNotificacao < A.dataInicioSintomas
   AND A.dataInicioSintomas BETWEEN '2020-01-04' AND '2022-07-22'
   AND A.dataNotificacao BETWEEN '2020-01-04' AND '2022-07-22'

SELECT dataPrimeiraDose AS Data_PrimeiraDose,
       codigoLaboratorioPrimeiraDose AS Laboratório_PrimeiraDose,
	   COUNT(*) AS Qtd_Registros INTO Producao..BASE_COVID_PDOSE
  FROM Producao..BASE_COVID A
 WHERE A.dataPrimeiraDose = ''
   AND A.codigoLaboratorioPrimeiraDose <> '' --5
 GROUP BY dataPrimeiraDose, codigoLaboratorioPrimeiraDose

 SELECT * INTO Producao..BASE_COVID_SEGUNDADOSE
   FROM (

 SELECT 'Laboratório Válido' AS Lab, COUNT(*) AS Qtde_CPFs
  FROM Producao..BASE_COVID A
 WHERE A.dataSegundaDose = ''
  AND A.codigoLaboratorioSegundaDose <> ''

UNION ALL

SELECT 'Laboratório Nulo' AS Lab, COUNT(*) AS Qtde_CPFs
  FROM Producao..BASE_COVID A
 WHERE A.dataSegundaDose = ''
  AND A.codigoLaboratorioSegundaDose = '')X
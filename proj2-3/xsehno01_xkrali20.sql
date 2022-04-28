-- Zadanie: 26. Banka
-- Autor: Patrik Sehnoutek (xsehno01), Dalibor Králik (xkrali20)

DROP TABLE PRIKAZ CASCADE CONSTRAINTS;
DROP TABLE VYPIS CASCADE CONSTRAINTS;
DROP TABLE SPRAVUJE CASCADE CONSTRAINTS;
DROP TABLE ZAMESTNANEC CASCADE CONSTRAINTS;
DROP TABLE DISPONUJE CASCADE CONSTRAINTS;
DROP TABLE UCET CASCADE CONSTRAINTS;
DROP TABLE KLIENT CASCADE CONSTRAINTS;


CREATE TABLE KLIENT(
    ID_klient INTEGER GENERATED AS IDENTITY NOT NULL,
    meno VARCHAR(40),
    priezvisko VARCHAR(40),
    ulica VARCHAR(255),
    mesto VARCHAR(255),
    email VARCHAR(255),
    telefon VARCHAR(9) CHECK(REGEXP_LIKE(telefon, '^[0-9]{9}$')),
    rodne_cislo VARCHAR(11),
    datum_narodenia DATE NOT NULL,

    CONSTRAINT PK_ID_klient PRIMARY KEY (ID_klient)
);

CREATE TABLE UCET (
    c_uctu VARCHAR(15) NOT NULL,
    datum_zalozenia DATE NOT NULL,
    zostatok DECIMAL(20, 2) DEFAULT 0,
    IBAN VARCHAR(24) CHECK(REGEXP_LIKE(IBAN, '^[A-Z]{2}[0-9]{22}$')),
    urok DECIMAL(6, 3),
    poplatok DECIMAL(10, 3),
    ID_klient INTEGER NOT NULL,
    CONSTRAINT typ_uctu CHECK (
        ((urok is NULL) and (poplatok is not NULL) or
        (urok is not NULL) and (poplatok is NULL))
        ),

    CONSTRAINT c_uctu_valid CHECK (
        REGEXP_LIKE(c_uctu, '^\d{10}/\d{4}$') and MOD(
            (
            6 * CAST(SUBSTR(c_uctu, 1, 1) AS INTEGER) +
            3 * CAST(SUBSTR(c_uctu, 2, 1) AS INTEGER) +
            7 * CAST(SUBSTR(c_uctu, 3, 1) AS INTEGER) +
            9 * CAST(SUBSTR(c_uctu, 4, 1) AS INTEGER) +
            10 * CAST(SUBSTR(c_uctu, 5, 1) AS INTEGER) +
            5 * CAST(SUBSTR(c_uctu, 6, 1) AS INTEGER) +
            8 * CAST(SUBSTR(c_uctu, 7, 1) AS INTEGER) +
            4 * CAST(SUBSTR(c_uctu, 8, 1) AS INTEGER) +
            2 * CAST(SUBSTR(c_uctu, 9, 1) AS INTEGER) +
            1 * CAST(SUBSTR(c_uctu, 10, 1) AS INTEGER)
            ), 11) = 0
    ),

    CONSTRAINT PK_c_uctu PRIMARY KEY (c_uctu),
    CONSTRAINT FK_ID_klient FOREIGN KEY (ID_klient) REFERENCES KLIENT
);

CREATE TABLE DISPONUJE(
    c_uctu VARCHAR(15) NOT NULL,
    ID_klient INTEGER NOT NULL,
    limit DECIMAL(20, 2) DEFAULT 0,

    CONSTRAINT FK_c_uctu_disponent FOREIGN KEY (c_uctu) REFERENCES UCET,
    CONSTRAINT FK_ID_disponent FOREIGN KEY (ID_klient) REFERENCES KLIENT,
    CONSTRAINT PK_disponuje PRIMARY KEY (c_uctu, ID_klient)
);

CREATE TABLE ZAMESTNANEC(
    ID_zamestanec INTEGER GENERATED AS IDENTITY NOT NULL,
    meno VARCHAR(40),
    priezvisko VARCHAR(40),
    ulica VARCHAR(255),
    mesto VARCHAR(255),
    email VARCHAR(255),
    telefon VARCHAR(9), CHECK(REGEXP_LIKE(telefon, '^[0-9]{9}$')),
    rodne_cislo VARCHAR(11),
    datum_narodenia DATE NOT NULL,

    CONSTRAINT PK_ID_zamestnanec PRIMARY KEY (ID_zamestanec)
);

CREATE TABLE SPRAVUJE (
    ID_zamestnanec INTEGER NOT NULL,
    c_uctu VARCHAR(15) NOT NULL,

    CONSTRAINT FK_ID_zamestnanec FOREIGN KEY (ID_zamestnanec) REFERENCES ZAMESTNANEC,
    CONSTRAINT FK_c_uctu FOREIGN KEY (c_uctu) REFERENCES UCET,
    CONSTRAINT PK_spravuje PRIMARY KEY (ID_zamestnanec, c_uctu)
);

CREATE TABLE VYPIS (
    poradove_cislo INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    datum_zalozenia DATE NOT NULL,
    c_uctu VARCHAR(15) NOT NULL,

    CONSTRAINT PK_poradove_cislo_vypis PRIMARY KEY (poradove_cislo, c_uctu),
    CONSTRAINT FK_c_uctu_vypis FOREIGN KEY (c_uctu) REFERENCES UCET
);

CREATE TABLE PRIKAZ(
    poradove_cislo INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    datum DATE NOT NULL,
    ciastka DECIMAL(20, 2),
    typ VARCHAR(6) CHECK(typ IN ('vklad', 'vyber', 'prevod', 'inkaso', 'platba')),
    c_uctu VARCHAR(15) NOT NULL,

    CONSTRAINT PK_poradove_cislo_prikaz PRIMARY KEY (poradove_cislo, c_uctu),
    CONSTRAINT FK_c_uctu_prikaz FOREIGN KEY (c_uctu) REFERENCES UCET
);

--Triggers
/*
 Trigger sa zavolá pred vložením alebo updatom zostatku v tabulke UCET.
 Zmení úrok na sporiacom účte, ak ma uživatel na tomto účte zostatok vacsi ako 99999.
 */
CREATE OR REPLACE TRIGGER ZMENA_UROKU
    BEFORE INSERT OR UPDATE OF zostatok ON UCET
    FOR EACH ROW
    BEGIN
        IF :NEW.urok IS NOT NULL AND :NEW.zostatok < 100000 THEN

            :NEW.urok:= 0.5;
        ELSIF :NEW.urok IS NOT NULL THEN
            :NEW.urok := 1.225;
        end if;
    END;
/

/*
 Trigger, ktorý sa zavolá pred vkladaním alebo updatom rodného čísla,
 do ktoreho sa v prípade chýbajúceho lomitka / toto lomitko vloží pre zachovanie správneho a očakávaného formátu rodného čísla
 */
CREATE OR REPLACE TRIGGER ZMENA_FORMATU_RODNEHO_CISLA
    BEFORE INSERT OR UPDATE OF rodne_cislo  ON KLIENT
    FOR EACH ROW
    declare
        position Integer;

    BEGIN
        position := INSTR(:NEW.rodne_cislo, '/');
        IF position IS NULL OR position = 0 then
           :NEW.rodne_cislo := substr(:NEW.rodne_cislo,1,6) || '/' || substr(:NEW.rodne_cislo,7,4);

        end if;
    END;
/


-- Proj2 - vlozenie vzorovych dat

-- Klienti
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Patrik', 'Sehnoutek', 'Purkynova', 'Brno', 'patrik@gmail.com', '774589123', '040503/0010', TO_DATE('2004-05-03', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Dalibor', 'Kralik', 'Purkynova', 'Brno', 'dalibor@gmail.com', '456253124', '030201/0016', TO_DATE('2003-02-01', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Jan', 'Novak', 'Staromestska', 'Praha', 'jan@centrum.cz', '445322564', '011210/3356', TO_DATE('2001-12-10', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Anna', 'Novakova', 'Staromestska', 'Praha', 'anna@gmail.com', '987562365', '0257073366', TO_DATE('2002-07-07', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Stefan', 'Eiselle', 'Smitkeho', 'Nemsova', 'eisellestefan@gmail.com', '771119123', '040111/0010', TO_DATE('2002-05-03', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Maros', 'Karci', 'Purkynova', 'Brno', 'karcimaros@gmail.com', '111253124', '0202010016', TO_DATE('2004-04-29', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Jan', 'Sekino', 'Staromestska', 'Praha', 'jansekino@centrum.cz', '445344564', '0112053356', TO_DATE('2005-12-10', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Anna', 'Nova', 'Staromestska', 'Olomouc', 'annamaria@gmail.com', '987562317', '025717/3366', TO_DATE('2005-07-07', 'YYYY-MM-DD'));

-- Zamestnanci
INSERT INTO ZAMESTNANEC( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Vladimir', 'Stary', 'Nadrazni', 'Brno', 'vladimir@banka.cz', '058695245', '846014/1008', TO_DATE('1984-10-14', 'YYYY-MM-DD'));
INSERT INTO ZAMESTNANEC( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Alena', 'Nova', 'Purkynova', 'Brno', 'alena@banka.cz', '062154783', '936105/2569', TO_DATE('1993-11-05', 'YYYY-MM-DD'));
INSERT INTO ZAMESTNANEC( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Igor', 'Pekny', 'Veveri', 'Brno', 'igorko@banka.cz', '458655245', '866014/1008', TO_DATE('1986-10-14', 'YYYY-MM-DD'));
INSERT INTO ZAMESTNANEC( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Majka', 'Vysoka', 'Purkynova', 'Brno', 'majka@banka.cz', '362116783', '926105/2569', TO_DATE('1992-11-05', 'YYYY-MM-DD'));

-- Účty
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES('1234567901/0300', TO_DATE('2020-05-03', 'YYYY-MM-DD'), 100.40, 'SK1000000000000025698745', 1.225, NULL, 1);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES('1234567928/0300', TO_DATE('2020-06-07', 'YYYY-MM-DD'), 2895.56, 'SK1000000000000025698746', NULL, 20.4, 1);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES('1234567936/0300', TO_DATE('2019-07-10', 'YYYY-MM-DD'), 4000.40, 'SK2000000000000078611745', NULL, 7.25, 2);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES('1234567944/0300', TO_DATE('2020-05-03', 'YYYY-MM-DD'), 100030.40, 'SK1000000000000044698745', 1.225, NULL, 4);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES('1234567952/0300', TO_DATE('2020-06-07', 'YYYY-MM-DD'), 22895.56, 'SK1000000000000055698746', 0.23, NULL, 3);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES('1234567960/0300', TO_DATE('2019-07-10', 'YYYY-MM-DD'), 14000.40, 'SK2000000000000079611745', NULL, 10.25, 5);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES('1234567979/0300', TO_DATE('2020-05-03', 'YYYY-MM-DD'), 130.40, 'SK1000000000000044698745', 1.2, NULL, 7);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES('1234567987/0300', TO_DATE('2020-06-07', 'YYYY-MM-DD'), 2295.56, 'SK1000000000000055698746', 0.65, NULL, 8);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES('1234567995/0300', TO_DATE('2019-07-10', 'YYYY-MM-DD'), 4000.40, 'SK2000000000000079611745', NULL, 10.5, 6);

-- Disponuje
INSERT INTO DISPONUJE(c_uctu, ID_klient, limit)
VALUES ('1234567901/0300', 3, 1000);
INSERT INTO DISPONUJE(c_uctu, ID_klient, limit)
VALUES ('1234567952/0300', 3, 500);
INSERT INTO DISPONUJE(c_uctu, ID_klient, limit)
VALUES ('1234567987/0300', 4, 200);
INSERT INTO DISPONUJE(c_uctu, ID_klient, limit)
VALUES ('1234567901/0300', 6, 500);
INSERT INTO DISPONUJE(c_uctu, ID_klient, limit)
VALUES ('1234567995/0300', 7, 200);
INSERT INTO DISPONUJE(c_uctu, ID_klient, limit)
VALUES ('1234567995/0300', 6, 400);

-- Spravuje
INSERT INTO SPRAVUJE(ID_zamestnanec, c_uctu)
VALUES(1, '1234567960/0300');
INSERT INTO SPRAVUJE(ID_zamestnanec, c_uctu)
VALUES(1, '1234567979/0300');
INSERT INTO SPRAVUJE(ID_zamestnanec, c_uctu)
VALUES(2, '1234567952/0300');
INSERT INTO SPRAVUJE(ID_zamestnanec, c_uctu)
VALUES(3, '1234567987/0300');
INSERT INTO SPRAVUJE(ID_zamestnanec, c_uctu)
VALUES(4, '1234567901/0300');
INSERT INTO SPRAVUJE(ID_zamestnanec, c_uctu)
VALUES(4, '1234567995/0300');

-- Výpisy
INSERT INTO VYPIS(datum_zalozenia, c_uctu)
VALUES(TO_DATE('2021-01-11', 'YYYY-MM-DD'), '1234567952/0300');
INSERT INTO VYPIS(datum_zalozenia, c_uctu)
VALUES(TO_DATE('2022-02-02', 'YYYY-MM-DD'), '1234567979/0300');
INSERT INTO VYPIS(datum_zalozenia, c_uctu)
VALUES(TO_DATE('2021-01-11', 'YYYY-MM-DD'), '1234567995/0300');
INSERT INTO VYPIS(datum_zalozenia, c_uctu)
VALUES(TO_DATE('2022-02-03', 'YYYY-MM-DD'), '1234567987/0300');

-- Príkazy
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2021-01-10', 'YYYY-MM-DD'), 10.5, 'vyber', '1234567987/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2021-01-10', 'YYYY-MM-DD'), 10.7, 'vyber', '1234567987/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-03-27', 'YYYY-MM-DD'), 1000, 'vklad', '1234567987/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-01-31', 'YYYY-MM-DD'), 250.50, 'platba', '1234567995/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-02-01', 'YYYY-MM-DD'), 40.78, 'inkaso', '1234567995/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2021-01-11', 'YYYY-MM-DD'), 10.5, 'prevod', '1234567979/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-03-28', 'YYYY-MM-DD'), 1060, 'vklad', '1234567979/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-01-03', 'YYYY-MM-DD'), 252.50, 'platba', '1234567952/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-02-05', 'YYYY-MM-DD'), 400.78, 'prevod', '1234567952/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2021-01-15', 'YYYY-MM-DD'), 104.5, 'vyber', '1234567936/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-03-22', 'YYYY-MM-DD'), 140, 'vklad', '1234567936/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-01-30', 'YYYY-MM-DD'), 20.50, 'vklad', '1234567944/0300');
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-02-09', 'YYYY-MM-DD'), 400.78, 'platba', '1234567944/0300');


-- Projekt č.3

-- Počet účtov, ktoré spravujú jednotliví zamestnanci
SELECT meno, priezvisko, COUNT(*)
FROM ZAMESTNANEC NATURAL JOIN SPRAVUJE
GROUP BY meno, priezvisko;

-- Ktorí klienti vytvorili príkaz s hodnotou minimánle 500€
SELECT meno, priezvisko
FROM KLIENT
WHERE ID_klient IN
    (SELECT ID_klient FROM UCET
        WHERE c_uctu IN
        (SELECT c_uctu FROM PRIKAZ
            WHERE ciastka >= 500));

-- Ktorí klienti a na akom účte vytvorili výpis z účtu za obdobie 1.2.2022 - 31.3.2022
SELECT meno, priezvisko, c_uctu
FROM KLIENT NATURAL JOIN UCET JOIN VYPIS V using(c_uctu)
WHERE V.datum_zalozenia BETWEEN TO_DATE('2022-02-01', 'YYYY-MM-DD') AND TO_DATE('2022-03-31', 'YYYY-MM-DD');

-- Ktorí klienti sú vlastníkmi sporiaceho aj bežného účtu
SELECT K.meno, K.priezvisko
FROM KLIENT K, UCET U
WHERE K.ID_klient=U.ID_klient AND urok IS NOT NULL
      AND EXISTS(SELECT *
          FROM UCET U
          WHERE K.ID_klient=U.ID_klient AND
                U.poplatok IS NOT NULL);

-- Jednotliví klienti a suma, ktorou disponujú na všetkých účtoch,
-- zoradení od najväčšieho limitu po najmenší
SELECT meno, priezvisko, SUM(limit) celkovy_limit
FROM KLIENT join DISPONUJE USING(ID_klient)
GROUP BY meno, priezvisko
ORDER BY celkovy_limit DESC;

-- Výpis klientov, ktorí majú sporiaci účet
SELECT meno, priezvisko
FROM KLIENT NATURAL JOIN UCET
WHERE urok IS NOT NULL;

--Výpis zamestnancov, ktorí spravovali uz bežný účet
SELECT DISTINCT meno, priezvisko
FROM ZAMESTNANEC NATURAL JOIN UCET
WHERE poplatok IS NOT NULL;


-- Projekt č.4 -- práva pre druhého člena

GRANT ALL ON PRIKAZ TO XKRALI20;
GRANT ALL ON VYPIS TO XKRALI20;
GRANT ALL ON SPRAVUJE TO XKRALI20;
GRANT ALL ON ZAMESTNANEC TO XKRALI20;
GRANT ALL ON DISPONUJE TO XKRALI20;
GRANT ALL ON UCET TO XKRALI20;
GRANT ALL ON KLIENT TO XKRALI20;


--Materialized view
DROP MATERIALIZED VIEW POCET_UCTOV_KLIENTA;

CREATE MATERIALIZED VIEW POCET_UCTOV_KLIENTA
REFRESH ON COMMIT AS
    SELECT ID_klient, COUNT(c_uctu) Pocet_uctov
    FROM XSEHNO01.KLIENT NATURAL JOIN UCET
    GROUP BY ID_klient;


SELECT * FROM UCET;

SELECT * FROM KLIENT;

-- Vypis klienta, čísla účtu, počtu príkazov, ktoré boli vykonané nad učtami klienta a suma čiastok prikazov.
-- First run without indexes
EXPLAIN PLAN FOR
SELECT ID_klient, meno, priezvisko, c_uctu, count(*), sum(ciastka)
FROM KLIENT natural join UCET join PRIKAZ using(c_uctu)
GROUP BY ID_klient, meno, priezvisko, c_uctu;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);

DROP INDEX KLIENT_INDEX;
DROP INDEX UCET_INDEX;


CREATE INDEX KLIENT_INDEX on KLIENT(ID_klient, meno, priezvisko);
CREATE INDEX UCET_INDEX on UCET(ID_klient, c_uctu);


--Second run with indexes
EXPLAIN PLAN FOR
SELECT ID_klient, meno, priezvisko, c_uctu, count(*), sum(ciastka)
FROM KLIENT natural join UCET join PRIKAZ using(c_uctu)
GROUP BY ID_klient, meno, priezvisko, c_uctu;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);



SET SERVEROUTPUT ON;

--Procedura počíta všetky príjmy a výdavky na danom účte
CREATE OR REPLACE PROCEDURE Transakcie_na_bankovom_ucte (cislo_uctu STRING) AS
    CURSOR prikazy_uctu is SELECT * FROM PRIKAZ WHERE c_uctu = cislo_uctu;
    riadok_kurzoru PRIKAZ%ROWTYPE;
    vydavky DECIMAL(20,2);
    prijmi DECIMAL(20,2);
    BEGIN
        vydavky := 0;
        prijmi := 0;
        OPEN prikazy_uctu;

        LOOP
            FETCH prikazy_uctu INTO riadok_kurzoru;
            EXIT WHEN prikazy_uctu%NOTFOUND;
            IF riadok_kurzoru.typ = 'vklad' THEN
                prijmi := prijmi + riadok_kurzoru.ciastka;
            ELSE
                vydavky := vydavky + riadok_kurzoru.ciastka;
            end if;

        end loop;

        CLOSE prikazy_uctu;

        DBMS_OUTPUT.PUT_LINE('Na ucte cislo ' || cislo_uctu||' boli príjmy ' || prijmi || ' a vydavky boli '||vydavky);
    EXCEPTION
        WHEN others THEN
         DBMS_OUTPUT.PUT_LINE('Error occured in Transakcie_na_bankovom_ucte procedure.');
    END;
/


-- Procedura vypíše všetkých klientov, ktorí majú dnes narodeniny => funkcia sysdate()
CREATE OR REPLACE PROCEDURE Klienti_Narodeniny AS
    CURSOR datum_narodenia is SELECT meno, priezvisko, datum_narodenia FROM KLIENT;
    menoINT KLIENT.meno%type;
    priezviskoINT KLIENT.priezvisko%type;
    datumNarodeniaINT KLIENT.datum_narodenia%type;
    dnesnyDatum KLIENT.datum_narodenia%type;
    ma_niekto_narodeniny BOOLEAN;
    BEGIN
        OPEN datum_narodenia;
            dnesnydatum := TO_DATE(sysdate,'DD-MM-YYYY');
            DBMS_OUTPUT.PUT_LINE('Dnes má narodeniny: ');
            ma_niekto_narodeniny := FALSE;
        LOOP
            FETCH datum_narodenia INTO menoINT, priezviskoINT, datumNarodeniaINT;
            EXIT WHEN datum_narodenia%NOTFOUND;
            if(substr(datumNarodeniaINT,1,5) = substr(dnesnyDatum,1,5)) then
                DBMS_OUTPUT.PUT_LINE(menoINT || ' '|| priezviskoINT);
                ma_niekto_narodeniny := TRUE;
            end if;

        end loop;
        IF ma_niekto_narodeniny = TRUE THEN
            DBMS_OUTPUT.PUT_LINE('Happy Birthday!');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Dnes nemá nikto narodeniny!');
        end if;


        CLOSE datum_narodenia;
    EXCEPTION
        WHEN others THEN
         DBMS_OUTPUT.PUT_LINE('Error occured in Klienti_Narodeniny procedure.');
    END;
/

begin
 Tranzakcie_na_bankovom_ucet('1234567987/0300');
end;
/

begin
 Klienti_Narodeniny();
end;
/
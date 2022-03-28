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
    c_uctu NUMBER NOT NULL CHECK(REGEXP_LIKE(c_uctu, '^[0-9]{6,14}$')), -- 2-10 je pre cislo uctu a 4 je pre cislo banky
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

    CONSTRAINT PK_c_uctu PRIMARY KEY (c_uctu),
    CONSTRAINT FK_ID_klient FOREIGN KEY (ID_klient) REFERENCES KLIENT
);

CREATE TABLE DISPONUJE(
    c_uctu NUMBER NOT NULL,
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
    c_uctu NUMBER NOT NULL,

    CONSTRAINT FK_ID_zamestnanec FOREIGN KEY (ID_zamestnanec) REFERENCES ZAMESTNANEC,
    CONSTRAINT FK_c_uctu FOREIGN KEY (c_uctu) REFERENCES UCET,
    CONSTRAINT PK_spravuje PRIMARY KEY (ID_zamestnanec, c_uctu)
);

CREATE TABLE VYPIS (
    poradove_cislo INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    datum_zalozenia DATE NOT NULL,
    c_uctu NUMBER NOT NULL,

    CONSTRAINT PK_poradove_cislo_vypis PRIMARY KEY (poradove_cislo, c_uctu),
    CONSTRAINT FK_c_uctu_vypis FOREIGN KEY (c_uctu) REFERENCES UCET
);

CREATE TABLE PRIKAZ(
    poradove_cislo INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    datum DATE NOT NULL,
    ciastka DECIMAL(20, 2),
    typ VARCHAR(6) CHECK(typ = 'vklad' or typ = 'vyber' or typ = 'prevod' or typ = 'inkaso' or typ = 'platba'),
    c_uctu NUMBER NOT NULL,

    CONSTRAINT PK_poradove_cislo_prikaz PRIMARY KEY (poradove_cislo, c_uctu),
    CONSTRAINT FK_c_uctu_prikaz FOREIGN KEY (c_uctu) REFERENCES UCET
);

-- Proj2 - vlozenie vzorovych dat

-- Klienti
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Patrik', 'Sehnoutek', 'Purkynova', 'Brno', 'patrik@gmail.com', '774589123', '040503/0010', TO_DATE('2004-05-03', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Dalibor', 'Kralik', 'Purkynova', 'Brno', 'dalibor@gmail.com', '456253124', '030201/0016', TO_DATE('2003-02-01', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Jan', 'Novak', 'Staromestska', 'Praha', 'jan@centrum.cz', '445322564', '011210/3356', TO_DATE('2001-12-10', 'YYYY-MM-DD'));
INSERT INTO KLIENT( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Anna', 'Novakova', 'Staromestska', 'Praha', 'anna@gmail.com', '987562365', '025707/3366', TO_DATE('2002-07-07', 'YYYY-MM-DD'));

-- Zamestnanci
INSERT INTO ZAMESTNANEC( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Vladimir', 'Stary', 'Nadrazni', 'Brno', 'vladimir@banka.cz', '458695245', '846014/1008', TO_DATE('1984-10-14', 'YYYY-MM-DD'));
INSERT INTO ZAMESTNANEC( meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('Alena', 'Nova', 'Purkynova', 'Brno', 'alena@banka.cz', '362154783', '936105/2569', TO_DATE('1993-11-05', 'YYYY-MM-DD'));

-- Účty
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES(114400, TO_DATE('2020-05-03', 'YYYY-MM-DD'), 100.40, 'SK1000000000000025698745', 1.225, NULL, 1);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES(224400, TO_DATE('2020-06-07', 'YYYY-MM-DD'), 2895.56, 'SK1000000000000025698746', NULL, 20.4, 1);
INSERT INTO UCET(c_uctu, datum_zalozenia, zostatok, IBAN, urok, poplatok, ID_klient)
VALUES(334400, TO_DATE('2019-07-10', 'YYYY-MM-DD'), 4000.40, 'SK2000000000000078611745', NULL, 7.25, 2);

-- Disponuje
INSERT INTO DISPONUJE(c_uctu, ID_klient, limit)
VALUES (224400, 3, 1000);
INSERT INTO DISPONUJE(c_uctu, ID_klient, limit)
VALUES (334400, 3, 500);
INSERT INTO DISPONUJE(c_uctu, ID_klient, limit)
VALUES (334400, 4, 200);

-- Spravuje
INSERT INTO SPRAVUJE(ID_zamestnanec, c_uctu)
VALUES(1, 224400);
INSERT INTO SPRAVUJE(ID_zamestnanec, c_uctu)
VALUES(1, 334400);
INSERT INTO SPRAVUJE(ID_zamestnanec, c_uctu)
VALUES(2, 114400);

-- Výpisy
INSERT INTO VYPIS(datum_zalozenia, c_uctu)
VALUES(TO_DATE('2021-01-11', 'YYYY-MM-DD'), 114400);
INSERT INTO VYPIS(datum_zalozenia, c_uctu)
VALUES(TO_DATE('2022-02-02', 'YYYY-MM-DD'), 334400);

-- Príkazy
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2021-01-10', 'YYYY-MM-DD'), 10.5, 'vyber', 224400);
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-03-27', 'YYYY-MM-DD'), 1000, 'vklad', 334400);
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-01-31', 'YYYY-MM-DD'), 250.50, 'platba', 334400);
INSERT INTO PRIKAZ(datum, ciastka, typ, c_uctu)
VALUES(TO_DATE('2022-02-01', 'YYYY-MM-DD'), 40.78, 'platba', 334400);
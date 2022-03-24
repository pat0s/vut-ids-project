-- Zadanie: 26. Banka
-- Autor: Patrik Sehnoutek (xsehno01), Dalibor Králik (xkrali20)

DROP TABLE VYPIS CASCADE CONSTRAINTS;
DROP TABLE PRIKAZ CASCADE CONSTRAINTS;
DROP TABLE ZAMESTNANEC CASCADE CONSTRAINTS;
DROP TABLE UCET CASCADE CONSTRAINTS;
DROP TABLE SPRAVUJE CASCADE CONSTRAINTS;
DROP TABLE KLIENT CASCADE CONSTRAINTS;
DROP TABLE DISPONUJE CASCADE CONSTRAINTS;

-- TODO: osetrenie rodneho cisla a zmena dlzky
-- TODO: podrobnejsie osetrenie IBAN-u

CREATE TABLE KLIENT(
    ID_klient INTEGER NOT NULL,
    meno VARCHAR(30),04
    priezvisko VARCHAR(30),
    ulica VARCHAR(255),
    mesto VARCHAR(255),
    email VARCHAR(50),
    telefon VARCHAR(9), CHECK(REGEXP_LIKE(telefon, '^[0-9]{9}$')),
    rodne_cislo VARCHAR(11),
    datum_narodenia DATE,

    CONSTRAINT PK_ID_klient PRIMARY KEY
)

CREATE TABLE UCET (
    c_uctu NUMBER NOT NULL,
    datum_zalozenia DATE NOT NULL,
    zostatok DECIMAL(20,2) DEFAULT 0,
    IBAN VARCHAR(24) CHECK(REGEXP_LIKE(IBAN, '^[A-Z]{2}[0-9]{22}$')),
    urok DECIMAL(6, 3),
    poplatok DECIMAL(10,3),
    ID_klient INTEGER NOT NULL,
    CHECK (
        ((urok == NULL) and (poplatok != NULL) or
        (urok != NULL) and (poplatok == NULL))
        ),

    CONSTRAINT PK_c_uctu PRIMARY KEY (c_uctu),
    CONSTRAINT FK_ID_klient FOREIGN KEY (ID_klient) REFERENCES KLIENT
);

CREATE TABLE DISPONUJE(
    c_uctu NUMBER NOT NULL,
    ID_klient INTEGER NOT NULL,
    LIMIT DECIMAL(20,2) DEFAULT 0,

    CONSTRAINT FK_c_uctu_disponent FOREIGN KEY (c_uctu) REFERENCES UCET,
    CONSTRAINT FK_ID_disponent FOREIGN KEY (ID_klient) REFERENCES KLIENT,
    CONSTRAINT PK_disponuje PRIMARY KEY (c_uctu, ID_klient)
)

CREATE TABLE ZAMESTNANEC(
    ID_zamestanec INTEGER NOT NULL,
    meno VARCHAR(30),
    priezvisko VARCHAR(30),
    ulica VARCHAR(255),
    mesto VARCHAR(255),
    email VARCHAR(50),
    telefon VARCHAR(9), CHECK(REGEXP_LIKE(telefon, '^[0-9]{9}$')),
    rodne_cislo VARCHAR(11),
    datum_narodenia DATE,

    CONSTRAINT PK_ID_zamestnanec PRIMARY KEY
)

CREATE TABLE SPRAVUJE (
    ID_zamestnanec INTEGER NOT NULL,
    c_uctu NUMBER NOT NULL,

    CONSTRAINT FK_ID_zamestnanec FOREIGN KEY (ID_zamestnanec) REFERENCES ZAMESTNANEC,
    CONSTRAINT FK_c_uctu FOREIGN KEY (c_uctu) REFERENCES UCET,
    CONSTRAINT PK_spravuje PRIMARY KEY (ID_zamestnanec, c_uctu)
)

CREATE TABLE VYPIS (
    poradove_cislo INTEGER NOT NULL,
    datum_zalozenia DATE NOT NULL,
    c_uctu NUMBER NOT NULL,

    CONSTRAINT PK_poradove_cislo_vypis PRIMARY KEY (poradove_cislo, c_uctu),
    CONSTRAINT FK_c_uctu_vypis FOREIGN KEY (cislo) REFERENCES UCET
);

CREATE TABLE PRIKAZ(
    poradove_cislo INTEGER NOT NULL,
    datum DATE NOT NULL,
    ciastka DECIMAL(20, 2),
    typ VARCHAR(50),
    c_uctu NUMBER NOT NULL,

    CONSTRAINT PK_poradove_cislo_prikaz PRIMARY KEY (poradove_cislo, c_uctu),
    CONSTRAINT FK_c_uctu_prikaz FOREIGN KEY (cislo) REFERENCES UCET
);

-- Proj2 - vlozenie vzorovych dat

-- TODO: zmenit hodnoty, ak budeme pridavat nejake osetrenia
INSERT INTO KLIENT(ID_klient, meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('123456789', 'Patrik', 'Sehnoutek', 'Purkynova', 'Brno', 'patrik@gmail.com', '774589123', '040503/0010', TO_DATE('2004-05-03', 'YYYY-MM-DD'));
INSERT INTO KLIENT(ID_klient, meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('987654321', 'Dalibor', 'Kralik', 'Purkynova', 'Brno', 'dalibor@gmail.com', '4562563124', '030201/0016', TO_DATE('2003-02-01', 'YYYY-MM-DD'));
INSERT INTO KLIENT(ID_klient, meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('11122233', 'Jan', 'Novak', 'Staromestska', 'Praha', 'jan@centrum.cz', '445322564', '011210/3356', TO_DATE('2001-12-10', 'YYYY-MM-DD'));
INSERT INTO KLIENT(ID_klient, meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('444555666', 'Anna', 'Novakova', 'Staromestska', 'Praha', 'anna@gmail.com', '987562365', '025707/3366', TO_DATE('2002-07-07', 'YYYY-MM-DD'));

INSERT INTO ZAMESTNANEC(ID_zamestanec, meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('123456', 'Vladimir', 'Stary', 'Nadrazni', 'Brno', 'vladimir@banka.cz', '458695245', '846014/1008', TO_DATE('1984-10-14', 'YYYY-MM-DD'));
INSERT INTO ZAMESTNANEC(ID_zamestanec, meno, priezvisko, ulica, mesto, email, telefon, rodne_cislo, datum_narodenia)
VALUES('654321', 'Alena', 'Nova', 'Purkynova', 'Brno', 'alena@banka.cz', '362154783', '936105/2569', TO_DATE('1993-11-05', 'YYYY-MM-DD'));



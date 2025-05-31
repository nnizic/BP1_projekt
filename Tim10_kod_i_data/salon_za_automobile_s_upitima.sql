DROP DATABASE IF EXISTS salon_za_automobile;
CREATE DATABASE salon_za_automobile;
USE salon_za_automobile;


CREATE TABLE salon (
id INTEGER PRIMARY KEY,
naziv VARCHAR(20) NOT NULL,
adresa VARCHAR(50) NOT NULL,
kontakt_telefon CHAR(10)  NOT NULL UNIQUE,
email VARCHAR(30) NOT NULL UNIQUE,
radno_vrijeme_pocetak  TIME NOT NULL,
radno_vrijeme_kraj TIME NOT NULL,
kapacitet_izlozbenih_mjesta_unutra CHAR(3) NOT NULL,
kapacitet_izlozbenih_mjesta_vani CHAR(3) NOT NULL,
kapacitet_servisa CHAR(3) NOT NULL
);


CREATE TABLE osoba (
    id INTEGER PRIMARY KEY,
    ime VARCHAR(40),
    prezime VARCHAR(40),
    oib CHAR(11) NOT NULL UNIQUE,
    adresa VARCHAR(50) NOT NULL,
    kontakt_telefon CHAR(10) NOT NULL UNIQUE,
    email VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE zaposlenik (
    id INTEGER PRIMARY KEY,  -- FK prema osoba.id
    datum_rodenja DATE NOT NULL,
    datum_zaposlenja DATE NOT NULL,
    pozicija VARCHAR(20) NOT NULL,
    placa INTEGER NOT NULL,
    id_salona INTEGER NOT NULL,
    FOREIGN KEY (id) REFERENCES osoba(id),
    FOREIGN KEY (id_salona) REFERENCES salon(id)
);


CREATE TABLE kupac (
    id INTEGER PRIMARY KEY,  -- FK prema osoba.id
    tip_kupca VARCHAR(40) NOT NULL CHECK (tip_kupca IN ('fizicka osoba', 'pravna osoba')),
    naziv_tvrtke VARCHAR(40),
    datum_prve_kupnje DATE NOT NULL,
    kategorija_kupca VARCHAR(40) NOT NULL CHECK (kategorija_kupca IN ('standard', 'fleet', 'VIP')),
    FOREIGN KEY (id) REFERENCES osoba(id),
    CHECK (
        tip_kupca = 'pravna osoba' AND naziv_tvrtke IS NOT NULL
        OR tip_kupca = 'fizicka osoba'
    )
);


CREATE TABLE voditelj_salona (
    id_zaposlenika INTEGER PRIMARY KEY,
    id_salona INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (id_zaposlenika) REFERENCES zaposlenik(id),
    FOREIGN KEY (id_salona) REFERENCES salon(id)
);

CREATE TABLE smjena (
id INTEGER PRIMARY KEY,
naziv_smjene VARCHAR(20) NOT NULL,
vrijeme_pocetka  TIME NOT NULL,
vrijeme_zavrsetka  TIME NOT NULL,
dan_u_tjednu VARCHAR(15) NOT NULL
);

CREATE TABLE raspored_rada (
id INTEGER PRIMARY KEY,
id_zaposlenika INTEGER NOT NULL,
id_smjene INTEGER NOT NULL,
datum DATE NOT NULL,
status VARCHAR(20) NOT NULL,
FOREIGN KEY (id_zaposlenika) REFERENCES zaposlenik (id),
FOREIGN KEY (id_smjene) REFERENCES smjena (id)
);

CREATE TABLE marka_automobila (
id INTEGER PRIMARY KEY,
naziv_marke VARCHAR(20) NOT NULL,
zemlja_porijekla VARCHAR(20) NOT NULL
);

CREATE TABLE model_automobila (
id INTEGER PRIMARY KEY,
id_marke INTEGER NOT NULL,
naziv_modela VARCHAR(20) NOT NULL,
godina_pocetka_proizvodnje CHAR(4) NOT NULL,
godina_zavrsetka_proizvodnje CHAR(4),
osnovna_cijena INTEGER NOT NULL,
FOREIGN KEY (id_marke) REFERENCES marka_automobila(id)
);



-- Glavna tablica za sve automobile
CREATE TABLE automobil (
  id INTEGER PRIMARY KEY,
  VIN CHAR(17) NOT NULL UNIQUE,
  id_modela INTEGER NOT NULL,
  tip_izvedbe VARCHAR(20),
  dodatna_cijena INTEGER DEFAULT 0 CHECK (dodatna_cijena >= 0),
  godina_proizvodnje CHAR(4) NOT NULL,
  boja VARCHAR(20) NOT NULL,
  kilometraza INTEGER,
  status VARCHAR(20) NOT NULL CHECK (status IN ('dostupan', 'rezerviran', 'prodano')),
  tip_automobila VARCHAR(20) NOT NULL CHECK (tip_automobila IN ('novi', 'rabljeni')),
  datum_zaprimanja DATE NOT NULL,
  nabavna_cijena INTEGER NOT NULL CHECK (nabavna_cijena >= 0),
  RUC_postotak INTEGER NOT NULL, 
  cijena_bez_PDV INTEGER NOT NULL CHECK (cijena_bez_PDV >= 0),
  maloprodajna_cijena INTEGER NOT NULL CHECK (maloprodajna_cijena >= 0),
  id_salona INTEGER NOT NULL,
  -- Tehničke specifikacije
  snaga_motora INTEGER CHECK (snaga_motora > 0),
  zapremina_motora INTEGER CHECK (zapremina_motora > 0),
  vrsta_goriva VARCHAR(20),
  emisija_CO2 DECIMAL(5,1) CHECK (emisija_CO2 >= 0),
  prosjecna_potrosnja DECIMAL(4,1) CHECK (prosjecna_potrosnja >= 0),
  duzina INTEGER CHECK (duzina > 0),
  sirina INTEGER CHECK (sirina > 0),
  visina INTEGER CHECK (visina > 0),
  meduosovinski_razmak INTEGER CHECK (meduosovinski_razmak > 0),
  masa_praznog_vozila INTEGER CHECK (masa_praznog_vozila > 0),
  FOREIGN KEY (id_modela) REFERENCES model_automobila(id),
  FOREIGN KEY (id_salona) REFERENCES salon(id)
);

CREATE TABLE novi_automobil (
  id INTEGER PRIMARY KEY, -- FK na automobil
  za_poznatog_kupca BOOLEAN,
  klasifikacija VARCHAR(20),
  id_narudzbe INTEGER,
  FOREIGN KEY (id) REFERENCES automobil(id)
  
);

CREATE TABLE rabljeni_automobil (
  id INTEGER PRIMARY KEY, -- FK na automobil
  broj_prethodnih_vlasnika INTEGER,
  datum_prve_registracije DATE,
  servisna_knjizica BOOLEAN,
  stanje VARCHAR(20) CHECK (stanje IN ('odlicno', 'dobro', 'zadovoljavajuce', 'lose')),
  napomene VARCHAR(200),
  FOREIGN KEY (id) REFERENCES automobil(id)
);
CREATE TABLE automobil_na_servisu (
  id INTEGER PRIMARY KEY,
  id_automobila INTEGER NOT NULL,
  datum_prijema DATE NOT NULL,
  datum_povratka DATE,
  opis_kvara TEXT,
  napomena TEXT,
  status_servisa VARCHAR(20) NOT NULL CHECK (status_servisa IN ('u tijeku', 'zavrseno')),
  FOREIGN KEY (id_automobila) REFERENCES automobil(id)
);

-- Tablica paketa opreme
CREATE TABLE paket_opreme (
id INTEGER PRIMARY KEY,
naziv_paketa VARCHAR(40) NOT NULL UNIQUE,
opis VARCHAR(500) NOT NULL,
cijena_paketa INTEGER NOT NULL CHECK (cijena_paketa >= 0)
);

-- Tablica pojedinačne opreme
CREATE TABLE oprema (
id INTEGER PRIMARY KEY,
naziv_opreme VARCHAR(40) NOT NULL UNIQUE,
opis VARCHAR(500) NOT NULL,
paket_id INTEGER,  -- NULL znači slobodna oprema
FOREIGN KEY (paket_id) REFERENCES paket_opreme(id)
);


-- Povezivanje opreme i paketa (m:n veza)
CREATE TABLE oprema_u_paketu (
id_paketa INTEGER NOT NULL,
id_opreme INTEGER NOT NULL,
PRIMARY KEY (id_paketa, id_opreme),
FOREIGN KEY (id_paketa) REFERENCES paket_opreme(id) ON DELETE CASCADE,
FOREIGN KEY (id_opreme) REFERENCES oprema(id) ON DELETE CASCADE
);

CREATE TABLE oprema_automobila (
    id_automobila INTEGER NOT NULL,
    id_opreme INTEGER NOT NULL,

    PRIMARY KEY (id_automobila, id_opreme),
    FOREIGN KEY (id_automobila) REFERENCES automobil(id) ON DELETE CASCADE,
    FOREIGN KEY (id_opreme) REFERENCES oprema(id)
);



CREATE TABLE testna_voznja (
id INTEGER PRIMARY KEY,
id_kupca INTEGER NOT NULL,
id_automobila INTEGER NOT NULL,
id_prodajni_savjetnik INTEGER NOT NULL,
datum_voznje DATE NOT NULL,
vrijeme_pocetka TIME NOT NULL,
vrijeme_zavrsetka TIME NOT NULL,
prijedena_kilometraza INTEGER NOT NULL CHECK (prijedena_kilometraza >= 0),
napomena VARCHAR(200) NOT NULL,
povratna_informacija VARCHAR(200) NOT NULL,
FOREIGN KEY (id_kupca) REFERENCES kupac (id),
FOREIGN KEY (id_automobila) REFERENCES automobil (id),
FOREIGN KEY (id_prodajni_savjetnik) REFERENCES zaposlenik (id),
CHECK (vrijeme_zavrsetka > vrijeme_pocetka)
);


CREATE TABLE rezervacija (
id INTEGER PRIMARY KEY,
id_kupca INTEGER NOT NULL,
id_automobila INTEGER NOT NULL,
id_prodajni_savjetnik INTEGER NOT NULL,
datum_rezervacije DATE NOT NULL,
datum_isteka_rezervacije DATE NOT NULL,
iznos_kapare INTEGER NOT NULL CHECK (iznos_kapare >= 0),
status_rezervacije VARCHAR(40) NOT NULL CHECK (status_rezervacije IN ('aktivna', 'istekla', 'pretvorena u ugovor')),
FOREIGN KEY (id_kupca) REFERENCES kupac (id),
FOREIGN KEY (id_automobila) REFERENCES automobil (id),
FOREIGN KEY (id_prodajni_savjetnik) REFERENCES zaposlenik (id),
CHECK (datum_isteka_rezervacije >= datum_rezervacije)
);

CREATE TABLE ugovor (
    id INTEGER PRIMARY KEY,
    broj_ugovora INTEGER NOT NULL UNIQUE,
    id_kupca INTEGER NOT NULL,
    id_automobila INTEGER NOT NULL,
    id_prodajni_savjetnik INTEGER NOT NULL,
    id_voditelja INTEGER NOT NULL,
    datum_sklapanja DATE NOT NULL,
    datum_isporuke DATE NOT NULL,
    ukupna_cijena INTEGER NOT NULL CHECK (ukupna_cijena >= 0),
    nacin_placanja VARCHAR(40) NOT NULL CHECK (nacin_placanja IN ('gotovina', 'leasing', 'kredit')),
    tip_ugovora VARCHAR(45) NOT NULL,
    status_ugovora VARCHAR(40) NOT NULL CHECK (status_ugovora IN ('u pripremi', 'isporucen', 'isporučen')),
    
    FOREIGN KEY (id_kupca) REFERENCES kupac (id),
    FOREIGN KEY (id_automobila) REFERENCES automobil (id),
    FOREIGN KEY (id_prodajni_savjetnik) REFERENCES zaposlenik (id),
    FOREIGN KEY (id_voditelja) REFERENCES zaposlenik(id)
);

CREATE TABLE garancija (
id INTEGER PRIMARY KEY,
id_automobila INTEGER NOT NULL,
id_ugovora INTEGER NOT NULL,
tip_garancije VARCHAR(40) NOT NULL CHECK (tip_garancije IN ('osnovna', 'produžena', 'na pogonski sklop', 'na koroziju')),
datum_pocetka DATE NOT NULL,
datum_isteka DATE NOT NULL,
opis_uvjeta VARCHAR(500) NOT NULL,
FOREIGN KEY (id_automobila) REFERENCES automobil (id),
FOREIGN KEY (id_ugovora) REFERENCES ugovor (id)
);

CREATE TABLE servis (
id_servisa INTEGER NOT NULL,
id_automobila  INTEGER NOT NULL,
datum_zaprimanja DATE NOT NULL,
datum_zavrsetka DATE NOT NULL,
tip_servisa VARCHAR(40) NOT NULL,
kilometraza_prilikom_servisa INTEGER NOT NULL,
opis_radova VARCHAR(300) NOT NULL,
status VARCHAR(40) NOT NULL,
opis_stavke VARCHAR(100) NOT NULL,
kolicina INTEGER NOT NULL,
jedinicna_cijena INTEGER NOT NULL,
ukupna_cijena_stavke INTEGER NOT NULL,
tip_stavke VARCHAR(100) NOT NULL,
ukupna_cijena INTEGER NOT NULL,
PRIMARY KEY (id_servisa),
FOREIGN KEY (id_automobila) REFERENCES automobil (id)
);

CREATE TABLE dobavljac (
id INTEGER PRIMARY KEY,
naziv VARCHAR(40) NOT NULL UNIQUE,
oib CHAR(11) NOT NULL UNIQUE, 
adresa VARCHAR(50) NOT NULL,
kontakt_osoba VARCHAR(50) NOT NULL,
kontakt_telefon CHAR(10) NOT NULL UNIQUE,
email VARCHAR(30) NOT NULL UNIQUE,
tip_dobavljaca VARCHAR(50) NOT NULL CHECK (tip_dobavljaca IN ('zastupnik marke', 'dobavljac dijelova', 'opreme'))
);
ALTER TABLE dobavljac ADD COLUMN marka VARCHAR(40);

CREATE TABLE narudzba (
id INTEGER PRIMARY KEY,
id_dobavljaca INTEGER NOT NULL,
id_zaposlenika INTEGER NOT NULL,
datum_narudzbe DATE NOT NULL,
ocekivani_datum_isporuke DATE NOT NULL,
stvarni_datum_isporuke DATE,
status_narudzbe VARCHAR(50) NOT NULL CHECK (status_narudzbe IN ('kreirana', 'potvrdena', 'djelomicno isporucena', 'isporucena')),
ukupna_vrijednost INTEGER NOT NULL CHECK (ukupna_vrijednost >= 0),
za_poznatog_kupca BOOLEAN NOT NULL,
tip_narudzbe VARCHAR(50) NOT NULL CHECK (tip_narudzbe IN ('specijalna', 'hitna', 'redovna')),
FOREIGN KEY (id_dobavljaca) REFERENCES dobavljac(id),
FOREIGN KEY (id_zaposlenika) REFERENCES zaposlenik(id)
);

CREATE TABLE stavka_narudzbe (
id INTEGER PRIMARY KEY,
id_narudzbe INTEGER NOT NULL,
id_modela INTEGER NOT NULL,
kolicina INTEGER NOT NULL CHECK (kolicina > 0),
jedinicna_cijena INTEGER NOT NULL CHECK (jedinicna_cijena >= 0),
napomene VARCHAR(100),
FOREIGN KEY (id_narudzbe) REFERENCES narudzba(id) ON DELETE CASCADE,
FOREIGN KEY (id_modela) REFERENCES model_automobila(id)
);

CREATE TABLE prodajni_cilj (
id INTEGER PRIMARY KEY,
opis_cilja VARCHAR(100) NOT NULL,
tip_cilja VARCHAR(50) NOT NULL CHECK (tip_cilja IN ('mjesecni', 'kvartalni', 'godisnji')),
datum_početka DATE NOT NULL,
datum_zavrsetka DATE NOT NULL,
ciljna_vrijednost INTEGER NOT NULL CHECK (ciljna_vrijednost > 0),
id_salona INTEGER NOT NULL,
id_zaposlenika INTEGER NOT NULL,

datum_posljednjeg_mjerenja DATE,
ostvarena_vrijednost INTEGER CHECK (ostvarena_vrijednost >= 0),
postotak_ostvarenja DECIMAL(4,1) CHECK (postotak_ostvarenja >= 0 AND postotak_ostvarenja <= 100),
komentar VARCHAR(100),

FOREIGN KEY (id_salona) REFERENCES salon(id),
FOREIGN KEY (id_zaposlenika) REFERENCES zaposlenik(id)
);


-- Views
-- View 1. voditelj salona bez inforamcija o plaći, OIB-u i slično
CREATE VIEW pregled_voditelja_salona AS
SELECT  o.ime,
		o.prezime,
        o.email,
        s.id AS id_salona,
        s.naziv AS naziv_salona,
        s.adresa AS adresa_salona,
TIMESTAMPDIFF(YEAR, z.datum_rodenja, CURDATE()) AS godine
FROM voditelj_salona vs
JOIN zaposlenik z ON vs.id_zaposlenika = z.id
JOIN osoba o ON z.id = o.id
JOIN salon s ON vs.id_salona = s.id;

-- View 2. pregled ukupnih servisnih troškova po modelu
CREATE VIEW servisi_po_modelu AS
SELECT      m.naziv_modela AS model,
COUNT(s.id_servisa) AS broj_servisa,
SUM(s.ukupna_cijena) AS ukupni_trosak_servisa
FROM servis s
JOIN automobil a ON s.id_automobila = a.id
JOIN model_automobila m ON a.id_modela = m.id
GROUP BY m.naziv_modela;

-- View 3. pregled dobavljača po tipu i narudžbi
CREATE VIEW dobavljaci_po_tipu AS
SELECT d.tip_dobavljaca,
COUNT(DISTINCT d.id) AS broj_dobavljaca,
COUNT(n.id) AS broj_narudzbi
FROM dobavljac d
LEFT JOIN narudzba n ON d.id = n.id_dobavljaca
GROUP BY d.tip_dobavljaca;

-- View 4. pregled narudžbi prema statusu
CREATE VIEW status_narudzbi AS
SELECT status_narudzbe,
COUNT(*) AS broj_narudzbi,
SUM(ukupna_vrijednost) AS ukupna_vrijednost
FROM narudzba
GROUP BY status_narudzbe;

-- VIew 5. pregled hitnih narudzbi dobavljača 
CREATE VIEW hitne_narudzbe_dobavljaca AS
SELECT n.id AS id_narudzbe,
       d.naziv AS dobavljac,
       n.datum_narudzbe,
       n.ocekivani_datum_isporuke,
       n.stvarni_datum_isporuke,
       n.status_narudzbe
FROM narudzba n 
JOIN dobavljac d ON n.id_dobavljaca = d.id
WHERE n.tip_narudzbe = 'hitna';

-- View 6. Pregled zaposlenika i postavljenih ciljeva
CREATE VIEW ciljevi_zaposlenika AS
SELECT o.ime ||' '|| o.prezime AS zaposlenik,
s.naziv AS salon,
p.opis_cilja,
p.tip_cilja,
p.datum_početka,
p.datum_zavrsetka,
p.ciljna_vrijednost
FROM prodajni_cilj p 
JOIN zaposlenik z ON p.id_zaposlenika = z.id
JOIN osoba o ON z.id = o.id
JOIN salon s ON p.id_salona = s.id;

-- View 7. zbrajanje narudžbi po dobavljaču 
CREATE VIEW ukupna_vrijednost_narudzbi AS
SELECT d.naziv AS dobavljac,
SUM(n.ukupna_vrijednost) AS ukupna_vrijednost,
COUNT(n.id) AS broj_narudzbi
FROM narudzba n
JOIN dobavljac d ON n.id_dobavljaca = d.id
GROUP BY d.naziv;

-- View 8. Pregled servisnih stavki s troškovima
CREATE VIEW servisne_stavke AS
SELECT s.id_servisa,
       a.id AS id_automobila,
       m.naziv_modela AS model,
       s.tip_stavke,
       s.opis_stavke,
       s.kolicina,
       s.jedinicna_cijena,
	   s.ukupna_cijena_stavke
FROM servis s 
JOIN automobil a ON s.id_automobila = a.id
JOIN model_automobila m ON a.id_modela = m.id;

-- View 9. Detaljni prikaz testnih vožnji
CREATE VIEW testne_voznje_detaljno AS 
SELECT ok.ime ||' ' || ok.prezime AS kupac,
       a.VIN,
       m.naziv_modela,
       ma.naziv_marke AS marka,
       tv.datum_voznje,
       tv.vrijeme_pocetka,
       tv.vrijeme_zavrsetka,
       tv.prijedena_kilometraza,
       tv.napomena,
       tv.povratna_informacija,
       oz.ime || ' ' || oz.prezime AS prodajni_savjetnik
FROM testna_voznja tv
JOIN kupac k ON tv.id_kupca = k.id
JOIN osoba ok ON k.id = ok.id
JOIN automobil a ON k.id = ok.id
JOIN model_automobila m ON a.id_modela = m.id
JOIN marka_automobila ma ON m.id_marke = ma.id
JOIN zaposlenik z ON tv.id_prodajni_savjetnik = z.id
JOIN osoba oz On z.id = oz.id;

-- View 10. detaljni prikaz rezervacija
CREATE VIEW rezervacije_automobila AS
SELECT ok.ime || ' ' || ok.prezime AS kupac,
       a.VIN,
       m.naziv_modela,
       ma.naziv_marke AS marka,
       r.datum_rezervacije,
       r.datum_isteka_rezervacije,
       r.iznos_kapare,
       r.status_rezervacije,
       oz.ime || ' ' || oz.prezime AS prodajni_savjetnik
FROM rezervacija r 
JOIN kupac k ON r.id_kupca = k.id
JOIN osoba ok ON k.id = ok.id
JOIN automobil a ON r.id_automobila = a.id
JOIN model_automobila m ON a.id_modela = m.id
JOIN marka_automobila ma ON m.id_marke = ma.id
JOIN zaposlenik z ON r.id_prodajni_savjetnik = z.id
JOIN osoba oz ON z.id = oz.id;

-- Upiti
-- 1. upiti vezani uz view-ove
-- 1.1 Prikaz voditelja starijih od 35 godina
SELECT 
    *
FROM
    pregled_voditelja_salona
WHERE
    godine > 35;

-- 1.2 Prikaz troškova servisa vautomobila koji su bili na servisu više puta
SELECT *
FROM servisi_po_modelu
WHERE broj_servisa > 1;

-- 1.3 Prikaz tipa dobavljača gdje ima više dobavljača za isti tip
SELECT * 
FROM dobavljaci_po_tipu
WHERE broj_dobavljaca >=2;

-- 1.4 Prikaz narudžbi po statusu gdje je više od 2 narudžbe 
SELECT *
FROM status_narudzbi
WHERE broj_narudzbi > 2;

-- 1.5 Prikaz hitnih narudzbi sortiranih prema datumu
SELECT *
FROM hitne_narudzbe_dobavljaca
ORDER BY datum_narudzbe DESC;

-- 1.6 Prikaz mjesečnih ciljeva salona
SELECT *
FROM ciljevi_zaposlenika
WHERE tip_cilja='mjesecni';

-- 1.7 Prikaz ukupne vrijednosti narudžbe dobavljača, ako je vrijednost viša od 1000
SELECT 
    *
FROM
    ukupna_vrijednost_narudzbi
WHERE
    ukupna_vrijednost > 1000;

-- 1.8 Prikaz servisnih stavki ukoliko im je ukupna cijena viša od 100

SELECT *
FROM servisne_stavke
WHERE ukupna_cijena_stavke > 100;
       



-- 1.9 Prikaz testnih vožnji dužih od 10 kilometara
SELECT * 
FROM testne_voznje_detaljno
WHERE prijedena_kilometraza > 10;

-- 1.10 Prikaz rezervacija pretvorenih u ugovor
SELECT *
FROM rezervacije_automobila
WHERE status_rezervacije = 'pretvorena u ugovor';
 
 -- 2. Izračun prosječne plaće po poziciji zaposlenika, sortirano silazno po prosjeku
SELECT 
    pozicija, AVG(placa) AS prosjecna_placa
FROM
    zaposlenik
GROUP BY pozicija
ORDER BY prosjecna_placa DESC;
 
-- 3. Prikazivanje svih smjena koja počinju prije 8 i završavaju iza 16, zajedno sa imenima zaposlenika
 SELECT   s.naziv_smjene,
		  o.ime,
          o.prezime
FROM      smjena s
JOIN      raspored_rada r On s.id = r.id_smjene
JOIN      zaposlenik z ON r.id_zaposlenika = z.id
JOIN      osoba o ON z.id = o.id
WHERE     s.vrijeme_pocetka < '08:00:00'
AND       s.vrijeme_zavrsetka > '16.00.00';

-- 4. Prikaz ukupnog broja prodanih automobila po svakom zaposleniku u zadnjih 6 mjeseci
SELECT o.ime, o.prezime, COUNT(p.id) AS broj_prodaja
FROM   zaposlenik z
JOIN osoba o ON z.id = o.id
JOIN ugovor p ON z.id = p.id_prodajni_savjetnik
WHERE p.datum_sklapanja >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY o.id, o.ime, o.prezime
ORDER BY broj_prodaja DESC;

-- 5. Svi kupci koji su kupili više od jednog automobila u istom mjesecu
SELECT o.ime, o.prezime
FROM kupac k
JOIN osoba o ON k.id = o.id
JOIN ugovor u ON k.id = u.id_kupca
GROUP BY k.id, YEAR(u.datum_sklapanja), MONTH(u.datum_sklapanja)
HAVING COUNT(u.id) > 1;

-- 6. svi modeli bez ijednog automobila
SELECT ma.naziv_modela
FROM model_automobila ma
LEFT JOIN automobil a ON ma.id = a.id_modela
WHERE a.id IS NULL;

-- 7. Prikaz ukupnog broja radnih sati u tjednu za svakog zaposlenika
SELECT o.ime, o.prezime,
SUM(
CASE
WHEN s.vrijeme_zavrsetka > s.vrijeme_pocetka 
THEN
TIMESTAMPDIFF(HOUR, s.vrijeme_pocetka, s.vrijeme_zavrsetka)
ELSE
TIMESTAMPDIFF(HOUR, s.vrijeme_pocetka, ADDTIME(s.vrijeme_zavrsetka, '24:00:00'))
END)
AS total_hours
FROM zaposlenik z
JOIN osoba o ON z.id = o.id
JOIN raspored_rada r ON z.id = r.id_zaposlenika
JOIN smjena s ON r.id_smjene = s.id
GROUP BY z.id, o.ime, o.prezime;

-- 8. Prikaz svih salona u kojima bar jedan zaposlenik nije imao prodaju uzadnjih 30 dana
SELECT DISTINCT s.naziv
FROM salon s
LEFT JOIN zaposlenik z ON s.id = z.id_salona
LEFT JOIN ugovor u ON z.id = u.id_prodajni_savjetnik
AND u.datum_sklapanja >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
WHERE u.id IS NULL;

-- 9. Prikaz svih salona u kojima niti jedan zaposlenik nije imao prodaju uzadnjih 30 dana
SELECT s.naziv
FROM salon s
WHERE NOT EXISTS(
SELECT 1
FROM zaposlenik z
JOIN ugovor u ON z.id = u.id_prodajni_savjetnik
WHERE z.id_salona = s.id
AND u.datum_sklapanja >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
);

-- 10. osnvoni podatci za rabljeno vozilo
SELECT a.VIN,
       a.maloprodajna_cijena,
       ra.broj_prethodnih_vlasnika,
       ra.stanje,
       s.naziv AS naziv_salona
FROM automobil a
JOIN rabljeni_automobil ra ON a.id = ra.id
JOIN salon s ON a.id_salona = s.id
WHERE a.tip_automobila = 'rabljeni';

-- 11. Prikaz 3 najprodavanija modela automobila u posljednjih godinu dana
SELECT m.naziv_modela,
COUNT(u.id) AS broj_prodaja
FROM ugovor u
JOIN automobil a ON u.id_automobila = a.id
JOIN model_automobila m ON a.id_modela = m.id
WHERE u.datum_sklapanja >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY m.naziv_modela
ORDER BY broj_prodaja DESC
LIMIT 3;

-- 12. Prikaz kupaca koji su kupili automobil po cijeni većoj od prosječne
SELECT o.ime,
       o.prezime
FROM kupac k
JOIN osoba o ON k.id = o.id
JOIN ugovor u ON k.id = u.id_kupca
JOIN automobil a ON u.id_automobila = a.id
JOIN model_automobila m ON a.id_modela = m.id
WHERE a.maloprodajna_cijena > (
SELECT AVG(a2.maloprodajna_cijena)
FROM automobil a2
WHERE a2.id_modela = a.id_modela
);

-- 13. Prikaz zaposlenika koji su radili više od jedne smejen u danu
SELECT o.ime,
       o.prezime,
COUNT(r.id) AS broj_smjena_u_danu
FROM zaposlenik z
JOIN osoba o ON z.id = o.id
JOIN raspored_rada r ON z.id = r.id_zaposlenika
GROUP BY z.id, r.datum
HAVING broj_smjena_u_danu  > 1;

-- 14. Prikaz zaposlenika i prosječne plaće po voditelju salona (bez voditelja)
SELECT o.ime,
       o.prezime,
       s.naziv AS naziv_salona,
COUNT(z.id) AS broj_zaposlenika,
AVG(z.placa) AS prosjecna_placa
FROM voditelj_salona vs
JOIN zaposlenik v ON vs.id_zaposlenika = v.id
JOIN osoba o ON v.id = o.id
JOIN salon s ON vs.id_salona = s.id
JOIN zaposlenik z ON z.id_salona = s.id AND z.id != v.id
GROUP BY v.id, o.ime, o.prezime, s.naziv;

-- 15. Prikaz ukupnog prihoda po mjesecima u zadnje dvije godine, sortirano po mjesecima
SELECT
YEAR(u.datum_sklapanja) AS godina,
MONTH(u.datum_sklapanja) AS mjesec,
SUM(u.ukupna_cijena) AS ukupni_prihod
FROM ugovor u
WHERE u.datum_sklapanja >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
GROUP BY godina, mjesec
ORDER BY godina, mjesec;

-- 16. SVe prodaje rabljenih automobila u zadnje dvije godine s podacima i o kupcu i prodavaču 
SELECT u.id,
       ok.ime AS kupac_ime,
       ok.prezime AS kupac_prezime,
       oz.ime AS prodavac_ime,
       oz.prezime AS prodavac_prezime,
       s.naziv AS naziv_salona,
       a.tip_automobila,
       m.naziv_modela
FROM ugovor u 
JOIN kupac k ON u.id_kupca = k.id
JOIN osoba ok ON k.id = ok.id
JOIN zaposlenik z ON u.id_prodajni_savjetnik = z.id
JOIN osoba oz ON z.id = oz.id
JOIN automobil a ON u.id_automobila = a.id
JOIN model_automobila m ON a.id_modela = m.id
JOIN salon s ON a.id_salona = s.id
WHERE u.datum_sklapanja >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
AND a.tip_automobila = 'rabljeni';


-- 17. najprodavanija vozila sa osnovnom garancijjom
SELECT m.naziv_modela,
COUNT(*) AS broj_prodaja
FROM model_automobila m
JOIN automobil a ON m.id = a.id_modela

JOIN ugovor u ON a.id = u.id_automobila
JOIN garancija g ON a.id = g.id_automobila 
WHERE g.tip_garancije = 'osnovna'
GROUP BY m.naziv_modela
ORDER BY
broj_prodaja DESC;

-- 18. zaposlenici koji su prodali više rabljenih nego novih vozila, po imenu i salonu
SELECT o.ime,
       o.prezime,
       s.naziv AS naziv_salona,
COUNT(CASE WHEN a.tip_automobila = 'rabljeni' THEN 1 END) AS broj_rabljenih,
COUNT(CASE WHEN a.tip_automobila = 'novi' THEN 1 END) AS broj_novih
FROM zaposlenik z
JOIN osoba o ON z.id = o.id
JOIN salon s ON z.id_salona = s.id
JOIN ugovor u ON z.id = u.id_prodajni_savjetnik
JOIN automobil a ON u.id_automobila = a.id
GROUP BY o.ime, o.prezime, s.naziv
HAVING 
COUNT(CASE WHEN a.tip_automobila = 'rabljeni' THEN 1 END) >
COUNT(CASE WHEN a.tip_automobila = 'novi' THEN 1 END)
ORDER BY
broj_rabljenih DESC;

-- 19. Prikaz svih salona gdje je više od 70% prodaja automobila imalo daodanu garanciju
SELECT s.naziv
FROM salon s 
JOIN zaposlenik z ON s.id = z.id_salona
JOIN ugovor u ON z.id = u.id_prodajni_savjetnik
LEFT JOIN garancija g ON u.id = g.id_ugovora AND g.tip_garancije = 'produžena'
GROUP BY s.id, s.naziv
HAVING
COUNT(g.id) * 1.0 / COUNT(u.id) > 0.7;

-- 20. Prikaz profita prodaje za svaki mjesec
SELECT
YEAR(u.datum_sklapanja) AS year,
MONTH(u.datum_sklapanja) AS month,
SUM(a.maloprodajna_cijena - a.nabavna_cijena) AS mjesecna_zarada
FROM ugovor u 
JOIN automobil a ON u.id_automobila = a.id
GROUP BY year, month
ORDER BY year,month;











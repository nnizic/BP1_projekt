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

INSERT INTO salon VALUES
(1, 'As speed', 'Osijek - Sv. Leopolda B. Mandića 245', '031/280564', 'as.speed@gmail.com', '08:00', '21:00', '30', '40', '70'),
(2, 'As speed 2', 'Zagreb - Ravnice 51', '01/065874' , 'as.speed-zg@gmail.com', '08:00', '21:00', '50', '60', '110'),
(3, 'As speed 3', 'Pula - Trg Republike 6', ' 052/84793', 'as.speed-pu@gmail.com', '08:00', '21:00', '20', '30', '50');


INSERT INTO osoba VALUES
(10, 'Slaven', 'Đukoković', '54789667811',  'Našice, ulica Brijesta 54', '0915477455', 'as-speed.dukokovic@gmail.com'),
(11, 'Bernard', 'Ban', '44153067895', 'Zagreb - ulica J. J. Strossmayera 148', '0958796611', 'as-speed.ban@gmail.com'),
(12, 'AnaMarija', 'Žarković', '10745985633', 'Pula - prilaz Plovana Mikule 7', '0987569494', 'as-speed.zarkovic@gmail.com'),
(13, 'Maja', 'Šušenka', '03562182487','Osijek - Sportska 2', '0951236567', 'as-speed.susenka@gmail.com'),
(14, 'Ljubica', 'Bajić', '57704288667', 'Zagreb - Glavna ulica 46', '0914456918', 'as-speed.bajic@gmail.com'),
(15, 'Petra', 'Senzel', '05661979786', 'Rovinj, ulica braće Radića 3', '0987456914', 'as-speed.senezl@gmail.com'),
(16, 'Nikola', 'Maraz', '05978860194', 'Osijek - Stjepana Radića 41', '0955564789', 'as-speed.maraz@gmail.com'),
(17, 'Petar', 'Dujmović', '00234759891', 'Zagreb - Trg spomena 55', '0914789632', 'as-speed.dujmovic@gmail.com'),
(18, 'Klaudija', 'Smit', '88793365201', 'Vrsar - Brostolade 33', '0985196914', 'as-speed.smit@gmail.com'),
(19, 'Marija', 'Vojnović', '24196336776', 'Vuka - ulica Stjepana Radića 54', '0910035679', 'as-speed.vojnovic@gmail.com' ),
(20, 'Gorana', 'Jandrilić', '30096308742','Zagreb - ulica Zvonimira Ljekovića 4', '0954789651', 'as-speed.jadrilic@gmail.com'),
(21, 'Igor', 'Katić', '47754789002', 'Pula - Rabarova ulica 78', '0984115997', 'as-speed.katic@gmail.com'),
(22, 'Vjeran', 'Čelenković', '28605556776', 'Čepin - Dunavska ulica 105', '0915697846', 'as-speed.celenkovic@gmail.com' ),
(23, 'Vlado', 'Kopić', '03562167811', 'Zagreb - Osječka ulica 167', '0954545819', 'as-speed.kopic@gmail.com'),
(24, 'Rio', 'Jeger', '79652552939', 'Fažana - Puljska 66', '0987466395', 'as-speed.jeger@gmail.com'),
(25,   'Dario',  'Jukić', '95410879681', ' Osijek, ulica S. Radića 5', '095847569', 'djukic@gmail.com'), 
(26,  'Ana',  'Babić', '74100236891', ' Zagreb, Tiha ulica 55', '0985569321', 'ana_d1@gmail.com'), 
(27,  'Stefani',  'Marić',  '10097663912', ' Pula, ulica A. Mihanovića 77', '0917859661', 'MaricS@gmail.com'), 
(28,  'SDM', 'transport' , '11147895886', ' Zagreb, Opatijska ulica 45', '0145878', 'smd-transport@gmail.com');

INSERT INTO zaposlenik VALUES
(10, STR_TO_DATE('14.10.1995.','%d.%m.%Y.'), STR_TO_DATE('10.12.2020.','%d.%m.%Y.'), 'voditelj', '1500', 1),
(11, STR_TO_DATE('07.02.1989.','%d.%m.%Y.'), STR_TO_DATE('16.08.2018.','%d.%m.%Y.'), 'voditelj', '1500', 2),
(12, STR_TO_DATE('08.03.1992.','%d.%m.%Y.'), STR_TO_DATE('02.02.2019.','%d.%m.%Y.'), 'voditelj', '1500', 3),
(13, STR_TO_DATE('05.07.2002.','%d.%m.%Y.'), STR_TO_DATE('02.09.2021.','%d.%m.%Y.'), 'prodajni_savjetnik', '1200', 1),
(14, STR_TO_DATE('10.07.1969.','%d.%m.%Y.'),STR_TO_DATE('19.03.2021.','%d.%m.%Y.'), 'prodajni_savjetnik', '1200', 2),
(15, STR_TO_DATE('14.06.2001.','%d.%m.%Y.'), STR_TO_DATE('01.10.2020.','%d.%m.%Y.'), 'prodajni_savjetnik', '1200', 3),
(16, STR_TO_DATE('17.01.2000.','%d.%m.%Y.'), STR_TO_DATE('07.04.2022.','%d.%m.%Y.'), 'prodajni_savjetnik', '1200', 1),
(17, STR_TO_DATE('06.03.1991.','%d.%m.%Y.'), STR_TO_DATE('03.09.2023.','%d.%m.%Y.'), 'prodajni_savjetnik', '1200', 2),
(18, STR_TO_DATE('11.05.2000.','%d.%m.%Y.'), STR_TO_DATE('05.01.2024.','%d.%m.%Y.'), 'prodajni_savjetnik', '1200', 3),
(19, STR_TO_DATE('24.11.1972.','%d.%m.%Y.'), STR_TO_DATE('05.02.2020.','%d.%m.%Y.'), 'administrator', '1000', 1),
(20, STR_TO_DATE('09.06.1974.','%d.%m.%Y.'), STR_TO_DATE('10.02.2020.','%d.%m.%Y.'), 'administrator', '1000', 2),
(21, STR_TO_DATE('14.12.1982.','%d.%m.%Y.'), STR_TO_DATE('21.03.2022.','%d.%m.%Y.'), 'administrator', '1000', 3),
(22, STR_TO_DATE('30.04.1992.','%d.%m.%Y.'), STR_TO_DATE('20.01.2019.','%d.%m.%Y.'), 'mehaničar', '1700', 1),
(23, STR_TO_DATE('07.08.1969.','%d.%m.%Y.'), STR_TO_DATE('07.04.2020.','%d.%m.%Y.'), 'mehaničar', '1700', 2),
(24, STR_TO_DATE('30.09.2001.','%d.%m.%Y.'), STR_TO_DATE('24.03.2023.','%d.%m.%Y.'), 'mehaničar', '1700', 3);

INSERT INTO kupac VALUES
(25, 'fizicka osoba', NULL, STR_TO_DATE('24.04.2025.','%d.%m.%Y.'), 'standard'),
(26, 'fizicka osoba', NULL, STR_TO_DATE('10.03.2024.','%d.%m.%Y.'), 'standard'),
(27, 'fizicka osoba', NULL, STR_TO_DATE('12.12.2024.','%d.%m.%Y.'), 'standard'),
(28, 'pravna osoba', 'SDM transport', STR_TO_DATE('14.11.2024.','%d.%m.%Y.'), 'VIP');

INSERT INTO voditelj_salona VALUES
(10, 1),
(11, 2),
(12, 3);


INSERT INTO smjena VALUES
(1,'jutarnja smjena', '8:00', '16:00', 'ponedjeljak'),
(2,'jutarnja smjena', '8:00', '16:00', 'utorak'),
(3,'jutarnja smjena', '8:00', '16:00', 'srijeda'),
(4,'jutarnja smjena', '8:00', '16:00', 'četvrtak'),
(5,'jutarnja smjena', '8:00', '16:00', 'petak'),
(6,'popodnevna smjena', '12:00', '21:00', 'ponedjeljak'),
(7,'popodnevna smjena', '12:00', '21:00', 'utorak'),
(8,'popodnevna smjena', '12:00', '21:00', 'srijeda'),
(9,'popodnevna smjena', '12:00', '21:00', 'četvrtak'),
(10,'popodnevna smjena', '12:00', '21:00','petak'),
(11,'vikend smjena', '8:00', '16:00', 'subota'),
(12,'vikend smjena', '8:00', '16:00', 'nedjelja'),
(13,'vikend smjena', '12:00', '21:00', 'subota'),
(14,'vikend smjena', '12:00', '21:00', 'nedjelja'),
(15,'dežurstvo', '00:00', '24:00', 'subota'),
(16,'dežurstvo', '00:00', '24:00', 'nedjelja');

INSERT INTO raspored_rada VALUES
(6610, 10, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6611, 11, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6612, 12, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6613, 13, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6614, 14, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6615, 15, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6616, 16, '6', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6617, 17, '6', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6618, 18, '6', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6619, 19, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6620, 20, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6621, 21, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6622, 22, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6623, 23, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6624, 24, '1', STR_TO_DATE('21.04.2025.','%d.%m.%Y.'), 'redovna'),
(6625, 10, 2, STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6626, 11, 2, STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6627, 12, 2, STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6628, 13, '2', STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6629, 14, '2', STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6630, 15, '2', STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6631, 16, '7', STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6632, 17, '7', STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6633, 18, '7', STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6634, 19, '2', STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6635, 20, '2', STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6636, 21, '2', STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6637, 22, 2, STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6638, 23, 2, STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6639, 24, 2, STR_TO_DATE('22.04.2025.','%d.%m.%Y.'), 'redovna'),
(6640, 10, '3', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6641, 11, '3', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6642, 12, '3', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6643, 13, '3', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6644, 14, '3', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6645, 15, 3, STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6646, 16, '8', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6647, 17, '8', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6648, 18, '8', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6649, 19, 3, STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6650, 20, 3, STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6651, 21, 3, STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6652, 22, '3', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6653, 23, '3', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'redovna'),
(6654, 24, '16', STR_TO_DATE('23.04.2025.','%d.%m.%Y.'), 'dezurstvo');

INSERT INTO marka_automobila VALUES
(55, 'BMW', 'Njemačka'),
(56, 'Mercedes - Benz', 'Njemačka'),
(57, 'Fiat', 'Italija'),
(58, 'Hyundai', 'Južna Korea'),
(59, 'Toyota', 'Japan'),
(60, 'Opel', 'Njemačka'),
(61, 'Mazda', 'Japan'),
(62, 'Peugeot', 'Francuska'),
(63, 'Citroen', 'Francuska'),
(64, 'Nissan', 'Japan');

INSERT INTO model_automobila VALUES
(100, 55, 'X2', '2024', '2025', '80000'),
(101, 56, 'E-klasa', '2024', '2025', '110000'),
(102, 57, '600', '2024', '2025', '30000'), 
(103, 58, 'Kona', '2023', '2024', '31000'),
(104, 59, 'Corolla Sedan', '2020', '2024', '25000'),    
(105, 60, 'Mokka', '2024', '2025', '35000'), 
(106, 61, '2', '2023', '2025', '30000'),
(107, 62, '208', '2024', '2025', '20000'),
(108, 63, 'C3', '2024', '2025', '20000'), 
(109, 64, 'Juke', '2021', '2024', '27000'); 



INSERT INTO automobil VALUES
(100, '54G7HI8JK9K874595', 100, '4 vrata', 83000, '2025', 'crna', 30, 'prodano', 'novi', '2025-03-05', 49230, 30, 64000, 80000, 2, 125, 1499, 'benzin', 139, 5.3, 4554, 1845, 1590, 2692, 1645),
(101, 'A748SSE77DF741020', 101, '4 vrata', 113000, '2025', 'bijela', 40, 'rezerviran', 'novi', '2025-03-25', 67692, 30, 88000, 110000, 1, 145, 1993, 'dizel', 132, 5.4, 4428, 1796, 1452, 2729, 1700),
(102, 'GH7DDBN789G852106', 102, '4 vrata', 32000, '2025', 'zelena', 10000, 'dostupan', 'novi', '2025-02-14', 18461, 30, 24000, 30000, 3, 75, 1199, 'hibrid', 110, 4.9, 4171, 1781, 1536, 2557, 1628),
(103, 'DEWS8874DDS774107', 103, '4 vrata', 31500, '2024', 'siva', 2000, 'prodano', 'rabljeni', '2024-07-05', 19076, 30, 24800, 31000, 1, 102, 1598, 'benzin', 141, 6.2, 4350, 1825, 1570, 2660, 1405),
(104, 'SE4415DVF56989743', 104, '4 vrata', 28000, '2024', 'bijela', 5000, 'prodano', 'rabljeni', '2024-10-09', 15384, 30, 20000, 25000, 1, 92, 1490, 'benzin', 124, 4.6, 4630, 1780, 1435, 2700, 1260),
(105, '47EEF5520GG741011', 105, '4 vrata', 36000, '2025', 'tamnosiva', 150, 'dostupan', 'novi', '2025-02-02', 12307, 30, 28000, 35000, 2, 96, 1199, 'benzin', 111, 4.8, 4151, 1791, 1531, 2557, 1715),
(106, '25SDC245C8C685293', 106, '4 vrata', 32000, '2025', 'crvena', 700, 'rezerviran', 'novi', '2025-04-10', 18461, 30, 24000, 30000, 3, 68, 1490, 'hibrid', 87, 4.0, 3940, 1745, 1505, 2560, 1180),
(107, '6SDE055DFV2001247', 107, '4 vrata', 21000, '2025', 'crna', 550, 'dostupan', 'novi', '2025-01-20', 12307, 30, 16000, 20000, 3, 74, 1199, 'benzin', 117, 5.2, 4055, 1745, 1430, 2540, 1165),
(108, '7SAC2557CC6231305', 108, '4 vrata', 20500, '2025', 'bijela', 140, 'prodano', 'novi', '2025-01-20', 12307, 30, 16000, 20000, 2, 74, 1199, 'benzin', 128, 5.7, 4015, 1755, 1577, 2540, 1226),
(109, '5SA74DSA47D892370', 109, '4 vrata', 28000, '2024', 'tamnoplava', 65, 'prodano', 'novi', '2025-01-10', 16615, 30, 21600, 27000, 1, 84, 999, 'benzin', 114, 5.0, 4210, 1800, 1595, 2636, 1268);

INSERT INTO novi_automobil VALUES
(100, 0, 'salonsko', NULL),
(101, 0, 'lager', NULL), 
(102, 0, 'zamjensko', NULL), 
(105, 0, 'salonsko', NULL), 
(106, 0, 'testno', NULL),
(107, 0, 'lager', NULL),
(108, 1, 'salonsko', 893),
(109, 1, 'salonsko', 977);

INSERT INTO rabljeni_automobil VALUES
(103, 1, STR_TO_DATE('10.02.2024.','%d.%m.%Y.'), 1, 'odlicno', '/'),
(104, 1, STR_TO_DATE('05.05.2024.','%d.%m.%Y.'), 1, 'odlicno', '/');

INSERT INTO automobil_na_servisu VALUES
(1, 103, STR_TO_DATE('28.04.2025.','%d.%m.%Y.'), STR_TO_DATE('10.05.2025.','%d.%m.%Y.'), 'Zamjena cijeva za klimu', 'Popravak i reparacija crijeva klime', 'zavrseno');


INSERT INTO paket_opreme VALUES
(1, 'vanjski paket', 'specifične barnike, veće felge, poseban dizajn prednje maske, posebna boja karoserije', 3000),
(2, 'navigacijski paket', 'ugrađena navigacija, veći ekran, bolje glasovno upravljanje', 1000),
(3, 'blind Spot Monitoring', 'upozorenje kad vozilo ulazi u mrtvi kut', 500),
(4, 'head-up display', 'Projekcija podataka na vjetrobransko staklo', 800),
(5, 'smartphone Connectivity paket', 'bežično spajanje telefona, prikaz aplikacija direktno na ekranu auta', 500);

INSERT INTO oprema  VALUES
(1, 'poseban dizajn prednje maske', 'unaprijeđena prednja maska automobila', 1),
(2, 'veće felge', 'veće i atraktivnije felge', 1),
(3, 'specifične barnike', 'posebna metalik boja karoserije', 1),
(4, 'navigacija', 'ugrađena navigacija s detaljnim kartama', 2),
(5, 'veći ekran', 'povećani ekran za bolji pregled', 2),
(6, 'glasovno upravljanje', 'bolja podrška za glasovne naredbe', 2),
(7, 'mrtvi kut', 'senzori za detekciju vozila u mrtvom kutu', 3),
(8, 'head-up display', 'prikaz podataka na vjetrobranu', 4),
(9, 'bežično spajanje telefona', 'spajanje mobitela bez kabela', 5),
(10, 'prikaz aplikacija', 'prikaz aplikacija direktno na ekranu automobila', 5),
(11, 'kožni volan', 'volan presvučen kožom', NULL),  -- slobodna oprema
(12, 'panoramski krov', 'veliki stakleni krov', NULL); -- slobodna oprema

INSERT INTO oprema_u_paketu (id_paketa, id_opreme) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5),
(2, 6),
(3, 7),
(4, 8),
(5, 9),
(5, 10);

INSERT INTO oprema_automobila (id_automobila, id_opreme) VALUES
(100, 1),  -- automobil 100 ima poseban dizajn prednje maske
(100, 4),  -- automobil 100 ima navigaciju
(100, 11), -- automobil 100 ima kožni volan
(101, 3),  -- automobil 101 ima specifične barnike
(101, 7),  -- automobil 101 ima mrtvi kut
(102, 12), -- automobil 102 ima panoramski krov
(102, 8);  -- automobil 102 ima head-up display

INSERT INTO testna_voznja VALUES
(001, 25 , 103, 13, STR_TO_DATE('22.04.2025.','%d.%m.%Y.'),  '10:00', '10:30', '15', '/', 'Kupac zadovoljan automobilom i njegovom izvedbom te zaposlenicima naše tvrtke'),
(002, 28 , 101, 16, STR_TO_DATE('15.04.2025.','%d.%m.%Y.'),  '12:00', '12:30', '20', '/', 'Tvrtka SMD transport stavlja na rezervaciju na automobil do 10.05.2025.'),
(003, 28 , 109, 16, STR_TO_DATE('15.04.2025.','%d.%m.%Y.'),  '12:00', '12:30', '20', '/', 'Tvrtka SMD zbog povećanja obujma posla kupuje navedeno vozilo. Istome ustupljene informacije o uvozu novih modela vozila te istog kontaktirati nakon uvoza i dati prednost biranja vozila.'),
(004, 27 , 106, 15, STR_TO_DATE('15.04.2025.','%d.%m.%Y.'),  '12:45', '13:10', '30', '/', 'Kupac stavlja rezervaciju na automobil do odobrenja kredita'),
(005, 26 , 100, 14, STR_TO_DATE('10.03.2025.','%d.%m.%Y.'),  '13:00', '13:30', '25', '/', '/');


INSERT INTO rezervacija VALUES
(800, 28, 101, 16, STR_TO_DATE('15.04.2025.','%d.%m.%Y.'),  STR_TO_DATE('10.05.2025.','%d.%m.%Y.'),  '1000', 'aktivna'),
(801, 27, 106, 15, STR_TO_DATE('15.04.2025.','%d.%m.%Y.'),  STR_TO_DATE('15.05.2025.','%d.%m.%Y.'),  '1000', 'aktivna');

INSERT INTO ugovor VALUES
(564748, '11', 25, 103, 13, 10,  STR_TO_DATE('24.04.2025.','%d.%m.%Y.'), STR_TO_DATE('26.04.2025.','%d.%m.%Y.'), '31500',  'gotovina', 'kupoprodaja', 'isporučen' ),
(968748, '22',  28, 109, 16, 10,  STR_TO_DATE('15.04.2025.','%d.%m.%Y.'),  STR_TO_DATE('17.04.2025.','%d.%m.%Y.'), '27000',  'leasing', 'kupoprodaja', 'isporučen' ),
(621105, '55',  26, 100, 14, 11,  STR_TO_DATE('10.03.2025.','%d.%m.%Y.'),  STR_TO_DATE('15.03.2025.','%d.%m.%Y.'), '83000',  'kredit', 'kupoprodaja', 'isporučen' ),
(98978, '66',  28 , 108, 17, 11,  STR_TO_DATE('22.02.2025.','%d.%m.%Y.'),  STR_TO_DATE('27.02.2025.','%d.%m.%Y.'), '20500',  'leasing', 'kupoprodaja', 'isporučen' ),
(10002, '77',  28 , 104, 16, 10,  STR_TO_DATE('25.02.2025.','%d.%m.%Y.'),  STR_TO_DATE('28.02.2025.','%d.%m.%Y.'), '25000',  'leasing', 'kupoprodaja', 'isporučen' );

INSERT INTO garancija VALUES
(55, 103, 564748,  'osnovna', STR_TO_DATE('26.04.2025.','%d.%m.%Y.'), STR_TO_DATE('26.04.2026.','%d.%m.%Y.'), ' Garancija pokriva sve tvorničke nedostatke u materijalu i izradi koji se pojave tijekom važenja jamstvenog roka. Garancija vrijedi samo ako se vozilo koristi u skladu s uputama proizvođača i propisanim načinom održavanja. '),
(66, 109, 968748, 'produžena',  STR_TO_DATE('17.04.2025.','%d.%m.%Y.'),  STR_TO_DATE('17.07.2026.','%d.%m.%Y.'), ' Garancija pokriva sve tvorničke nedostatke u materijalu i izradi koji se pojave tijekom važenja jamstvenog roka. Garancija vrijedi samo ako se vozilo koristi u skladu s uputama proizvođača i propisanim načinom održavanja. ' ),
(77, 100, 621105, 'osnovna',  STR_TO_DATE('15.03.2025.','%d.%m.%Y.'),  STR_TO_DATE('15.03.2026.','%d.%m.%Y.'), ' Garancija pokriva sve tvorničke nedostatke u materijalu i izradi koji se pojave tijekom važenja jamstvenog roka. Garancija vrijedi samo ako se vozilo koristi u skladu s uputama proizvođača i propisanim načinom održavanja.'),
(88, 108, 98978, 'produžena', STR_TO_DATE('27.02.2025.','%d.%m.%Y.'),  STR_TO_DATE('27.05.2026.','%d.%m.%Y.'), 'Garancija pokriva sve tvorničke nedostatke u materijalu i izradi koji se pojave tijekom važenja jamstvenog roka. Garancija vrijedi samo ako se vozilo koristi u skladu s uputama proizvođača i propisanim načinom održavanja.' ),
(99, 104, 10002, 'produžena', STR_TO_DATE('28.02.2025.','%d.%m.%Y.'),  STR_TO_DATE('28.05.2026.','%d.%m.%Y.'), 'Garancija pokriva sve tvorničke nedostatke u materijalu i izradi koji se pojave tijekom važenja jamstvenog roka. Garancija vrijedi samo ako se vozilo koristi u skladu s uputama proizvođača i propisanim načinom održavanja.' );

INSERT INTO servis VALUES 
(1, 103, STR_TO_DATE('28.04.2025.','%d.%m.%Y.'), STR_TO_DATE('10.05.2025.','%d.%m.%Y.'), 'izvanredni', 2145, 'Popravak i reparacija crijeva klime', 'fakturiran', 'crijeva za klimu', 2, 60, 120, 'dio', 120);


INSERT INTO dobavljac VALUES
(780, 'Tomic & co d.o.o.', '66478920159', 'Zagreb, ulica T. Ujevića 98', 'Jan Koniček', '0984715633', 'tomic&co_jkonicek@gmail.com', 'zastupnik marke', 'BMW'),
(880, 'Silux d.o.o.', '00786219862', 'Osijek, Vrtna ulica 19', 'Mario Ivanić', '0918969331', 'silux_mivanic@gmail.com', 'dobavljac dijelova', NULL),
(980, 'Minux d.o.o.', '98774125691', 'Pula, G. Gesspoto 87', 'Pero Matić', '0958874123', 'minux_matic@gmail.com', 'opreme', NULL);

INSERT INTO narudzba VALUES
( 748, 880, 19, STR_TO_DATE('30.04.2025.','%d.%m.%Y.'), STR_TO_DATE('05.05.2025.','%d.%m.%Y.'), STR_TO_DATE('06.05.2025.','%d.%m.%Y.'), 'isporučena', '120', '1', 'redovna'),
( 893, 780, 11, STR_TO_DATE('12.12.2024.','%d.%m.%Y.'), STR_TO_DATE('10.01.2025.','%d.%m.%Y.'), STR_TO_DATE('20.01.2025.','%d.%m.%Y.'), 'isporučena', '20000', '4', 'redovna'),
( 977, 780, 10, STR_TO_DATE('12.12.2024.','%d.%m.%Y.'), STR_TO_DATE('10.01.2025.','%d.%m.%Y.'), STR_TO_DATE('10.01.2025.','%d.%m.%Y.'), 'isporučena', '30000', '4', 'redovna');  
 
INSERT INTO stavka_narudzbe VALUES
(1478, 748, 103, 2, 60, '/'),
(1479, 893, 108, 1, 20000, '/'),
(1480, 977, 109, 1, 30000, '/');



INSERT INTO prodajni_cilj  VALUES
(1, 'prodaja 50 novih automobila', 'godisnji', STR_TO_DATE('01.01.2025.','%d.%m.%Y.'), STR_TO_DATE('31.12.2025.','%d.%m.%Y.'), 50, 1, 13, STR_TO_DATE('01.05.2025.','%d.%m.%Y.'), 4, 8.0, 'loš početak godine'),
(2, 'prodaja 15 hibridnih modela', 'kvartalni', STR_TO_DATE('01.01.2025.','%d.%m.%Y.'), STR_TO_DATE('31.03.2025.','%d.%m.%Y.'), 15, 2, 14, STR_TO_DATE('15.05.2025.','%d.%m.%Y.'), 12, 24.0, 'poboljšanje rezultata'),
(3, 'prodaja 4 novih automobila - Zagreb', 'mjesecni', STR_TO_DATE('01.05.2025.','%d.%m.%Y.'), STR_TO_DATE('31.05.2025.','%d.%m.%Y.'), 4, 1, 15, STR_TO_DATE('01.06.2025.','%d.%m.%Y.'), 5, 33.3, 'solidna prodaja'),
(4, 'prodaja 3 novih klasičnih automobila - Osijek', 'mjesecni', STR_TO_DATE('01.05.2025.','%d.%m.%Y.'), STR_TO_DATE('31.05.2025.','%d.%m.%Y.'), 3, 2, 16, STR_TO_DATE('15.06.2025.','%d.%m.%Y.'), 2, 66.7, 'ostvarenje u tijeku'),
(5, 'prodaja 2 novih klasičnih automobila - Pula', 'mjesecni', STR_TO_DATE('01.05.2025.','%d.%m.%Y.'), STR_TO_DATE('31.05.2025.','%d.%m.%Y.'), 2, 3, 17, STR_TO_DATE('20.06.2025.','%d.%m.%Y.'), 1, 50.0, 'realizacija u planu');


-- view
CREATE VIEW pregled_voditelja_salona AS
SELECT  o.ime,
		o.prezime,
        o.email,
        s.naziv AS naziv_salona,
        s.adresa AS adresa_salona,
TIMESTAMPDIFF(YEAR, z.datum_rodenja, CURDATE()) AS godine
FROM voditelj_salona vs
JOIN zaposlenik z ON vs.id_zaposlenika = z.id
JOIN osoba o ON z.id = o.id
JOIN salon s ON vs.id_salona = s.id;


-- Upiti

-- 1. Prikaži sve zaposlenike koji rade u salonima čiji je voditelj stariji od 35 godina
 SELECT * FROM pregled_voditelja_salona WHERE godine>35;
 
 -- 2. Izračun prosječne plaće po poziciji zaposlenika, sortirano silazno po prosjeku
 SELECT pozicija, AVG(placa) AS prosjecna_placa
 FROM zaposlenik
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

-- 13. Prikaz zaposlenika koji su radili više od jedne smeje u danu
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
count(g.id) * 1.0 / COUNT(u.id) > 0.7;

-- 20. Prikaz profita prodaje za svaki mjesec
SELECT
YEAR(u.datum_sklapanja) AS year,
MONTH(u.datum_sklapanja) AS month,
SUM(a.maloprodajna_cijena - a.nabavna_cijena) AS mjesecna_zarada
FROM ugovor u 
JOIN automobil a ON u.id_automobila = a.id
GROUP BY year, month
ORDER BY year,month;

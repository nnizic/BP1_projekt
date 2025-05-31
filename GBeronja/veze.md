# Osoba 2 - Poslovni proces i ER dijagram

## 1. ORGANIZACIJSKA STRUKTURA

**Salon za automobile** je osnovna poslovna jedinica koja ima svoj naziv, adresu, kontakt podatke i radno vrijeme. Svaki salon ima definirane kapacitete za izložbene prostore (unutarnje i vanjske) te kapacitet servisa. Salon **zapošljava** više zaposlenika, pri čemu svaki zaposlenik radi u jednom salonu. Jedan od zaposlenika ima ulogu **voditelja salona** koji upravlja cijelim salonom.

Zaposlenici imaju različite pozicije (prodajni savjetnik, mehaničar, administrator itd.) i svoje plaće. Njihov rad se organizira kroz **smjene** koje imaju definirano vrijeme početka i završetka te dan u tjednu. **Raspored rada** povezuje zaposlenike sa smjenama na specifične datume.

## 2. UPRAVLJANJE VOZILIMA

### 2.1 Inventar vozila

Salon **posjeduje** vozila različitih **marki** i **modela**. Svaki model pripada određenoj marki i ima osnovnu cijenu. **Automobili** mogu biti **novi** ili **rabljeni**, što se modelira kroz specijalizaciju:

- **Novi automobili** mogu biti naručeni za poznatog kupca i imaju svoju klasifikaciju
- **Rabljeni automobili** imaju podatke o prethodnim vlasnicima, datumu prve registracije, stanju vozila itd.

Svaki automobil ima detaljne tehničke specifikacije (snaga motora, emisije, dimenzije) te poslovne podatke (nabavna cijena, maloprodajna cijena, status).

### 2.2 Oprema vozila

Automobili mogu biti **opremljeni** različitom **opremom**. Oprema se može prodavati pojedinačno ili u sklopu **paketa opreme**. Ova N:M veza omogućuje fleksibilno konfiguriranje vozila prema zahtjevima kupaca.

## 3. NABAVNI PROCES

**Dobavljači** mogu biti zastupnici marki, dobavljači dijelova ili opreme. **Zaposlenici** kreiraju **narudžbe** kod dobavljača, koje sadrže **stavke narudžbe** sa specifičnim modelima vozila, količinama i cijenama. Narudžbe mogu biti redovne, hitne ili specijalne, te mogu biti za poznatog kupca.

Kada se narudžba realizira, novi automobili se dodaju u inventar salona.

## 4. PRODAJNI PROCES

### 4.1 Upravljanje kupcima

**Kupci** mogu biti fizičke ili pravne osobe, s različitim kategorijama (standard, fleet, VIP). Svaki kupac ima datum prve kupnje i ostale podatke potrebne za praćenje odnosa s klijentima.

### 4.2 Prodajni ciklus

Prodajni proces uključuje nekoliko faza:

1. **Testna vožnja** - kupac testira vozilo uz nadzor prodajnog savjetnika
2. **Rezervacija** - kupac može rezervirati vozilo uz plaćanje kapare
3. **Ugovor** - finaliziranje prodaje s definiranim uvjetima plaćanja
4. **Garancija** - vozilo se pokriva različitim tipovima garancija

### 4.3 Prodajni ciljevi

Salon postavlja **prodajne ciljeve** za zaposlenike, koji mogu biti mjesečni, kvartalni ili godišnji. Prate se ostvarene vrijednosti i postoci ispunjenja ciljeva.

## 5. SERVISIRANJE I ODRŽAVANJE

Automobili se redovito **servisiraju** i **održavaju**. Kada vozilo dolazi na servis, evidentirani su datum prijema, opis radova, korišteni dijelovi i ukupna cijena. Također se vodi evidencija o vozilima koja su trenutno **na servisu**.

## 6. KLJUČNE POSLOVNE VEZE

- **Osoba** može biti **zaposlenik** ili **kupac** (ili oboje)
- **Zaposlenik** može biti **voditelj salona**
- **Model** ima više **primjeraka** vozila
- **Vozilo** se može **testirati**, **rezervirati** i **prodati**
- **Ugovor** uključuje **garancije**
- **Narudžbe** rezultiraju **novim vozilima**

## 7. IZVJEŠTAVANJE I ANALITIKA

Sustav omogućuje praćenje:

- Prodajnih performansi po zaposlenicima
- Najprodavanijih modela
- Ostvarenja prodajnih ciljeva
- Profitabilnosti po mjesecima
- Učinkovitosti servisa

Na osnovu detaljne analize PDF dijagrama i CSV datoteke, evo konačnog rezultata:

## **ENTITETI:**

**salon**(id, naziv, adresa, kontakt_telefon, email, radno_vrijeme_pocetak, radno_vrijeme_kraj, kapacitet_izlozbenih_mjesta_unutra, kapacitet_izlozbenih_mjesta_vani, kapacitet_servisa)

**osoba**(id, ime, prezime, oib, adresa, kontakt_telefon, email)

**zaposlenik**(id, datum_rodenja, datum_zaposlenja, pozicija, placa, id_salona)

**kupac**(id, tip_kupca, naziv_tvrtke, datum_prve_kupnje, kategorija_kupca)

**voditelj_salona**(id_zaposlenika, id_salona)

**smjena**(id, naziv_smjene, vrijeme_pocetka, vrijeme_zavrsetka, dan_u_tjednu)

**raspored_rada**(id, id_zaposlenika, id_smjene, datum, status)

**marka_automobila**(id, naziv_marke, zemlja_porijekla)

**model_automobila**(id, id_marke, naziv_modela, godina_pocetka_proizvodnje, godina_zavrsetka_proizvodnje, osnovna_cijena)

**izvedba_modela**(id, id_modela, tip_izvedbe, opis, dodatna_cijena)

**automobil**(id, VIN, id_izvedbe, godina_proizvodnje, boja, kilometraza, status, tip_automobila, datum_zaprimanja, nabavna_cijena, RUC_postotak, cijena_bez_PDV, maloprodajna_cijena, id_salona)

**novi_automobil**(id, za_poznatog_kupca, klasifikacija, id_narudzbe)

**rabljeni_automobil**(id, broj_prethodnih_vlasnika, datum_prve_registracije, servisna_knjizica, stanje, napomene)

**tehnicke_specifikacije**(id, id_automobila, snaga_motora, zapremnina_motora, vrsta_goriva, emisija_CO2, prosjecna_potrosnja, duzina, sirina, visina, meduosovinski_razmak, masa_praznog_vozila)

**automobil_na_servisu**(id, id_automobila, datum_prijema, datum_povratka, opis_kvara, napomena)

**paket_opreme**(id, naziv_paketa, opis, cijena_paketa)

**oprema**(id, naziv_opreme, opis, paket_id)

**oprema_automobila**(id_automobila, id_opreme)

**testna_voznja**(id, id_kupca, id_automobila, id_prodajni_savjetnik, datum_voznje, vrijeme_pocetka, vrijeme_zavrsetka, prijedena_kilometraza, napomena, povratna_informacija)

**rezervacija**(id, id_kupca, id_automobila, id_prodajni_savjetnik, datum_rezervacije, datum_isteka_rezervacije, iznos_kapare, status_rezervacije)

**ugovor**(id, broj_ugovora, id_kupca, id_automobila, id_prodajni_savjetnik, id_voditelja, datum_sklapanja, datum_isporuke, ukupna_cijena, nacin_placanja, tip_ugovora, status_ugovora)

**garancija**(id, id_automobil, id_ugovora, tip_garancije, datum_pocetka, datum_isteka, opis_uvjeta)

**servis**(id_servisa, id_automobila, datum_zaprimanja, datum_zavrsetka, tip_servisa, kilometraza_prilikom_servisa, opis_radova, status, opis_stavke, kolicina, jedinicna_cijena, ukupna_cijena_stavke, tip_stavke, ukupna_cijena)

**servisna_stavka**(id, id_servisa, opis_stavke, kolicina, jedinicna_cijena, ukupna_cijena, tip_stavke)

**dobavljac**(id, naziv, oib, adresa, kontakt_osoba, kontakt_telefon, email, tip_dobavljaca)

**narudzba**(id, id_dobavljaca, id_zaposlenika, datum_narudzbe, ocekivani_datum_isporuke, stvarni_datum_isporuke, status_narudzbe, ukupna_vrijednost, za_poznatog_kupca, tip_narudzbe)

**stavka_narudzbe**(id, id_narudzbe, id_modela, kolicina, jedinicna_cijena, napomene)

**prodajni_cilj**(id, opis_cilja, tip_cilja, datum_pocetka, datum_zavrsetka, ciljna_vrijednost, id_salona, id_zaposlenika, datum_posljednjeg_mjerenja, ostvarena_vrijednost, postotak_ostvarenja, komentar)

## Tablica entiteta i veza



| **Entitet 1**    | **Entitet 2**          | **Tip veze** | **Naziv veze**        | **Objašnjenje**                                                                                          |
| ---------------- | ---------------------- | ------------ | --------------------- | -------------------------------------------------------------------------------------------------------- |
| osoba            | zaposlenik             | 1:1          | je                    | Jedna osoba može biti zaposlenik ili ne, jedan zaposlenik je jedna osoba                                 |
| osoba            | kupac                  | 1:1          | je                    | Jedna osoba može biti kupac ili ne, jedan kupac je jedna osoba                                           |
| zaposlenik       | voditelj_salona        | 1:1          | vodi_salon            | Jedan zaposlenik može voditi salon ili ne, jedan voditelj je jedan zaposlenik                            |
| salon            | voditelj_salona        | 1:1          | ima_voditelja         | Jedan salon ima točno jednog voditelja, jedan voditelj vodi jedan salon                                  |
| automobil        | novi_automobil         | 1:1          | je_novi               | Jedan automobil može biti novi ili ne, jedan novi automobil je jedan automobil                           |
| automobil        | rabljeni_automobil     | 1:1          | je_rabljeni           | Jedan automobil može biti rabljen ili ne, jedan rabljeni automobil je jedan automobil                    |
| automobil        | tehnicke_specifikacije | 1:1          | specificira           | Jedan automobil ima jedne tehničke specifikacije, jedne specifikacije pripadaju jednom automobilu        |
| salon            | zaposlenik             | 1:N          | zapošljava            | Jedan salon zapošljava više zaposlenika, jedan zaposlenik radi u jednom salonu                           |
| salon            | automobil              | 1:N          | posjeduje             | Jedan salon posjeduje više automobila, jedan automobil se nalazi u jednom salonu                         |
| salon            | prodajni_cilj          | 1:N          | postavlja             | Jedan salon postavlja više ciljeva, jedan cilj pripada jednom salonu                                     |
| marka_automobila | model_automobila       | 1:N          | proizvodi             | Jedna marka proizvodi više modela, jedan model pripada jednoj marki                                      |
| model_automobila | izvedba_modela         | 1:N          | specificira_izvedbu   | Jedan model ima više izvedbi, jedna izvedba pripada jednom modelu                                        |
| model_automobila | stavka_narudzbe        | 1:N          | odnosi_se_na          | Jedan model može biti u više stavki narudžbi, jedna stavka se odnosi na jedan model                      |
| izvedba_modela   | automobil              | 1:N          | definira              | Jedna izvedba definira više automobila, jedan automobil pripada jednoj izvedbi                           |
| automobil        | testna_voznja          | 1:N          | koristi_se_za         | Jedan automobil može imati više testnih vožnji, jedna testna vožnja koristi jedan automobil              |
| automobil        | rezervacija            | 1:N          | rezervira             | Jedan automobil može biti rezerviran više puta, jedna rezervacija rezervira jedan automobil              |
| automobil        | ugovor                 | 1:1          | prodaje_se            | Jedan automobil se prodaje jednom (jedan ugovor), jedan ugovor prodaje jedan automobil                   |
| automobil        | garancija              | 1:N          | ima                   | Jedan automobil može imati više garancija, jedna garancija pripada jednom automobilu                     |
| automobil        | automobil_na_servisu   | 1:N          | ide_na_servis         | Jedan automobil može ići na servis više puta, jedno servisiranje se odnosi na jedan automobil            |
| automobil        | servis                 | 1:N          | servisira_se          | Jedan automobil može imati više servisa, jedan servis se odnosi na jedan automobil                       |
| kupac            | testna_voznja          | 1:N          | vodi                  | Jedan kupac može voditi više testnih vožnji, jedna testna vožnja pripada jednom kupcu                    |
| kupac            | rezervacija            | 1:N          | rezervira             | Jedan kupac može imati više rezervacija, jedna rezervacija pripada jednom kupcu                          |
| kupac            | ugovor                 | 1:N          | potpisuje             | Jedan kupac može potpisati više ugovora, jedan ugovor potpisuje jedan kupac                              |
| zaposlenik       | testna_voznja          | 1:N          | vodi                  | Jedan zaposlenik može voditi više testnih vožnji, jedna testna vožnja se vodi od jednog zaposlenika      |
| zaposlenik       | rezervacija            | 1:N          | procesira             | Jedan zaposlenik može procesirati više rezervacija, jedna rezervacija se procesira od jednog zaposlenika |
| zaposlenik       | ugovor                 | 1:N          | potpisuje             | Jedan zaposlenik može sklopiti/odobriti više ugovora, jedan ugovor sklapa/odobrava jedan zaposlenik      |
| zaposlenik       | raspored_rada          | 1:N          | radi_smjene           | Jedan zaposlenik ima više rasporeda rada, jedan raspored pripada jednom zaposleniku                      |
| zaposlenik       | narudzba               | 1:N          | kreira                | Jedan zaposlenik može kreirati više narudžbi, jedna narudžba je kreirana od jednog zaposlenika           |
| zaposlenik       | prodajni_cilj          | 1:N          | ima_zadano            | Jedan zaposlenik ima više zadanih ciljeva, jedan cilj je zadat jednom zaposleniku                        |
| smjena           | raspored_rada          | 1:N          | izvršava_se           | Jedna smjena se izvršava kroz više rasporeda rada, jedan raspored izvršava jednu smjenu                  |
| ugovor           | garancija              | 1:N          | uključuje             | Jedan ugovor može uključivati više garancija, jedna garancija pripada jednom ugovoru                     |
| dobavljac        | narudzba               | 1:N          | prima                 | Jedan dobavljač prima više narudžbi, jedna narudžba se šalje jednom dobavljaču                           |
| narudzba         | stavka_narudzbe        | 1:N          | sadrži                | Jedna narudžba sadrži više stavki, jedna stavka pripada jednoj narudžbi                                  |
| narudzba         | novi_automobil         | 1:N          | rezultira_automobilom | Jedna narudžba može rezultirati više automobila, jedan novi automobil nastaje iz jedne narudžbe          |
| paket_opreme     | oprema                 | 1:N          | definira              | Jedan paket definira više opreme, jedna oprema može pripadati jednom paketu                              |
| servis           | servisna_stavka        | 1:N          | sadrži                | Jedan servis sadrži više stavki, jedna stavka pripada jednom servisu                                     |
| paket_opreme     | oprema                 | N:M          | sadrži                | Jedan paket može sadržavati više opreme, jedna oprema može biti u više paketa                            |
| automobil        | oprema                 | N:M          | ima                   | Jedan automobil može imati više opreme, jedna oprema može biti ugrađena u više automobila                |

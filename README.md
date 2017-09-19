# About 
This work present homework number 2, part 2 for the school year 2016/2017 in [Digital Signal Processing](http://tnt.etf.rs/~oe3dos/) in the 3rd year, Department of Electronics, School of Electrical Engineering, University of Belgrade.

# About the homework number 2 in Serbian
Cilj drugog domaćeg zadatka je da studenti samostalno probaju osnovne metode projektovanja IIR filtara i da projektovane filtre iskoriste za filtriranje signala u određenim primerima.

Domaći zadatak se sastoji iz dva dela. Prvi deo domaćeg zadatka se sastoji od projektovanja IIR filtara propusnika opsega kojim se prepoznaje pozvani broj kod dvotonskog signaliziranja. Drugi deo domaćeg zadatka je primena IIR filtra u interpolaciji i promeni učestanosti odabiranja signala prilikom prelaska sa jednog na drugi audio standard. Cilj drugog dela je i da studenti vide kako na spektar utiče promena učestanosti odabiranja.

# Text of the task in Serbian
Vaš asistent je pronašao veoma retku gramofonsku ploču sa pesmom “Avalon” iz 1920. godine. Ploča je takođe iz 20ih godina XX veka. Međutim, tadašnje ploče su pravljene za gramofone koji su okretali ploče sa 78 rotacija u minuti, a takav gramofon je danas jako teško naći. Zbog toga je vaš asistent pustio ploču na gramofonu koji radi sa 33 rpm. Audio izlaz gramofona je povezao na AD konvertor zvučne kartice i snimio celu pesmu sa učestanošću odabiranja od 44,1 kHz. Međutim, kada je pustio snimak u audio plejeru, doživeo je neprijatno iznenađenje. Snimak je, naravno, 78/33 = 26/11 puta sporiji nego što je originalna pesma. Pomozite svom asistentu da reši problem i napravite .wav fajl koji se može slušati na 44,1 kHz, ali kod koga je tempo pesme ispravan.

Da je broj rotacija u minuti gramofona koji je korišćen za snimanje 2 ili 3 puta manji od 78 rpm za koliko je namenjena ploča, problem bi se lako otklonio uzimanjem svakog drugog odnosno svakog trećeg odbirka snimljene sekvence. Međutim, odnos 26/11 nije ceo broj. Jasno je, takođe, da bi ispravna sekvenca trebalo da ima 26/11 puta manje odbiraka od snimljene sekvence. Zbog toga je u ovom zadatku potrebno najpre povećati broj odbiraka snimljene sekvence 11 puta, a zatim za izlaznu sekvencu uzeti svaki 26. odbirak te produžene sekvence. Produžena sekvenca se dobija interpolacijom, a u daljem tekstu će biti objašnjeno kako je najlakše uraditi navedenu interpolaciju.

Na slici 2 je prikazan primer 3 tipa interpolacije. Najjednostavniji način je dodavanjem nula između dva susedna odbirka. Ovaj način neće dati dobre rezultate, a videćemo i zašto. Bolji rezultati se dobijaju ponavljanjem odbiraka što predstavlja konvoluciju signala kome su dodate nule sa signalom [1 1 1 1]. Navedeni signal ima dejstvo niskofrekventnog filtra jer je pravougaoni signal u vremenu sinc u frekvencijskom domenu. Bolji NF filtar je linearni interpolator čiji je impulsni odziv signal [0,25 0,5 0,75 1 0,75 0,5 0,25] i rezultat linearne interpolacije je dat na četvrtom grafiku sa slike 2.

![1](https://user-images.githubusercontent.com/16638876/30590670-f116609a-9d3f-11e7-941f-9a5df12f451d.png)

Kako bismo detaljnije razumeli postupak interpolacije, posmatrajmo spektar signala kome su dodate nule između svaka dva odbirka, tj. signala

![2](https://user-images.githubusercontent.com/16638876/30590717-1cb7e1a6-9d40-11e7-8d8b-ba4079009649.png)

gde je x[n] originalni signal, a U = 4 u primeru sa slike 2. Z transformacija signala y[n] je

![3](https://user-images.githubusercontent.com/16638876/30590742-410df130-9d40-11e7-901e-9a218eba190c.png)

Na osnovu veze između Furijeove i Z transformacije gde je z = exp(jΩ), zaključujemo da je spektar signala y[n] isti spektar kao i spektar signala x[n], samo što mu je frekvencijska osa sabijena U puta. Na slici 3 je prikazan spektar nekog signala i signala kod koga je U = 3. Periodično ponovljeni spektri na visokim učestanostima formiraju nagle promene signala. Interpolacija se dobija poništavanjem ovih periodično ponovljenih delova spektra i zadržavanjem samo osnovnog opsega. Potrebno je projektovati filtar kojim se izdvaja samo osnovni spektar signala.

![4](https://user-images.githubusercontent.com/16638876/30590780-69a184ea-9d40-11e7-886f-29a7109a14ff.png)

1. Iz audio sekvence avalon_44k.wav učitati nekoliko sekundi snimljenog signala. Nacrtati spektar ovog signala. Dodavanjem nula između odbiraka napraviti signal koji je 11 puta duži i nacrtati spektar tog signala.

2. Projektovati niskofrekventni filtar kojim se filtriraju svi periodično ponovljeni spektri. Za projektovanje koristiti impulsno invarijantnu transformaciju. Na osnovu faznih karakteristika različitih analognih aproksimacija odrediti koja aproksimacija najviše odgovara ovoj primeni i nju odabrati za projektovanje analognog prototipa. Izvršiti softversku proveru da li filtar zadovoljava predefinisane gabarite koje je potrebno odrediti empirijski i ako ne zadovoljava iterativno menjati zadate gabarite kako bi se ostvarili predefinisani (ova provera mora da postoji). Slabljenje u nepropusnom opsegu treba da bude dovoljno veliko tako da se na izlazu dobija zvučna sekvenca koja prijatno zvuči. Obratiti pažnju da se ne mogu istovremeno ostvariti jako veliko slabljenje i jako uska prelazna zona, pa stoga usvojiti odgovarajuće kompromise. Nacrtati fazni i amplitudski spektar projektovanog filtra.

3. Signal kome su dodate nule filtrirati korišćenjem filtra iz tačke 2 i iz rezultata filtriranja za krajnji rezultat uzeti svaki 26. odbirak. Rezultat sačuvati u izlaznu sekvencu avalon_OK.wav i proveriti da li je obrada bila uspešna. Obično se loše isfiltrirani signal čuje kao ispravan signal na koga je superponirano neprijatno zujanje.

Obeležiti sve ose odgovarajućim oznakama/tekstom. U kodu komentarima jasno naznačiti koji deo koda se odnosi na koji deo zadatka. Sve fajlove vezane za ovaj zadatak priložiti uz izveštaj. Nije potrebno slati rezultate obrade pošto će fajlovi biti veliki, dovoljno je poslati samo kodove.


## **Pagrindiniai Konceptai (Terraform Concepts)**

*Čia aiškiname „statybines medžiagas“.*

### **1\. Providers (Tiekėjai)**

Terraform pats savaime nežino, kaip sukurti serverį AWS ar „DigitalOcean“. Jam reikia „vertėjo“.  
* **Esmė:** Provider'iai yra įskiepiai (plugins), kurie leidžia Terraform bendrauti su konkrečių debesų API (AWS, Azure, Google Cloud, Kubernetes ir kt.).  
* **Pavyzdys:** ```provider "aws" { region \= "us-east-1" }```

### **2\. Resources (Resursai / Ištekliai)**

Tai yra svarbiausia dalis. Tai konkretūs objektai, kuriuos sukuriame.  
* **Esmė:** Kiekvienas resursas priklauso tam tikram provider'iui.  
* **Pavyzdys:** Virtuali mašina (aws\_instance), duomenų bazė, IP adresas, ugniasienės taisyklė.  
* **Sintaksė:** ```resource "tipas" "vardas" { ...nustatymai... }```

### **3\. Variables (Kintamieji)**

Kad nereikėtų kodo rašyti "hardcode" stiliumi , naudojame kintamuosius. Tai leidžia tą patį kodą naudoti skirtingoms aplinkoms (DEV, STAGE, PROD).  
* **Tipai:**  
  * **Input Variables:** Parametrai, kuriuos paduodame (pvz., serverio dydis, regionas).  
  * **Output Values:** Informacija, kurią gauname po sukūrimo (pvz., serverio IP adresas).  
  * **Local Values:** Laikini kintamieji skaičiavimams kodo viduje.

### **4\.State (Būsena)** 
Tai yra Terraform „atmintis“. Be jos Terraform nežinotų, ką jau sukūrė.**

* **Failas:** Dažniausiai tai terraform.tfstate failas (JSON formatu).  
* **Kaip veikia:** State faile Terraform sujungia jūsų parašytą kodą su realiais objektais debesyje (pvz., kodas resource "aws\_s3\_bucket" "b" atitinka realų bucket'ą su ID my-bucket-123).  
* **Svarbu:** State failas turi būti saugomas saugiai (dažniausiai nuotoliniu būdu, pvz., S3), nes ten gali būti slaptažodžių, ir tam, kad komanda galėtų dirbti kartu.

---

## **Komandos ir Darbo Eiga (Workflow)**

### **1\. terraform init (Inicijavimas)**

* **Kada naudoti:** Patį pirmą kartą atsisiuntus kodą arba pridėjus naują provider'į/modulį.  
* **Ką daro:**  
  * Nuskaito kodą ir supranta, kokių provider'ių reikia.  
  * Atsisiunčia tų provider'ių dvejetainius failus (plugins) į .terraform aplanką.  
  * Paruošia backend'ą (kur bus saugomas State failas).  
* **Analogiija:** Tai lyg įrankių dėžės atsinešimas prieš statybas.

### **2\. terraform plan (Planavimas / Peržiūra)**

* **Kada naudoti:** Visada prieš darant pakeitimus.  
* **Ką daro:**  
  * Palygina jūsų kodą su State failu ir realia situacija debesyje.  
  * Parodo, kas bus padaryta:  
    * \+ (žalia) – bus sukurta.  
    * \- (raudona) – bus ištrinta.  
    * \~ (geltona) – bus pakeista (updated).  
* **Svarbu:** Tai „saugus“ veiksmas, niekas dar nekeičiama. Tai lyg brėžinio peržiūra.

### **3\. terraform apply (Vykdymas)**

* **Kada naudoti:** Kai esate patenkinti tuo, ką parodė plan.  
* **Ką daro:**  
  * Atlieka realius veiksmus (kreipiasi į API).  
  * Sukuria, pakeičia arba ištrina resursus.  
  * Atnaujina terraform.tfstate failą su naujausia informacija.  
* **Pastaba:** Dažnai prašo patvirtinimo (yes).

### **4\. terraform destroy (Sunaikinimas)**

* **Kada naudoti:** Kai norite viską ištrinti (pvz., baigėsi testavimas, naikinama aplinka).  
* **Ką daro:** Ištrina visus resursus, kurie aprašyti kode ir egzistuoja state faile.  
* **Įspėjimas:** Naudoti labai atsargiai\!

### **5\. terraform state (Būsenos valdymas)**

* *Tai skiriasi nuo „State koncepto“. Čia kalbama apie komandas darbui su būsena.*  
* **Kada naudoti:** Pažengusiems veiksmams (troubleshooting, refactoring).  
* **Populiarios sub-komandos:**  
  * terraform state list – parodo visus sekamus resursus.  
  * terraform state show \<adresas\> – parodo detalią info apie vieną resursą.  
  * terraform state rm – nustoja sekti resursą (ištrina iš state failo, bet palieka debesyje).  
  * terraform state mv – pervadina resursą state faile (naudojama refaktorinant kodą).


## **Praktinė dalis**
Žingsniai:
1. Apžiūrėti ```main.tf```.
2. Susipažinti ir išnagrinėti: ```providers```, ```variables```, ```resource``` ir ```output``` blokus.
3. Užpildyti ```terraform.tfvars``` failą:
- Project: ```aivaras-s-sandbox```
- Region: ```europe-west3```
- bucket_name: ```<vardas>-<pavarde>-<data be tarpų>```
- bucket_location: europe-west3.  
**Svarbu:** bucket\_name turi būti **unikalus visame pasaulyje** (ne tik jūsų projekte). Jei toks vardas jau egzistuoja pas kitą Google vartotoją, gausite klaidą. Rekomenduojama naudoti mažąsias raides, skaičius, brūkšnius (-) arba pabraukimus (\_).
4. Išsaugoti pakeitimus ```terraform.tfvars``` faile.
5. Paleiskite komandą ```terraform init```
6. Atkreipti dėmesį į atsiradusią ```.terraform``` direktoriją.
7. Paleiskite komandą ```terraform validate```
8. Paleiskite komandą ```terraform plan```
9. Paleiskite komandą ```terraform apply```, įrašykite į terminalą ```yes``` ir paspauskite ```Enter```.
10. Atsidaryti ir apžiūrėti ```State``` failą.
11. Paleiskite komandą ```terragrunt destroy```, įrašykite į terminalą ```yes``` ir paspauskite ```Enter```.
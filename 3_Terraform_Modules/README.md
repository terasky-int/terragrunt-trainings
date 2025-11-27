Terraform moduliai yra esminis žingsnis pereinant nuo paprastų infrastruktūros skriptų prie profesionalaus, keičiamo dydžio (scalable) ir tvarkingo kodo valdymo. Tai tarsi perėjimas nuo „spageti kodo“ prie funkcinio programavimo.

### **1\. Įžanga: Kodėl mums reikia modulių?**

* **Problema:** Kopijuojamas kodas (Copy-Paste). Jei turime 10 serverių ir norime pakeisti vieną parametrą, turime keisti 10 vietų.  
* **Sprendimas:** **DRY** (Don't Repeat Yourself) principas.  
* **Analogija:** Moduliai yra kaip „funkcijos“ programavime arba „LEGO kaladėlės“. Tu sukuri vieną kaladėlę (pvz., standartizuotą saugyklą) ir naudoji ją daug kartų.


### **2\. Modulio Anatomija (Struktūra)**

Paaiškink, iš ko susideda standartinis modulis. Tai nėra magija – tai tiesiog aplankas su .tf failais.

Standartinė failų struktūra:

* ```main.tf```: Pagrindinė logika (resursai).  
* ```variables.tf```: **Input** (įvesties parametrai) – tarsi funkcijos argumentai.  
* ```outputs.tf```: **Output** (išvesties reikšmės) – ką modulis grąžina (pvz., sukurto serverio IP).  
* ```README.md```: Dokumentacija (būtina gerai praktikai).

---

### **4\. Modulių šaltiniai (Module Sources)**

Paaiškink, kad moduliai nebūtinai turi būti vietiniame diske.

1. **Local Paths:** ```./modules/my-module``` (geriausia mokymuisi ir testavimui).  
2. **Terraform Registry:** Vieši, bendruomenės sukurti moduliai (pvz., oficialus AWS VPC modulis). Tai sutaupo daug laiko.  
3. **Git (GitHub/GitLab):** Privatiems įmonės moduliams.  
   * *Pavyzdys:* ```source \= "git::https://github.com/my-org/terraform-modules.git//aws-vpc?ref=v1.0.0"```

**Svarbu:** Versijavimas (?ref=v1.0.0). Niekada nenaudokite latest versijos gamybinėje aplinkoje (Production), nes pasikeitus moduliui, gali „sugriūti“ infrastruktūra.

---

### **5\. Gerosios praktikos (Best Practices)**

* **Versijavimas:** Visada naudokite versijas (Git tags).  
* **Dokumentacija:** Naudokite įrankius kaip terraform-docs, kad automatiškai sugeneruotumėte aprašymus.  
* **Kapsuliavimas (Encapsulation):** Modulis turi daryti vieną dalyką gerai. Nekurkite „Dievo modulio“, kuris sukuria visą tinklą, serverius ir duomenų bazes viename.  
* **Defaults:** Naudokite protingas numatytąsias reikšmes variables.tf, kad modulį būtų lengva naudoti nekonfigūruojant kiekvienos smulkmenos.

---

### **6\. Praktinė užduotis**

Iš prieš tai sukurto terraform skripto (direktorija ```2_Terraform_Basics```) reikės sukurti modulį ir jį panaudoti kitame modulyje.

1. Iš direktorijos ```2_Terraform_Basics``` ```main.tf``` failo:
    - Nukopijuokite visus ```provider``` blokus į ```3_Terraform_Modules\bucket_module\provider.tf``` failą.
    - Nukopijuokite visus ```variable``` blokus į ```3_Terraform_Modules\bucket_module\varialbes.tf``` failą.
    - Nukopijuokite visus ```provider``` blokus į ```3_Terraform_Modules\bucket_module\provider.tf``` failą.
    - Nukopijuokite visus ```output``` blokus į ```3_Terraform_Modules\bucket_module\outputs.tf``` failą.      
2. Peržiūrėkite ```3_Terraform_Modules\provider.tf``` failą. Atkreipkite į ```teraform``` bloką.
3. Peržiūrėkite ```3_Terraform_Modules\variables.tf``` failą.
4. Atsidarykite ```3_Terraform_Modules\main.tf``` failą ir padarykite pakeitimus bloke ```
module "bucket" {

}
```
    - asd
1. 
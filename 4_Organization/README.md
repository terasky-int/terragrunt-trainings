# **Organizacijos kūrimas**

## **Diegimo tvarka**

1. Bootstrap (4_Organization/bootstrap)  
2. \_org (4_Organization/organization\_org/)  
3. \_folders (4_Organization/organization\_org/\<aplanko\_pavadinimas\>/\_folder)  
4. \_projects (4_Organization/organization\_org/\<aplanko\_pavadinimas\>/\<projekto\_pavadinimas\>/\_project)  
5. \_billing (4_Organization/\_billing)  
6. \_logging (4_Organization/\_logging)
7. \_perimeter (4_Organization/\_perimeter)

## **Būtinos sąlygos**

Prieš pradėdami įsitikinkite, kad turite šiuos dalykus:

1. **Įdiegti įrankiai:**  
   * [Terraform](https://www.terraform.io/downloads.html)  
   * [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)  
   * [Google Cloud SDK (gcloud)](https://www.google.com/search?q=%5Bhttps://cloud.google.com/sdk/docs/install%5D\(https://cloud.google.com/sdk/docs/install\))  
2. **GCP teisės:**  
   Turite autentifikuotis kaip vartotojas, turintis aukšto lygio teises organizacijoje. Jums reikės bent:  
   * **Organization Administrator** (roles/resourcemanager.organizationAdmin)  
   * **Billing Account Administrator** (roles/billing.admin)  
3. **GCP autentifikacija:**  
   Autentifikuokite savo vietinę aplinką vykdydami: 
   ```gcloud auth application-default login```

4. **Egzistuojančios „Google“ grupės:**  
   Šiam diegimui reikia, kad jau egzistuotų šios „Google“ grupės. Jums reikės jų el. pašto adresų.  
   * Organization Admins grupė  
   * Billing Admins grupė  
   * Project Creator grupė (-ės)

## **Bootstrap**
### **GCP organizacijos „Bootstrap“ modulis (Terragrunt)**

Šiame dokumente aprašomi žingsniai, kaip įdiegti GCP organizacijos „bootstrap“ modulį naudojant pateiktą „Terragrunt“ konfigūraciją.

Šis modulis skirtas sukurti pamatinius resursus naujai GCP organizacijai. Jis sukuria:

* Dedikuotą „Bootstrap“ aplanką.  
* „Seed“ (pradinį) projektą tame aplanke (pvz., shared-terraform-seed).  
* GCS saugyklą (bucket) „seed“ projekte, skirtą „Terraform“ nuotolinei būsenai (remote state) saugoti (pvz., shared-terraform-seed-tfstate-ca69).  
* Esminius IAM susiejimus organizacijos lygiu (pvz., Organization Admins, Billing Admins, Project Creators).

---

### **Konfigūracija**

Turite redaguoti `terragrunt.hcl`, kad jis atitiktų jūsų organizacijos duomenis.

Atnaujinkite šiuos kintamuosius `inputs = { ... }` bloke:

* `org_id`: Jūsų skaitmeninis GCP organizacijos ID.  
* `billing_account`: Jūsų GCP atsiskaitymo paskyros (Billing Account) ID (pvz., XXXXXX-XXXXXX-XXXXXX).  
* `group_org_admins`: Jūsų esamos „Org Admins“ grupės pilnas el. pašto adresas.  
* `group_billing_admins`: Jūsų esamos „Billing Admins“ grupės pilnas el. pašto adresas.  
* `org_project_creators`: Sąrašas esamų grupių el. paštų, kurioms turėtų būti leista kurti projektus organizacijoje. Pridėkite vartotoją, grupę arba SA (Service Account), kurio vardu vykdote „terragrunt“.

---

### **Diegimo žingsniai**

Šis modulis sukuria GCS saugyklą (bucket), kurią naudos savo *paties* nuotolinei būsenai. Tai sukuria „vištos ir kiaušinio“ problemą: negalite saugoti būsenos saugykloje, kuri dar neegzistuoja.

Sprendimas yra dviejų žingsnių procesas:

1. Pirmiausia diekite naudodami **vietinę** (local) sistemą resursams (įskaitant GCS saugyklą) sukurti.  
2. Perkelkite „Terraform“ būseną iš vietinio disko į naujai sukurtą GCS saugyklą.

#### **1 žingsnis: Pradinis diegimas (vietinė būsena)**

Pirmiausia sukonfigūruosite „Terragrunt“, kad būsenos failas būtų saugomas jūsų vietiniame kompiuteryje.

1. Faile `terragrunt.hcl` **užkomentuokite** visą `remote_state { ... }` bloką, skirtą `gcs`.  
2. **Atkomentuokite** `remote_state { ... }` bloką, skirtą `local`.  
   Jūsų failas turėtų atrodyti taip:  
```
   remote_state {
     backend = "local"
     config = {
       path = "${path_relative_to_include()}/terraform.tfstate"
     }
     generate = {
       path      = "backend.tf"
       if_exists = "overwrite"
     }
   }
   # remote_state {  
   #   disable_dependency_optimization = true  
   #   backend                         = "gcs"  
   #   ...  
   # }
```
3. Inicijuokite „Terragrunt“:

   ```terragrunt init```

4. Peržiūrėkite planą:  
     
   ```terragrunt plan```

5. Pritaikykite konfigūraciją. Tai sukurs aplankus, projektus, GCS saugyklą ir IAM susiejimus.    
   ```terragrunt apply```

   Patvirtinkite ```yes``` taikymą (apply), kai būsite paprašyti. Šis žingsnis sukurs GCS saugyklą ir kitus resursus.

6. Iš pritaikyto modulio išvesties (output) nusikopijuokite ```gcs_bucket_name``` ir ```seed_project_id```, kurių reikės kitame žingsnyje.

#### **2 žingsnis: Būsenos perkėlimas į GCS**

Dabar, kai GCS saugykla egzistuoja, galite perkelti savo vietinį būsenos failą (`terraform.tfstate`) į ją.

1. Vėl redaguokite savo ```terragrunt.hcl``` failą.  
2. **Užkomentuokite** `local` backend bloką.  
3. **Atkomentuokite** `gcs` backend bloką ir atnaujinkite ```project``` naudodami ankstesnio žingsnio išvestį ```seed_project_id``` bei ```bucket``` naudodami ankstesnio žingsnio išvestį ```gcs_bucket_name```.  
   Jūsų failas turėtų atrodyti kaip originalas:  
```
   # remote_state {
   #   backend = "local"
   #   config = {
   #     path = "${path_relative_to_include()}/terraform.tfstate"
   #   }
   #   generate = {
   #     path      = "backend.tf"
   #     if_exists = "overwrite"
   #   }
   # }

   remote_state {  
     disable_dependency_optimization = true  
     backend                         = "gcs"  
     generate = {  
       path      = "backend.tf"  
       if_exists = "overwrite"  
     }

     config = {  
       project  = "<reikšmė iš seed_project_id output>"  
       location = "europe-west4"  
       bucket   = "<reikšmė iš gcs_bucket_name output>"  
       prefix   = "bootstrap/terraform.tfstate"  
     }  
   }
```
4. Vėl paleiskite init. „Terragrunt“ aptiks backend pakeitimą ir pasiūlys perkelti jūsų būseną.  
   ```terragrunt init -migrate-state```

   Terraform paklaus: „Do you want to copy the state from "local" to "gcs"?“  
   Įveskite ```yes``` ir paspauskite Enter.  
5. Jūsų būsena dabar yra GCS. Paleiskite `apply` dar kartą, kad įsitikintumėte, jog viskas sinchronizuota. Jokių pakeitimų neturėtų būti rodoma.  
   ```terragrunt apply```


## **Organizacija**

### **GCP organizacijos „Terragrunt“ diegimas (_org aplankas)**
Naudojamas „Google Cloud Foundation Fabric“ (CFF) organizacijos modulis, skirtas valdyti IAM, organizacijos politiką, resursų žymas (tags) ir kitus organizacijos lygio nustatymus.

---

### **Modulis ir priklausomybės**

Organizacijos aplanko kūrimo vietoje (`organization`) atidarykite ```root.hcl``` ir atlikite pakeitimus:
* Atnaujinkite ```remote_state``` bloką:
  * ```project``` - projekto ID, kur bus patalpinti jūsų terraform būsenos failai.
  * ```bucket``` - saugyklos (bucket) pavadinimas projekte, kur bus patalpinti terraform būsenos failai.
* Atnaujinkite ```locals``` bloko kintamuosius:
  * ```organization_id``` - Unikalus skaitmeninis jūsų „Google Cloud“ organizacijos identifikatorius. Šis ID naudojamas taikant politiką ir teises aukščiausiame resursų hierarchijos lygyje.
  * ```billing_account``` - Unikalus jūsų „Google Cloud“ atsiskaitymo paskyros identifikatorius. Ši paskyra susieta su projektais, kad būtų galima apmokėti už resursų naudojimą.
  * ```quota_project``` - Nurodo konkretaus projekto ID, kuris bus naudojamas API kvotoms ir atsiskaitymo operacijoms „Terraform“ tikslais. „Google“ API, įskaitant tas, kurias naudoja „Terraform“, turi kvotas. Nurodydami konkretų `quota_project`, užtikrinate, kad visi „Terragrunt“/„Terraform“ atliekami API iškvietimai būtų apmokestinami pagal šį projektą ir naudotų jo kvotas. Gali būti tas pats kaip „seed“ projektas.
  * ```organization_domain``` - Pagrindinis domeno vardas, susietas su jūsų „Google Cloud“ organizacijos („Google Workspace“/„Cloud Identity“) paskyra. Naudojamas kuriant grupių el. pašto adresus (pvz., grupe@<organizacijos_domenas>).
  * ```region``` -  Nustato numatytąjį „Google Cloud“ regioną, kuriame bus diegiami resursai, jei nenurodyta kitaip. Tai padeda užtikrinti, kad resursai būtų kuriami nuoseklioje geografinėje vietoje.
  * ```project_prefix``` - Trumpas eilutės priešdėlis, naudojamas generuojant naujų projektų ID.
  * ```default_budget_notification_project``` -  Projekto ID, kuriame yra „Pub/Sub“ tema (topic), naudojama gaunant pranešimus apie biudžetą. Biudžetai nustatomi atsiskaitymo paskyroje, o šis projektas suteikia mechanizmą („Pub/Sub“ temą) programiniams įspėjimams gauti, kai išlaidos viršija nustatytas ribas. Gali būti tas pats kaip „seed“ projektas.
  * ```prefix``` - priešdėlis naudojamas resursams kurti.
  * ```region_trigram``` - sutrumpinimas regionui.
  * ```client_name``` - : euw4 (sutrumpinimas regionui europe-west4).
  * ```client_name``` - : euw4 (sutrumpinimas regionui europe-west4).
client_name: cst (kliento kodas arba padalinio trumpinys).

env: prod (aplinka – Production). 

* Organizacijos aplanko kūrimo vietoje (`4_Organization/organization/_org`) atidarykite ```terragrunt.hcl``` ir atlikite pakeitimus: 
  * ```locals``` blokas:
    * ```gcp_groups_roles``` - grupių priešdėlis (grupės pavadinimas iki @) su vaidmenų (roles), kuriuos reikia priskirti grupei, sąrašu.  
    * ```org_policies``` - organizacijos politikos konfigūracija.
    * ```custom_roles``` - jei reikia, GCP pasirinktiniai vaidmenys (custom roles) su jiems priskirtų teisių sąrašu.
  * ```inputs``` blokas:
    * ```tags``` - žymų (tags) konfigūracija. Žymos pagal rakto pavadinimą. Jei pateikiamas ID, rakto arba reikšmės kūrimas praleidžiamas.


### **Aktyvios grupės ir vaidmenys**

* **gcp-customer-org-all-vssa_admins**: Tai yra super-administratorių grupė, turinti beveik neribotas teises valdyti visą organizaciją, jos struktūrą, saugumą ir finansus. 
  * roles/organizationAdmin  
  * roles/owner  
  * roles/resourcemanager.projectCreator  
  * roles/compute.xpnAdmin (Shared VPC Admin)  
  * roles/billing.user  
  * roles/securitycenter.admin  
  * ...ir kiti aukšto lygio administraciniai vaidmenys.  

* **gcp-customer-org-all-customer_admins**: Tai kliento administratorių grupė. Jie turi daug teisių valdyti savo resursus (tinklus, projektus), tačiau jiems apribotos teisės keisti pačią organizacijos struktūrą, politikas ar matyti finansinius duomenis (remiantis komentarais kode). 
  * roles/compute.xpnAdmin: Gali administruoti Shared VPC tinklus.
  * roles/resourcemanager.folderAdmin: Gali valdyti aplankų struktūrą (organizuoti savo projektus).
  * roles/resourcemanager.projectCreator: Gali kurti naujus projektus.
  * roles/securitycenter.admin: Gali matyti ir valdyti saugumo pranešimus.
  * roles/cloudsupport.admin: Gali bendrauti su „Google“ technine pagalba.

* **gcp-customer-org-all-customer_viewers**: Štai išsami šio „Terraform“ kodo analizė. Jame apibrėžiamos trys vartotojų grupės ir joms suteikiamos teisės (IAM roles) organizacijos lygiu.

Žemiau pateikiu, ką tiksliai reiškia kiekviena rolė lietuvių kalba ir kokias galias ji suteikia.

1. Grupė: gcp-customer-org-all-vssa_admins
Tai yra super-administratorių grupė (tikriausiai paslaugų tiekėjo arba pagrindinės IT komandos), turinti beveik neribotas teises valdyti visą organizaciją, jos struktūrą, saugumą ir finansus.

roles/billing.user (Billing Account User): Leidžia susieti projektus su mokėjimo sąskaita. Tai reiškia, kad jie gali kurti resursus, kurie kainuoja pinigus, priskirdami juos konkrečiam biudžetui.

roles/compute.xpnAdmin (Compute Shared VPC Admin): Leidžia konfigūruoti „Shared VPC“. Tai tinklo sprendimas, kai vienas pagrindinis projektas valdo tinklą, o kiti projektai juo naudojasi.

roles/resourcemanager.folderAdmin: Leidžia pilnai valdyti aplankus (Folders) – juos kurti, trinti, perkelti ir keisti jų teises. Aplankai naudojami projektams grupuoti.

roles/iam.denyAdmin: Suteikia teisę kurti „Deny Policies“ (draudimo politikas). Tai aukšto lygio saugumo funkcija, leidžianti griežtai uždrausti tam tikrus veiksmus, nepriklausomai nuo to, kokias kitas teises vartotojas turi.

roles/resourcemanager.organizationAdmin: Viena galingiausių rolių. Leidžia valdyti visą organizaciją, priskirti teises kitiems administratoriams ir matyti visą resursų hierarchiją.

roles/orgpolicy.policyAdmin: Leidžia nustatyti organizacijos politikas (pvz., „galima kurti resursus tik Europoje“ arba „draudžiama naudoti viešus IP adresus“).

roles/iam.organizationRoleAdmin: Leidžia kurti ir valdyti Custom Roles (nestandartines roles) visos organizacijos lygiu.

roles/owner: Klasikinė, pati plačiausia rolė. Savininkas turi pilną prieigą prie visų resursų, gali valdyti prieigas ir trinti viską.

roles/resourcemanager.projectCreator: Suteikia teisę kurti naujus projektus.

roles/securitycenter.admin: Pilna prieiga prie „Security Center“. Leidžia matyti saugumo spragas, grėsmes ir konfigūruoti saugumo nustatymus.

roles/cloudsupport.admin: Leidžia kurti ir valdyti techninės pagalbos (Google Support) užklausas.

2. Grupė: gcp-customer-org-all-customer_admins
Tai kliento administratorių grupė. Jie turi daug teisių valdyti savo resursus (tinklus, projektus), tačiau jiems apribotos teisės keisti pačią organizacijos struktūrą, politikas ar matyti finansinius duomenis (remiantis komentarais kode).

roles/compute.xpnAdmin: Gali administruoti Shared VPC tinklus.

roles/resourcemanager.folderAdmin: Gali valdyti aplankų struktūrą (organizuoti savo projektus).

roles/resourcemanager.projectCreator: Gali kurti naujus projektus.

roles/securitycenter.admin: Gali matyti ir valdyti saugumo pranešimus.

roles/cloudsupport.admin: Gali bendrauti su „Google“ technine pagalba.

Svarbus skirtumas: Ši grupė neturi roles/owner, roles/billing.user (pagal komentarą, tai tvarkoma atskirai), roles/resourcemanager.organizationAdmin ar roles/orgpolicy.policyAdmin. Tai reiškia, kad jie negali pakeisti fundamentalių organizacijos taisyklių ar perimti pilnos kontrolės iš tiekėjo.

3. Grupė: gcp-customer-org-all-customer_viewers
Tai stebėtojų grupė, skirta auditoriams arba vadovams, kuriems reikia tik matyti situaciją.
  * roles/viewer: Suteikia „tik skaitymo“ (read-only) prieigą prie beveik visų resursų. Jie gali peržiūrėti konfigūracijas, bet negali nieko keisti, trinti ar kurti.

### **Organizacijos politika**

Tai pati plačiausia konfigūracijos dalis. `local.org_policies` žemėlapis (map) apibrėžia griežtą saugumo ir valdymo apribojimų rinkinį, taikomą visiems organizacijos projektams.

**Pagrindinės taikomos politikos:**

* **Saugumas ir IAM:**  
  * iam.managed.disableServiceAccountKeyCreation: **Išjungia** statinių „Service Account“ raktų kūrimą (svarbi saugumo praktika).  
  * iam.allowServiceAccountCredentialLifetimeExtension: **Draudžia** visas užklausas pratęsti „Service Account“ kredencialų galiojimo laiką.  
  * iam.managed.preventPrivilegedBasicRolesForDefaultServiceAccounts: Neleidžia numatytosioms „Service Accounts“ (pvz., „Compute Engine“ numatytoji SA) suteikti „Owner“, „Editor“ ar „Viewer“ vaidmenų.  
  * compute.requireOsLogin: **Priverstinai taiko** „OS Login“ visiems SSH prisijungimams prie VM, centralizuojant prieigos valdymą per IAM.  
  * compute.requireShieldedVm: **Priverstinai taiko**, kad visi nauji VM turi būti „Shielded VM“.  
* **Tinklas ir prieigos kontrolė:**  
  * compute.skipDefaultNetworkCreation: **Užkerta kelią** nesaugus „default“ VPC tinklo kūrimui naujuose projektuose.  
  * compute.vmExternalIpAccess: **Draudžia** išorinių IP adresų kūrimą visiems VM, priverčiant resursus pagal nutylėjimą būti tik vidiniais.  
  * sql.restrictPublicIp & ainotebooks.restrictPublicIp: **Apriboja** viešus IP „Cloud SQL“ instancijoms ir „Vertex AI Notebooks“.  
  * storage.publicAccessPrevention: **Priverstinai taiko** viešos prieigos prevenciją visoms „Cloud Storage“ saugykloms.  
* **GKE (Kubernetes Engine):**  
  * container.managed.enablePrivateNodes: **Priverstinai taiko**, kad nauji GKE klasteriai turi naudoti privačius mazgus (nodes).  
  * container.managed.enableSecretsEncryption: **Priverstinai taiko** aplikacijų lygmens paslapčių (secrets) šifravimą GKE.  
  * container.managed.disallowDefaultComputeServiceAccount: **Užkerta kelią** GKE mazgų grupėms (node pools) naudoti numatytąją „Compute Engine“ tarnybinę paskyrą (SA).  
* **Paslaugų ir resursų valdymas:**  
  * gcp.restrictServiceUsage: **Apriboja**, kurios „Google“ API gali būti įjungtos. Leidžiamos tik aiškiai išvardytos paslaugos (pvz., compute.googleapis.com, storage.googleapis.com, bigquery.googleapis.com).  
  * gcp.resourceLocations: **Apriboja**, kur gali būti kuriami resursai, limituojant juos iki konkretaus JAV ir Europos regionų sąrašo.  
  * resourcemanager.allowedExportDestinations: **Draudžia** visus resursų eksportavimus į kitas organizacijas.  
  * compute.trustedImageProjects: **Apriboja** VM atvaizdus (images) iki patikimų projektų rinkinio (pvz., cos-cloud, ubuntu-os-cloud, windows-cloud).

### **Pastebėjimai**
Kai kurios organizacijos politikos gali išmesti klaidą:
```
Error: Error creating Policy: googleapi: Error 409: Requested entity already exists
```
Ši klaida atsiranda, kai organizacijos politika jau egzistuoja standartiškai („out of the box“). Pavyzdys: ```iam.allowedPolicyMemberDomains```
Jei norite valdyti šias politikas naudodami ```terragrunt```, tiesiog importuokite jas į būseną (state):
```
terragrunt import 'google_org_policy_policy.default["<politikos pavadinimas>"]' organizations/<organizacijos id>/policies/<politikos pavadinimas>
```
Pavyzdys su ```iam.allowedPolicyMemberDomains``` politika:
```
terragrunt import 'google_org_policy_policy.default["iam.allowedPolicyMemberDomains"]' organizations/<organizacijos id>/policies/iam.allowedPolicyMemberDomains
```

### **Resursų žymos (Tags)**

`inputs.tags` blokas apibrėžia *taksonomiją* (galimus raktus ir reikšmes) resursų žymoms visoje organizacijoje. Tai nepritaiko žymų, o *sukuria* jas, kad jas būtų galima naudoti projektuose ir resursuose.

* **Raktas:** environment  
  * **Reikšmės:** development, staging, production  
* **Raktas:** team  
  * **Reikšmės:** devops, engineering, data, billing
---

### **Diegimo žingsniai**

Norėdami pritaikyti šią konfigūraciją, vykdykite standartines „Terragrunt“ komandas iš katalogo (4_Organization/organization/_org), kuriame yra šis ```terragrunt.hcl``` failas:

1. **Inicijuoti:**  
   ```terragrunt init```

2. **Planuoti:**  
   ```terragrunt plan```

3. **Pritaikyti:**  
   ```terragrunt apply```


## **Aplankai (Folders)**
### **Struktūra ir vieta**

Šis konfigūracijos failas skirtas būti patalpintas kataloge pavadinimu `_folder`. Šis `_folder` katalogas savo ruožtu turi būti kataloge, kuris apibrėžia norimą GCP aplanko pavadinimą.

#### **Pilnas failų struktūros pavyzdys**
```
.  
├── Env/  
│   ├── _folder/  
│   │   └── terragrunt.hcl  <-- Ši konfigūracija (Sukuria 'Env' aplanką)  
│   ├── Prod/
│   │   └── _folder/
│   │       └── terragrunt.hcl <-- Ši konfigūracija sukuria 'Prod' aplanką 'Env' aplanko viduje 
│   ├── Test/  
│  
├── Infra/  
│   └── _folder/  
│       └── terragrunt.hcl  <-- Ši konfigūracija (Sukuria 'Infra' aplanką)  
│  
└── Sandbox/  
    └── _folder/  
        └── terragrunt.hcl  <-- Ši konfigūracija (Sukuria 'Sandbox' aplanką)  
 
```

Tiesiai po organizacija yra organizacijos pagrindiniai (root) aplankai (sukurti tiesiogiai po organizacija): Env, Infra, Sandbox. Kiekvienas aplanko pavadinimas atitinka GCP Org aplankų pavadinimus.

---

### **Pagrindinio (Root) aplanko konfigūracija**

Kiekvienas pagrindinis organizacijos aplankas turės ```_org``` priklausomybę:
```
dependencies {
  paths = ["../../_org"]
}
```
Įvestys (Inputs):
* locals:
  * gcp_groups_roles - panašiai kaip organizacijos modulyje, galite konfigūruoti papildomas grupių teises aplankui.
* inputs:
  * org_policies - Organizacijos politika, taikoma šiam aplankui, susieta pagal politikos pavadinimą. [Daugiau informacijos](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/folder#organization-policies) 
  * tag_bindings - Žymų susiejimai šiam aplankui, formatu raktas => žymos reikšmės id. [Daugiau informacijos](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/folder#tags)

### **Poaplankio (Sub folder) konfigūracija**
Viskas panašu į pagrindinio aplanko kūrimą, išskyrus priklausomybes. Poaplankiams priklausomybės turėtų atrodyti taip:
```
dependency "parent" {
  config_path = "../../_folder"
}
```

### **Kaip naudoti (Diegimo eiga)**

1. Norėdami sukurti naują aukščiausio lygio aplanką (pvz., Uat), sukurkite naują katalogą struktūros šaknyje: `mkdir Uat`.  
2. Jo viduje sukurkite `_folder` katalogą: `mkdir Uat/_folder`.  
3. Nukopijuokite `terragrunt.hcl` failą iš kito pagrindinio aplanko į `Uat/_folder` katalogą.
4. Atlikite pakeitimus pagal savo poreikius.
5. Sukurkite poaplankių struktūrą. 
6. Nueikite į katalogą: `cd Uat/`.  
7. Vykdykite ```terragrunt apply -all```.  
8. „Terragrunt“ sukurs naują GCP aplanką pavadinimu `Uat` tiesiai po jūsų organizacija.

### **Diegimo žingsniai**

Galiausiai sukūrę visą struktūrą, pereikite per pagrindinius organizacijos aplankus ir vykdykite komandas:

1. **Inicijuoti:**  
   ```terragrunt init -all```

2. **Planuoti:**  
   ```terragrunt plan -all```

3. **Pritaikyti:**  
   ```terragrunt apply -all```

## **Projektai**

### **Struktūra ir vieta**

Šis konfigūracijos failas skirtas būti patalpintas kataloge pavadinimu `_project`. Šis `_project` katalogas savo ruožtu turi būti kataloge, kuris apibrėžia norimą GCP projekto pavadinimą. Pavyzdys: ```4_Organization/organization/Infra/gc-prj-customer-infra-networking/_project```. Šiame pavyzdyje organizacijos aplanke ```Infra``` bus sukurtas projektas ```gc-prj-customer-infra-networking```.

#### **Pilnas failų struktūros pavyzdys**
```
.  
├── Env/  
│   ├── _folder/  
│   ├── Prod/
│   ├── Test/  
...
└── Infra/  
    └── _folder/  
    └── gc-prj-customer-infra-networking/
        └── _project/
            └── terragrunt.hcl <-- Ši konfigūracija sukuria 'gc-prj-customer-infra-networking' projektą 'infra' aplanke. 

```

### **Projekto konfigūracija**

Projekto pavadinimo sukūrimas priklausys nuo aplanko, kuriame patalpintas ```_project``` katalogas, pavadinimo.
Įvestys (Inputs):
* services - Sąrašas GCP API, kurios bus įjungtos šiame projekte sukūrimo metu.
* labels - Rakto-reikšmės etikečių žemėlapis (map), taikomas projektui identifikavimo, filtravimo ir atsiskaitymo tikslais.
* iam, iam\_bindings\_additive, org\_policies, tag\_bindings - papildomos IAM teisės, naudojamos tik projektui. [Daugiau informacijos](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/project#iam)
* tag_bindings - Žymų susiejimai šiam projektui, formatu raktas => žymos reikšmės id. [Daugiau informacijos](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/project#tag-bindings)

### **Kaip naudoti (Diegimo eiga)**

1. Norėdami sukurti naują projektą (pvz., gc-prj-customer-infra-networking), sukurkite naują katalogą ```gc-prj-customer-infra-networking``` su poaplankiu ```_project``` reikiamo organizacijos aplanko viduje. 
2. Nukopijuokite `terragrunt.hcl` failą iš kito ```_project``` aplanko į ```gc-prj-customer-infra-networking/_project``` katalogą.
3. Atlikite pakeitimus pagal savo poreikius.
4. Nueikite į katalogą ```gc-prj-customer-infra-networking/_project```.  
5. Vykdykite ```terragrunt apply```.  
6. „Terragrunt“ sukurs naują GCP projektą jūsų struktūroje ten, kur jį patalpinote.

### **Diegimo žingsniai**

Galiausiai sukūrę projektų katalogus, pereikite per juos po vieną ir vykdykite komandas:

1. **Inicijuoti:**  
   ```terragrunt init```

2. **Planuoti:**  
   ```terragrunt plan```

3. **Pritaikyti:**  
   ```terragrunt apply```

## **Atsiskaitymas (Billing)**
Šis „Terragrunt“ konfigūracijos failas skirtas valdyti resursus, susijusius su „Google Cloud Platform“ (GCP) atsiskaitymo paskyra (Billing Account).

Jo pagrindinė paskirtis yra:

* Nurodyti centrinį „Terraform“ modulį GCP atsiskaitymo valdymui.  
* Dinamiškai sukurti keturis atskirus **GCP Biudžetus**, po vieną kiekvienam pagrindinių aplankų (Env, Infra, Sandbox).  
* Sukonfigūruoti **pranešimų kanalus** (El. paštas ir „Slack“) biudžeto įspėjimams.  

### **Atsiskaitymo konfigūracija**
Atsiskaitymo pranešimų konfigūracija patalpinta ```organization``` katalogo ```_billing``` aplanko ```terraform.hcl``` faile.
Yra sukonfigūruota priklausomybė (dependency) visiems pagrindiniams organizacijos aplankams, kuriems nustatome atsiskaitymo pranešimus. Mūsų atveju – Env, Infra, Sandbox.

Pasiruošimas „Slack“ paslapties (secret) kūrimui aprašytas ```_billing``` aplanko ```Readme.md``` faile.
Po pasiruošimo atnaujinkite įvestis (inputs) pagal poreikį.
Įvestys (Inputs):
**Biudžetai (Budgets)**

`budgets` įvestis apibrėžia keturių biudžetų žemėlapį. Visi keturi vadovaujasi tuo pačiu modeliu:

* **Pagrindinė savybė (amount):** use\_last\_period \= true. Tai sukuria **tempą sekantį biudžetą**. Vietoj fiksuotos sumos, einamojo mėnesio biudžetas automatiškai nustatomas pagal **viso praėjusio mėnesio išlaidas**.  
* **Filtras (resource\_ancestors):** Kiekvienas biudžetas filtruojamas taip, kad būtų taikomas *tik* resursams, esantiems po konkrečiu Verslo Padalinio aplanku (pvz., dependency.bu-ai-ml.outputs.id).  
* **Ribos (Thresholds):** Įspėjimai siunčiami, kai *einamosios* išlaidos pasiekia **75%** ir **100%** *praėjusio mėnesio* visų išlaidų.  
* **Pranešimai (Notifications):** disable\_default\_iam\_recipients \= true sustabdo numatytuosius įspėjimus projektų savininkams/atsiskaitymo administratoriams. monitoring\_notification\_channels \= \["billing-admins"\] nukreipia visus įspėjimus *tik* į žemiau apibrėžtą pasirinktinį „billing-admins“ el. pašto kanalą.

#### **Biudžeto pranešimų kanalai**

Šis žemėlapis apibrėžia įspėjimo kanalus, kuriuos gali naudoti biudžetai.

* **billing-default (Slack):**  
  * Apibrėžia „Slack“ pranešimų kanalą.  
  * Jam reikia vietos rezervavimo reikšmių (placeholder) `channel_name` ir `team`.  
  * Jis nurodo paslaptį (secret) pavadinimu `slack_token` autentifikacijai.  
* **billing-admins (Email):**  
  * Apibrėžia el. pašto pranešimų kanalą.  
  * Šį kanalą **naudoja** visi keturi aukščiau apibrėžti biudžetai.  
  * Jam reikia vietos rezervavimo reikšmės `email_address`.  
* **project\_id:** Abu kanalai sukuriami konkrečiame GCP projekte, kuris paveldimas iš bendros konfigūracijos (include.shared.locals.default\_budget\_notification\_project).

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į ```_billing``` aplanką ir vykdykite:

1. **Inicijuoti:**  
   ```terragrunt init```

2. **Planuoti:**  
   ```terragrunt plan```

3. **Pritaikyti:**  
   ```terragrunt apply```

## **Žurnalų vedimas (Logging) Papidlomas darbas**

**Jei norite atlikti šį žingsnį turite susikurti naują projektą tam arba pernaudoti jau sukurtą**

Ši konfigūracija naudoja „cloud-foundation-fabric“ modulį, kad sukurtų **centralizuotą organizacijos lygio žurnalų rinktuvą (logging sink)**. Pagrindinis tikslas yra surinkti visus žurnalo įrašus iš kiekvieno projekto ir aplanko jūsų „Google Cloud“ organizacijoje ir nukreipti juos į vieną dedikuotą „Cloud Logging“ saugyklą centriniame žurnalų projekte.

Šis metodas yra geriausia praktika saugumui, auditui ir atitikčiai užtikrinti, nes tai garantuoja, kad visi žurnalai yra agreguojami vienoje saugioje, valdomoje vietoje.



### **Logging konfigūracija**
Logging pranešimų konfigūracija patalpinta ```organization``` katalogo ```_logging_``` aplanko ```terragrunt.hcl``` faile.

Atlikite pakeitimus pagal poreikį.
Įvestys (Inputs):
* organization\_id: Tai jūsų „Google Cloud“ organizacijos ID (pvz., organizations/123456789012). Jis dinamiškai gaunamas iš bendro `locals` bloko.  
* logging\_sinks: Šis blokas apibrėžia patį rinktuvą (sink).  
  * central-log-export: Tai draugiškas rinktuvo resurso pavadinimas.  
  * **destination**: Tai svarbiausias nustatymas. Jis apibrėžia, kur bus siunčiami žurnalai.  
    * projects/\<logging projekto id\>/locations/global/buckets/\_Default  
    * Tai nurodo į \_Default žurnalų saugyklą, esančią jūsų centriniame žurnalų projekte.
    * Pakeiskite \<logging projekto id\> į savo centrinio žurnalų projekto ID.   
  * **type \= "logging"**: Nurodo, kad paskirtis yra „Cloud Logging“ saugykla (skirtingai nei „Pub/Sub“, „BigQuery“ ar „Cloud Storage“).  
  * **include\_children \= true**: Tai būtina. Tai užtikrina, kad rinktuvas fiksuos žurnalus iš **visų** esamų ir būsimų poaplankių bei projektų organizacijoje.  
  * **filter \= ""**: Tuščias filtras reiškia, kad bus eksportuojami **visi žurnalai**. Norėdami eksportuoti tik specifinius žurnalus (pvz., audito žurnalus), čia pridėtumėte filtrą (pvz., logName:"cloudaudit.googleapis.com").  
  * **iam \= true**: Šis nustatymas nurodo moduliui automatiškai valdyti IAM teises. Jis sukurs unikalų „service account“ (writer identity) rinktuvui ir suteiks jam reikiamas teises (roles/logging.bucketWriter) paskirties žurnalų saugykloje.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į ```_logging``` aplanką ir vykdykite:

1. **Inicijuoti:**  
   ```terragrunt init```

2. **Planuoti:**  
   ```terragrunt plan```

3. **Pritaikyti:**  
   ```terragrunt apply```

## **Perimetras**

Ši dalis įdiegia „Google Cloud“ (GCP) resursų rinkinį, skirtą valdyti prieigą prie GCP konsolės.

Pagrindinis tikslas yra įgyvendinti **kontekstu paremtą prieigos politiką**, užtikrinant, kad tik konkretūs vartotojai (iš apibrėžtų „Google“ grupių), jungdamiesi iš konkrečių, patikimų IP adresų, galėtų gauti prieigą. Tai yra kritinė saugumo priemonė, greičiausiai įgyvendinta naudojant **GCP Access Context Manager**.

### **Perimetro konfigūracija**
Atlikite pakeitimus pagal poreikį.
Šios reikšmės apibrėžia prieigos politikos pagrindą.

* **whitelisted\_ips**: Sąrašas konkrečių IP adresų (CIDR formatu; /32 reiškia vieną IP). **Tik srautas iš šių IP** bus laikomas patikimu.  
* **group\_emails**: Sąrašas „Google“ grupių el. pašto adresų. **Tik šių grupių nariams** bus suteikta prieiga.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į ```_perimeter``` aplanką ir vykdykite:

1. **Inicijuoti:**  
   ```terragrunt init```

2. **Planuoti:**  
   ```terragrunt plan```

3. **Pritaikyti:**  
   ```terragrunt apply```
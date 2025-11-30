1. sukursime bucket'ą klientui taplpinti terraform/terragrunt state.
2. Kliento rolėje:
2.1. susikonfigūruosime aplinką, kad galėtumėm diegtis resursus
2.2. Susikursime service account'ą Compute engine virtualiai mašinai
2.3. Susikursime Virtualią maišną su sukurtu service account'u ir prijungsime prie VPC
2.4. Susikursime Cloud SQL domenų bazę ir ją prijungsime prie VPC
2.5. Susikursime Cloud Run deploymentą
2.6. Susikursime Application load balancer'į.
2.ų. Susikursime GKE klasterį.


## Bucket (5_Organization/seed-bucket)
#### **1.Konfigūracija**
Iš direktorijos ```5_Resources``` nusikopijuojame ```seed-bucket``` visą direktoriją ir ją patapliname į ```4_Organization/organization/Env/Prod/gc-prj-cst-prod-demo/```.

Atsidarome ```4_Organization/organization/Env/Prod/gc-prj-cst-prod-demo/seed-bucket/terragrunt.hcl``` ir darome pakeitimus:
* ```bucket_name``` - pakeičiame į <projekto pavadinimas>-seed-<4 nesusiję simboliai>. Turėtų atrodyti panašiai: ```gc-prj-cst-prod-demo-seed-k8s9```.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į ```_billing``` aplanką ir vykdykite:

1. **Inicijuoti:**  
   ```terragrunt init```

2. **Planuoti:**  
   ```terragrunt plan```

3. **Pritaikyti:**  
   ```terragrunt apply```

**SVARBU** nusikopijuokit ```bucket_name``` išvestį, sekančiam žingsnyje jo reikės konfigūruojant state konfigūraciją.

## Kliento aplinkos konfigūracija (5_Organization/client-resources)
#### **1.Konfigūracija**

Atsidarome ```5_Organization/client-resources``` direktoriją. Joje yra kliento resursai sudėti į vieną direktoriją. Norint palaikyti DRY principą mums reikia sukonfigūruoti keltą failų:
* ```root.hcl``` - pagrindinis failas kuriame sudėsime state failo konfigūraciją, globalius įvesties kintamuosius. 
* ```env.yaml``` - nurodome aplinkos kintamąjį (prod/test) 
* ```defaults.yaml``` - kitamieji kurie bus naudojami per visus modulius. 

Kliento resursų kūrimo vietoje (`5_Resources/client-resources`) atidarykite ```root.hcl``` ir peržiūrėkite/atlikite pakeitimus:

## Praktinės dalies eiga

1.  Sukursime *bucket'ą* klientui talpinti terraform/terragrunt *state*.
2.  Kliento rolėje:   
    2.1. Susikonfigūruosime aplinką, kad galėtumėm diegtis resursus.   
    2.2. Susikursime *Service Account'ą* Compute Engine virtualiai mašinai.   
    2.3. Susikursime Virtualią mašiną su sukurtu *Service Account'u* ir prijungsime prie VPC.   
    2.4. Susikursime Cloud SQL duomenų bazę ir ją prijungsime prie VPC.   
    2.5. Susikursime Cloud Run deploymentą.   
    2.6. Susikursime Application Load Balancer'į.   
    2.7. Susikursime GKE klasterį.   

## Bucket (5\_Resources/seed-bucket)

#### **1. Konfigūracija**

Iš direktorijos `5_Resources` nusikopijuojame `seed-bucket` visą direktoriją ir ją patalpiname į `4_Organization/organization/Env/Prod/gc-prj-cst-prod-demo/`.

Atsidarome `4_Organization/organization/Env/Prod/gc-prj-cst-prod-demo/seed-bucket/terragrunt.hcl` ir darome pakeitimus:

  * `bucket_name` - pakeičiame į `<projekto pavadinimas>-seed-<4 nesusiję simboliai>`. Turėtų atrodyti panašiai: `gc-prj-cst-prod-demo-seed-k8s9`.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į `seed-bucket` aplanką ir vykdykite:

1.  **Inicijuoti:**

    ```bash
    terragrunt init
    ```

2.  **Planuoti:**

    ```bash
    terragrunt plan
    ```

3.  **Pritaikyti:**

    ```bash
    terragrunt apply
    ```

**SVARBU:** nusikopijuokite `bucket_name` išvestį (*output*), sekančiam žingsnyje jo reikės konfigūruojant *state* konfigūraciją.

## Kliento aplinkos konfigūracija (5\_Resources/client-resources)

#### **1. Konfigūracija**

Atsidarome `5_Resources/client-resources` direktoriją. Joje yra kliento resursai sudėti į vieną direktoriją. Norint palaikyti DRY principą, mums reikia sukonfigūruoti keletą failų:

  * `root.hcl` - pagrindinis failas, kuriame sudėsime *state* failo konfigūraciją, globalius įvesties kintamuosius.
  * `env.yaml` - nurodome aplinkos kintamąjį (prod/test).
  * `defaults.yaml` - kintamieji, kurie bus naudojami per visus modulius.

Kliento resursų kūrimo vietoje (`5_Resources/client-resources`) atidarykite `root.hcl` ir peržiūrėkite/atlikite pakeitimus:

  * `remote_state` blokas:
      * `config` blokas:
          * `bucket` - iš prieš tai sukurto *bucket'o* modulio išvesties parametras `bucket_name`.
          * `project` - jūsų kliento projekto ID `gc-prj-cst-prod-demo-<suffix>`.
          * `location` - "europe-west4".
  * `inputs` blokas:
      * `glb_name` - nurodo globalių vardų naudojimo taisyklę. `"global-${local.common_inputs.client_name}-${local.common_inputs.folder}-${local.common_inputs.env}"`
      * `glb_name_region` - `"${local.common_inputs.region_trigram}-${local.common_inputs.client_name}-${local.common_inputs.env}"`

Kliento resursų kūrimo vietoje (`5_Resources/client-resources`) atidarykite `env.yaml` ir peržiūrėkite/atlikite pakeitimus:

  * `env: prod` - bus naudojama resursų vardų generavimui.

Kliento resursų kūrimo vietoje (`5_Resources/client-resources`) atidarykite `defaults.yaml` ir peržiūrėkite/atlikite pakeitimus:

  * `region: "europe-west4"` - regionas.
  * `region_trigram: "euw4"` - regiono sutrumpinimas.
  * `location: "europe-west4"` - regionas.
  * `project: "gc-prj-cst-prod-demo-<suffix>"` - projekto ID, kuriame resursus kursime.
  * `project_id: "gc-prj-cst-prod-demo-<suffix>"` - projekto ID, kuriame resursus kursime.
  * `client_name: "cst"` - kliento vardas.
  * `vpc: "https://www.googleapis.com/compute/v1/projects/gc-prj-cst-infra-networking-<suffix>/global/networks/gc-vpc-global-cst-infra-prod-01"` - iš Organizacijos kūrimo, VPC žingsnio išsaugota `vpc_self_links` reikšmė.
  * `subnet: "https://www.googleapis.com/compute/v1/projects/gc-prj-cst-infra-networking-<suffix>/regions/europe-west4/subnetworks/gc-sub-euw4-cst-infra-prod-01"` - iš Organizacijos kūrimo, VPC žingsnio išsaugota `vpc_subnet_links = {"europe-west4/gc-sub-euw4-cst-infra-prod-01"}` reikšmė.

**SVARBU:** Jei neatsimenate kintamųjų:

  * `vpc_self_link`
  * `vpc_subnet_links`

Norint juos dar kartą pažiūrėti, galima nunaviguoti į *shared-vpc* direktoriją (`4_Organization/organization/Infra/gc-prj-cst-infra-networking-<suffix>/shared-vpc`) ir paleisti komandą:

```bash
terragrunt output
```

## Service Account (5\_Resources/client-resources/service-account)

#### **1. Konfigūracija**

Service account resursų kūrimo vietoje (`5_Resources/client-resources/service-account`) atidarykite `terragrunt.hcl` ir peržiūrėkite/atlikite pakeitimus:

  * `inputs` blokas:
      * `name` - `"sa-${include.shared.inputs.glb_name}-vm"`. Service account vardas, gale vietoj `-vm` nurodykite paskirtį arba galite palikti `-vm`.
      * `display_name` - Toks pats kaip ir `name`.
      * `description` - Jūsų Service account apibūdinimas. Užpildykite.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į `service-account` aplanką ir vykdykite:

1.  **Inicijuoti:**

    ```bash
    terragrunt init
    ```

2.  **Planuoti:**

    ```bash
    terragrunt plan
    ```

3.  **Pritaikyti:**

    ```bash
    terragrunt apply
    ```

Patikrinkite gautus *output*.
**Klausimas: Kodėl service account name, nors ir nenurodėme `prefix`, bet jis vis tiek atsirado?**

## VM (5\_Resources/client-resources/vm)

#### **1. Konfigūracija**

Virtualios mašinos resursų kūrimo vietoje (`5_Resources/client-resources/vm`) atidarykite `terragrunt.hcl` ir peržiūrėkite/atlikite pakeitimus:

  * `dependency "service_account"` blokas:
      * `config_path` - Čia mums reikia nurodyti service account resurso priklausomybę. Nurodome `..\\service-account`.
  * `inputs` blokas:
      * `name` - Virtualios mašinos vardas, gale pridėkite papildomai VM paskirtį. Pvz.: `"${include.shared.inputs.prefix}-vm-${include.shared.inputs.glb_name}-web"`.
      * `zone` - Kurioje zonoje bus paleista virtuali mašina. *europe-west4* turi a, b, c zonas. Pasirinkti vieną ir nurodyti formate: `"${include.shared.inputs.region}-a"`.
      * `instance_type` - virtualios mašinos dydis. Nurodome `f1-micro`.
      * `network_interfaces` blokas:
        Šioje vietoje nurodysime, kokį tinklą prijungti virtualiai mašinai.
          * `network` - shared VPC pilnas vardas (vpc\_self\_link). Kadangi jie pas mus nurodyti kaip globalūs kintamieji, galime nurodyti juos. Pakeičiame į `"${include.shared.inputs.vpc}"`.
          * `subnetwork` - shared VPC subnet pilnas vardas (subnet\_self\_link). Pakeičiame į `"${include.shared.inputs.subnet}"`.
      * `boot_disk` blokas:
          * `size` - VM boot disko dydis. Pakeiskite į `20`.


### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į `vm` aplanką ir vykdykite:

1.  **Inicijuoti:**

    ```bash
    terragrunt init
    ```

2.  **Planuoti:**

    ```bash
    terragrunt plan
    ```

3.  **Pritaikyti:**

    ```bash
    terragrunt apply
    ```

## Cloud SQL (5\_Resources/client-resources/cloudsql)

#### **1. Konfigūracija**

Cloud SQL duomenų bazės resursų kūrimo vietoje (`5_Resources/client-resources/cloudsql`) atidarykite `terragrunt.hcl` ir peržiūrėkite/atlikite pakeitimus:

  * `inputs` blokas:
      * `name` - Cloud SQL vardas. Gale pridėkite paskirtį. Pvz.: `${include.shared.inputs.prefix}-sql-${include.shared.inputs.glb_name}-web-01`.
      * `tier` - Cloud SQL dydis. Pakeiskite į `db-f1-micro`.
      * `databases` - duomenų bazės pavadinimas, kurią sukurs. Pvz.: `web_laravel`.
      * `users` blokas:
          * `web-user` - vartotojo vardas, kurį sukurs. Jei tinka, galit palikti kaip yra arba pakeisti pagal save.
          * `access_to_db` - nurodyti, kuriai DB sukurti *secret* įrašą. Nurodykite tą patį, kaip ir `databases` lauke. Pvz.: `web_laravel`.
      * `deletion_protection` - šis parametras apsaugo duomenų bazes nuo ištrynimo. Kadangi mokymų gale reikės šiuos resursus ištrinti, tad turim pakeisti į `false`.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į `cloudsql` aplanką ir vykdykite:

1.  **Inicijuoti:**

    ```bash
    terragrunt init
    ```

2.  **Planuoti:**

    ```bash
    terragrunt plan
    ```

3.  **Pritaikyti:**

    ```bash
    terragrunt apply
    ```

## Cloud Run (5\_Resources/cloudrun)

#### **1. Konfigūracija**

Cloud Run resursų kūrimo vietoje (`5_Resources/client-resources/cloud-run`) atidarykite `terragrunt.hcl` ir peržiūrėkite/atlikite pakeitimus:

  * `inputs` blokas:
      * `name` - Cloud Run vardas. Pridėkite gale paskirtį. Pvz.: `${include.shared.inputs.prefix}-run-${include.shared.inputs.glb_name}-hello`.
      * `image` - Cloud Run konteinerio atvaizdas. Turi būti `crccheck/hello-world`.
      * `resources` blokas:
          * `cpu` - Kiek CPU išskirti milicore. Nurodykite `1000m`.
          * `memory` - Kiek RAM išskirti. Nurodykite `1Gi`.
      * `ports` blokas:
          * `container_port` - Kokiu prievadu konteineris klausosi. Nurodykite `8000`.
      * `env` blokas - skirtas sisteminiams kintamiesiems. Palikite, kaip yra.
      * `service_account_config` blokas - skirtas Cloud Run sukurti *service account'us*.
      * `revision` blokas:
          * `vpc_access` blokas - nurodo konfigūraciją, kaip mums prijungti Cloud Run prie nurodyto VPC subnet. Paliekame, kaip yra.
      * `service_config` blokas:
          * `max_instance_count` - kiek maksimaliai konteinerių gali padidėti (išsiplėsti). Pakeičiam į `5`.
          * `min_instance_count` - minimalus konteinerių kiekis. Pakeičiam į `0`.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į `cloud-run` aplanką ir vykdykite:

1.  **Inicijuoti:**

    ```bash
    terragrunt init
    ```

2.  **Planuoti:**

    ```bash
    terragrunt plan
    ```

3.  **Pritaikyti:**

    ```bash
    terragrunt apply
    ```

### **Tikrinimas**

Iš gauto *output* nusikopijuojame kintamojo `service_uri` reikšmę ir ją suvedame į naršyklės langą. Ką matote?

## Application Load Balancer (5\_Resources/client-resources/alb)

#### **1. Konfigūracija**

Application Load Balancer resursų kūrimo vietoje (`5_Resources/client-resources/alb`) atidarykite `terragrunt.hcl` ir peržiūrėkite/atlikite pakeitimus:

  * `dependency` blokas - Jums reikia sukonfigūruoti priklausomybę nuo Cloud Run prieš tai sukurto resurso, nes *loadbalancer* bus nukreiptas į jį.
      * Užpildykite priklausomybės vardą. Pvz.: `dependency "cloud-run"`.
      * Reikia nurodyti, kur priklausomybė kreipsis, t.y. `config_path`. Šitą vietą padarykite patys. Jei neatsimenat kaip, galite pažiūrėti `vm` direktoriją, ten jau tai darėme.
  * `inputs` blokas:
      * `name` - ALB vardas. Gale pridėkite paskirtį. Pvz.: `${include.shared.inputs.prefix}-alb-${include.shared.inputs.glb_name}-cloudrun-web`.
      * `backend_service_configs` blokas:
          * `backend` - kur ALB kreipsis, kai ateis užklausos į jį. Šiuo atveju mes konfigūruosime NEG (Network Endpoint Group tam). Pridėkite gale paskirtį. Pvz.: `${include.shared.inputs.prefix}-neg-${include.shared.inputs.glb_name}-run-hello`.
      * `neg_configs` blokas - čia sukonfigūruosime prieš tai nurodytą *backend'ą*:
          * `${include.shared.inputs.prefix}-neg-${include.shared.inputs.glb_name}` - pakeiskite tokiu pat vardu, kaip ir buvo `backend` nurodyta.
              * `cloudrun` -\> `target_service` -\> `name` - šioje vietoje nurodome mūsų Cloud Run'o resurso vardą. Jį pasiimsime iš mūsų priklausomybės. Jei prieš tai užpildėte `dependency "cloud-run"`, tai šioje vietoje `name` turi atrodyti taip: `dependency.cloud-run.outputs.service_name`.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į `alb` aplanką ir vykdykite:

1.  **Inicijuoti:**

    ```bash
    terragrunt init
    ```

2.  **Planuoti:**

    ```bash
    terragrunt plan
    ```

3.  **Pritaikyti:**

    ```bash
    terragrunt apply
    ```

### **Tikrinimas**

Iš gauto *output* nusikopijuojame kintamojo `address` reikšmę ir ją suvedame į naršyklės langą. Ką matote? Turėtumėt gauti tą patį vaizdą, kaip ir iš prieš tai kurto modulio `cloud-run`.

### **Papildomai**

Kadangi šis modulis neišskiria statinio IP adreso savarankiškai, tai galite pabandyti pasiekti.
Pavyzdžiai, kaip susikurti IP adresą: [Nuoroda į modulį](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/net-lb-app-ext#changing-the-network-endpoint-group).
HINT: reikės susikurti naują resursą išoriniam IP adresui susikurti ir jį pridėti šiame terragrunt faile.

## GKE (5\_Resources/client-resources/gke)

Norint pradėti diegti GKE resursus, visų pirma turime gauti *Pod* ir *Services* tinklus. Tam naudosime kitą modulį, kurį vėliau panaudosime kaip priklausomybę.

### get-subnet-network-links (5\_Resources/client-resources/get-subnet-network-links)

#### **1. Konfigūracija**

Subnet gavimo resursų kūrimo vietoje (`5_Resources/client-resources/get-subnet-network-links`) atidarykite `terragrunt.hcl` ir peržiūrėkite konfigūraciją.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į `get-subnet-network-links` aplanką ir vykdykite:

1.  **Inicijuoti:**

    ```bash
    terragrunt init
    ```

2.  **Planuoti:**

    ```bash
    terragrunt plan
    ```

3.  **Pritaikyti:**

    ```bash
    terragrunt apply
    ```

### gke (5\_Resources/client-resources/gke)

"Susirinkę" pilnus kelius iki subnet, galime diegti GKE klasterį.

#### **1. Konfigūracija**

GKE resursų kūrimo vietoje (`5_Resources/client-resources/gke`) atidarykite `terragrunt.hcl` ir padarykite pakeitimus:

  * `dependency` blokas - Jums reikia sukonfigūruoti priklausomybę nuo subnet gavimo prieš tai sukurto resurso.
      * Užpildykite priklausomybės vardą. Pvz.: `dependency "gke-network"`.
      * Reikia nurodyti, kur priklausomybė kreipsis, t.y. `config_path`. Pvz.: `../get-subnet-network-links`.
  * `inputs` blokas:
      * `network` - VPC tinklo vardas. Turime paimti iš priklausomybės. Pvz.: `dependency.gke-network.outputs.network`.
      * `subnetwork` - VPC subnet vardas. Turime paimti iš priklausomybės. Pvz.: `dependency.gke-network.outputs.subnetwork`.
      * `machine_type` - Pradinės GKE mašinos tipas. Palikite, kaip nustatyta `n2d-standard-2`.
      * `spot` - Spot VM naudojimas. Palikite `true`.
      * `node_locations` - zonos, kuriose bus kuriamos pradinės GKE mašinos.
      * `name` - GKE klasterio vardas. Pridėkite gale paskirtį. Pvz.: `"${include.shared.inputs.prefix}-gke-${include.shared.inputs.glb_name}-apps"`.
      * `nodepool_config` - pradinė automatinio mašinų didinimo konfigūracija. Palikite, kaip yra.
      * `enable_secrets_database_encryption` - GKE viduje naudojamų paslapčių kriptavimas. Pagal numatytą reikšmę mes jį paliekam `true`, tačiau mokymų tikslais padarykite `false`.
      * `cluster_service_account_name` - GKE klasterio naudojamas service accountas. Pridėkite gale paskirtį tokią pat, kaip ir GKE klasterio vardas. Pvz.: `"${include.shared.inputs.prefix}-sa-${include.shared.inputs.glb_name}-gke-apps"`.
      * `cluster_secondary_range_name` - Pod IP subnet pavadinimas. Turime paimti iš priklausomybės. Pvz.: `dependency.gke-network.outputs.secondary_pods_name`.
      * `service_secondary_range_name` - Service IP subnet pavadinimas. Turime paimti iš priklausomybės. Pvz.: `dependency.gke-network.outputs.secondary_services_name`.
      * `node_pools` blokas - čia nurodome virtualių mašinų rinkinius (node pools), kuriuose bus paleidžiami resursai:
          * `name` - pakeiskit į savo sugalvotą vardą.
          * `nodepool_config` blokas:
              * `max_node_count` - kiek maksimaliai virtualių mašinų gali būti. Pakeiskite į `2`.
          * `nodepool_machine_type` - virtualių mašinų dydis ir tipas. Pakeiskite į `n2-standard-2`.
          * `disk_size_gb` - virtualių mašinų diskų dydis. Pakeiskite į `35`.

### **Diegimo žingsniai**

Atlikę pakeitimus, nueikite į `gke` aplanką ir vykdykite:

1.  **Inicijuoti:**

    ```bash
    terragrunt init
    ```

2.  **Planuoti:**

    ```bash
    terragrunt plan
    ```

3.  **Pritaikyti:**

    ```bash
    terragrunt apply
    ```

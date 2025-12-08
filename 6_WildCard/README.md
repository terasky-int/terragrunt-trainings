## WildCard užsiėmimas

Sveikinu, pabaigėt mokymus, tačiau jei norit truputį didesnio "deep dive", štai keleta užduočių reikalaujančių pagalvoti ir "susitempti rankas" :))


## VM (5\_Resources/client-resources/vm)

#### **1. Konfigūracija**

Virtualios mašinos resursų kūrimo vietoje (`5_Resources/client-resources/vm`) atidarykite `terragrunt.hcl` ir peržiūrėkite/atlikite pakeitimus:
  * Užkomentuokite `shielded_config` bloką ir bandykite atnaujinti virtualios mašinos konfigūraciją. 

Taip pamatysite, kaip veikia Organizacijos politikos – neleis paleisti VM. 

**Jūsų užduotis:** pakeitus organizacijos arba projekto politiką paleisti virtualią mašiną.
HINT: `4_Organization/_org` -> `org_policies` arba projekto atveju `4_Organization/organization/Env/Prod/gc-prj-cst-prod-demo-<sufix>/_project` -> `org_policies`


## Application Load Balancer (5\_Resources/client-resources/alb)

### 1 ALB užduotis

Kadangi šis modulis neišskiria statinio IP adreso savarankiškai, kas yra naudinga kuriant tinklo balansuoklius (Perkūrus išliks tas pats IP), tai galite pabandyti pasiekti.

Pavyzdžiai, kaip susikurti IP adresą: [Nuoroda į modulį](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/net-address#external-and-global-addresses).
HINT: reikės sukurti naują direktoriją ir `terragrunt.hcl` išoriniam IP adresui. Sukurti ip adresą ir jį pridėti alb terragrunt faile. **Naudoti globalų ip addresą ir nepamirškit dependency tarp ip adreso ir ALB**.  [terraform pavyzdys kaip prijungti ALB išorinį ip](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/net-lb-app-ext#http-to-https-redirect)

### 1 ALB užduotis

Gerosios praktikos diktuoja, kad srauto balansuoklis (Load Balancer) pats užtikrintų srauto nukreipimą iš HTTP užklausų į HTTPS. Tą ir implementuokite.

HINT: [Terraform pavyzdys kaip tai pasiekti su moduliais](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/net-lb-app-ext#http-to-https-redirect)
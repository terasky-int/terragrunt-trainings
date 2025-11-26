
## **📋 Reikalavimai**

* „Windows 10“ arba „Windows 11“  
* Administratoriaus teisės

---

## **1\. „Git“ diegimas**

1. Apsilankykite [oficialioje „Git“ svetainėje](https://git-scm.com/download/win).  
2. Atsisiųskite **64-bit Git for Windows Setup**.  
3. Paleiskite diegimo failą.  
4. **Pastaba:** Dažniausiai galite priimti visus numatytuosius nustatymus spausdami „Next“ (Toliau) per visą diegimo vedlį.

---

## **2\. Failų katalogo paruošimas („Terraform“ ir „Terragrunt“)**

Kadangi „Terraform“ ir „Terragrunt“ platinami kaip pavieniai failai, sukursime jiems skirtą vietą.

1. Atidarykite „File Explorer“.  
2. Dabalaukyje sukurkite aplanką pavadinimu "mokymai".  
   * **Kelias:** C:\\Users\\<<"user name">>\\Desktop\\moykymai

## **3. Mokymų repositorijos klonavimas**

1. Atsidarykite Terminal (Lango mygtukas -> Terminal)
2. Suveskite komandą:
```cd .\Desktop\mokymai\```
3. Nusiklonuokite repositoriją:
```git clone https://github.com/terasky-int/terragrunt-trainings.git``` 


## **4\. Sistemos aplinkos kintamųjų konfigūravimas (Environment Variables)**

Kad „Windows“ atpažintų terraform ir terragrunt komandas bet kuriame terminalo lange, turite pridėti sukurtą aplanką į sistemos „Path“ kintamąjį.

1. Paspauskite **Windows klavišą** ir įveskite env.  
2. Pasirinkite **Edit the system environment variables** (Redaguoti sistemos aplinkos kintamuosius).  
3. Spustelėkite mygtuką **Environment Variables...** lango apačioje.  
4. Skiltyje **System variables** (apatinis langas) raskite kintamąjį **Path**, pažymėkite jį ir spustelėkite **Edit** (Redaguoti).  
5. Spustelėkite **New** (Naujas).  
6. Įveskite aplanko kelią: C:\\Users\\<<"user name">>\\Desktop\\moykymai\\terragrunt-trainings\\1_Prepare_Env.  
7. Spustelėkite **OK** visuose trijuose languose, kad išsaugotumėte pakeitimus ir uždarytumėte langus.

## **5\. Gcloud CLI diegimas**

1. Atsidarome direktoriją
```Desktop\mokymai\terragrunt-trainings\1_Prepare_Env```
2. Du kartus paspaudžiame ant ```GoogleCloudSDKInstaller.exe```
3. Atsidariusiame lange spaudžiame keletą kartų ```Next``` iki lango ```Select components to install```. Pažymime ```Cloud Tools for PowerShell```. Spaudžiame ```Install```.
4. ```Next``` ir ```Finish```.

## **6\. Visual Studio Code diegimas**

1. Atsidarome naršyklėje
```https://code/visualstudion.com/download```
2. Pasirenkame ```Windows```.
3. Atsidarome atsiūstą failą.
4. Pora kartų spaudžiame ```Next```ir ```Install```.
5. Baigusis diegimui, spaudžiame ```Finish```.


## **ų\. Patikrinimas**

**Svarbu:** Turite uždaryti visus atidarytus terminalo langus ir atidaryti **naują** „PowerShell“ arba „Command Prompt“ langą, kad „Path“ pakeitimai įsigaliotų.

Norėdami patikrinti, ar įrankiai veikia, paleiskite šias komandas:

```
# Patikrinti Git  
git \-\-version```

# Patikrinti Terraform  
terraform \-v

# Patikrinti Terragrunt  
terragrunt \-v

# Patikrinti Google Cloud SDK  
gcloud \-v
```

## **6\. Inicializavimas**

Kai patikrinimas sėkmingas, inicijuokite „Google Cloud CLI“:
```
gcloud init
```
Ši komanda atidarys naršyklę, kurioje turėsite prisijungti prie savo „Google“ paskyros ir pasirinkti GCP projektą.



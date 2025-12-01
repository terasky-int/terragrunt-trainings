
## **📋 Reikalavimai**

* „Windows 10“ arba „Windows 11“
* „macOS“ kompiuteris su interneto prieiga.
* Administratoriaus teisės

---
# **Mokymams paruošimas**
1. Susikurkite ant darbalaukio direktoriją, pavadinimu `mokymai` (Dešiniu pelės klavišu ant darbalaukio New -> Folder) 
2. Atsidarykite komandinę eilutę:
* Spaudžiame lango mygtuką
* Įrašome `cmd`
* spaudžiame klavišą `Enter`
3. Atsidariusioje komandinėje eilutėje vedame komandą: `cd Desktop\mokymai` ir spaudžiame `Enter`
4. Suvedame komandą `git clone https://github.com/terasky-int/terragrunt-trainings.git` ir spaudžiame `Enter`
5. (jei turite) Atsidarome Visual Studio code (Lango mygtukas -> Visual Studio Code ir enter):
* Spaudžiame dešiniam viršutiniam kampe `File -> Add Folder to Workspace`
* Naujai atsidariusime lange pasirenkame `mokymai` direktoriją (tą kurią prieš tai sukūrėm) ir spaudžiame `Add`
*  Kairėje turėjo pasirodyti direktorija mokymai
6. Grįžkite atgal į komandinę eilutę ir suveskite atskirai komandas:
* `git version`
* `terraform version`
* `terragrunt version`
* `gcloud version` (Jei naudojate PowerShell veskite `gcloud.cmd version`)
7. Toliau komandinėje eilutėje suveskite komandą: `gcloud init`
* Jei pasirodė klausimas su tekstu: `Pick configuration to use` įveskite numerį `2` ir spauskite `Enter`
* Pavadinkite konfigūraciją `tf-demo`
* Prie klausimo `Select an account` pasirinkite numerį `3` (`Sing in with new Google account`) ir spauskite `Enter`.
* Atsidariusiame naršyklės lange prisijunkite su savo GCP paskyros vardu (Formatas `<vardas>.<pavardė>@gcp.vssa.lt`)
* Toliau grįžę į komandinę eilutę pasirinkite 1 (`Enter a project ID`) ir įveskite `aivaras-s-sandbox`
* Kai klaus `Do you want to configure a default Compute Region and Zone` įveskite `n` ir spauskite `Enter`
8. **Nusiteikti padirbėt :)**
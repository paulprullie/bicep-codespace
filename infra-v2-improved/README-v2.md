# 📚 IaC Workshop: Deel 1 - Bicep Infrastructure

Welkom bij de praktische workshop **Infrastructuur als Code**!

In deze sessie bouw je een complete **IoT Data Pipeline** in Azure, volledig gedefinieerd met **Bicep**.

## 🎯 Wat Je Gaat Leren

Na het afmaken van deze workshop begrijp je:

✅ Hoe je Azure documentatie leest voor Bicep resources
✅ Het verschil tussen Basic/Standard/Premium tiers
✅ Waarom Managed Identity beter is dan verbindingsreeksen
✅ Hoe RBAC rollen werken en waarom ze nodig zijn
✅ Child resources in Bicep (parent-child relaties)
✅ Waarom deployment-volgorde belangrijk is
✅ Wat `uniqueString()` doet en wanneer het nodig is
✅ Consumer groups en Event Hub partitionering
✅ Echte IaC development workflow (docs → code → validate)

Dit is **professioneel niveau** kennis!

---

## ⏱️ Tijdsinvestering

**Deze workshop (Deel 1: Bicep Infrastructure) duurt ongeveer 60 minuten:**

Dit omvat voorbereiding, Azure-verbinding, documentatie raadplegen, implementatie, en validatie.

| Activiteit | Tijd |
|-----------|------|
| Voorbereiding & Azure setup | ~10 min |
| Documentatie raadplegen | ~15 min |
| Code implementeren (alle modules) | ~25 min |
| Validatie & troubleshooting | ~10 min |
| **TOTAAL DEEL 1** | **~60 min** |

**Workshop totaal (90 minuten):**
- ✅ Deel 1: Bicep Infrastructure (dit bestand) = **60 min**
- ✅ Deel 2: CI/CD Pipeline (essentials) = **30 min**
- 🎯 Challenges (VNET, Application Insights, etc.) = **OPTIONEEL** (voor snelle deelnemers)

---

## 🚀 Aan de Slag

### Stap 1: Voorbereiding
```bash
# Zorg dat je in de infra-v2-improved folder bent
cd infra-v2-improved
```

### Stap 2: Lees Eerst de TODOs
- Elke TODO bevat **leerinhoud**, niet alleen instructies
- De hints verwijzen naar Azure documentatie
- Reflectievragen ("Vraag jezelf af:") moedigen kritisch denken aan

### Stap 3: Implementeer Module voor Module
```
1. storage.bicep       (MAKKELIJK - variabele naming)
2. eventhub.bicep      (GEMIDDELD - resource properties)
3. function.bicep      (LASTIG - app settings patroon)
4. rbac.bicep          (EXPERT - role assignments)
```

### Stap 4: Valideer Voortgang
```bash
# Na elke module:
az bicep build --file main.bicep

# Uiteindelijk:
az deployment sub what-if \
  --location westeurope \
  --template-file main.bicep \
  --parameters main.bicepparam
```



---

## 🤔 Hulp Nodig?

### "Hoe definieer ik de storage account naam?"
Kijk naar `eventhub.bicep` - daar is een soortgelijk patroon met `eventHubNamespaceName`. Wat maakt een naam globally uniek?

### "Welke properties heeft een storage account nodig?"
Raadpleeg de documentatielink in de TODO. Wat is het verschil tussen `kind` waarden?

### "Waarom heb ik RBAC nodig?"
De Function App moet rechten hebben om events te lezen en naar opslag te schrijven. Hoe zou jij een applicatie in het echte leven autoriseren?

### "Wat betekent `existing`?"
Je maakt hier de storage account NIET aan - die is al gemaakt door de vorige module. Hoe refereer je naar iets dat al bestaat?

---

## 📊 Moeilijkheidsgraad per Module

De TODOs zijn ingedeeld naar moeilijkheid:

| Module | Niveau | Focus |
|--------|--------|-------|
| storage.bicep | 🟢 MAKKELIJK | Variabele naming, unieke waarden |
| eventhub.bicep | 🟡 GEMIDDELD | SKU/tier config, child resources |
| function.bicep | 🟠 LASTIG | Managed Identity, app settings |
| rbac.bicep | 🔴 EXPERT | Role assignments, principalId |

Je kunt in volgorde werken OF naar modules springen waar je meer aangetrokken tot voelt.

---

## ✅ Success Criteria

Je weet dat je klaar bent als:

- [ ] Alle Bicep bestanden compileren zonder fouten
- [ ] `az bicep build` succesvol draait
- [ ] What-If analyse toont "10 resources to create"
- [ ] Je kunt uitleggen WHY elke eigenschap ingesteld is
- [ ] Je begrijpt de deployment dependency order
- [ ] Je kunt elke RBAC role en doel noemen

---

## 📚 Aanvullende Resources

Voor meer diepgang:
- **DEPLOYMENT-NOTES.md** - Diepgaande architectuur uitleg
- **README.md** - Originele workshop gids

## 🎯 Aan het Einde van Deze Workshop

Je bent niet alleen klaar met Azure resources - je begrijpt **waarom** ze zo geconfigureerd zijn.

Je kunt:
- ✅ Zelfstandig Bicep bestanden lezen
- ✅ Documentatie effectief gebruiken
- ✅ IaC patronen toepassen op andere projecten
- ✅ Beveiligingsimplicaties van keuzes evalueren
- ✅ Professioneel met Infrastructure-as-Code werken

**Veel succes!** 🚀

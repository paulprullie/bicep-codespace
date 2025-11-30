# 📊 Detailed Comparison: v1 vs v2 Skeleton Files

This document shows the specific improvements between the original skeleton files and the v2 learning-optimized version.

---

## 🔄 Overview of Changes

| Aspect | v1 (Original) | v2 (Improved) | Why Better? |
|--------|---------------|---------------|------------|
| **Comment specificity** | Lists exact property names | Links to docs + hints | Forces research & understanding |
| **Variable initialization** | `var name = 'yourname'` | `var name = ''` | Students must think about naming |
| **Resource implementation** | Properties listed in comments | Empty resource blocks | Students read documentation |
| **Learning questions** | None | "Vraag jezelf af:" prompts | Encourages critical thinking |
| **Error tolerance** | High (copy-paste works) | Low (must implement correctly) | Better retention |
| **Estimated time** | ~25 minutes | ~60 minutes | Meets workshop goals |
| **Student engagement** | Low (copy-paste) | High (problem-solving) | Better learning outcomes |

---

## 🔍 Detailed Examples

### File 1: main.bicep

#### v1 (Original)
```bicep
// TODO: Roep de storage module aan
// Documentatie: https://learn.microsoft.com/azure/azure-resource-manager/bicep/modules

module storage 'modules/storage.bicep' = {
  name: 'deploy-storage'
  scope: resourceGroup
  params: {
    workloadName: workloadName
    location: location
  }
}

// TODO: Voeg de overige parameters toe (gebruik outputs van andere modules)
// eventHubNamespace: eventHub.outputs.fullyQualifiedNamespace
// eventHubName: eventHub.outputs.eventHubName
// storageAccountName: storage.outputs.storageAccountName
```

**Issues:**
- Solution is in the comments (literally!)
- No explanation of WHY outputs are needed
- Students just uncomment

#### v2 (Improved)
```bicep
// =============================================================================
// MODULE AANROEPEN
// =============================================================================
// Volgorde is belangrijk! Modules worden sequentieel gedeployd:
// 1. Storage → 2. Event Hub → 3. Function App → 4. RBAC
//
// Waarom? Omdat Function App de outputs van Storage en Event Hub nodig heeft,
// en RBAC moet na de Function App omdat het de principalId nodig heeft.

// TODO: Implementeer de vier modules hieronder.
// Documentatie: https://learn.microsoft.com/azure/azure-resource-manager/bicep/modules
//
// Tips:
// - Gebruik `scope: resourceGroup` om modules in de juiste RG te deployen
// - Module outputs zijn beschikbaar via: moduleName.outputs.outputName
// - Dependencies kunnen expliciet gemaakt worden met `dependsOn`

module storage 'modules/storage.bicep' = {
  name: 'deploy-storage'
  scope: resourceGroup
  params: {
    workloadName: workloadName
    location: location
  }
}

module functionApp 'modules/function.bicep' = {
  name: 'deploy-function-app'
  scope: resourceGroup
  params: {
    workloadName: workloadName
    location: location
    // TODO: Voeg de benodigde parameters toe uit storage en eventHub outputs
  }
}
```

**Improvements:**
- Explains WHY the order matters
- Doesn't give away the exact parameters
- Teaches OUTPUT REFERENCE pattern
- Students must think about dependencies

---

### File 2: storage.bicep

#### v1 (Original) - Storage Account Naming
```bicep
// TODO: Maak een unieke naam voor het storage account
// Tips:
// - Storage account namen moeten globally unique zijn
// - Max 24 karakters, alleen lowercase letters en cijfers
// - Gebruik uniqueString(resourceGroup().id) voor uniekheid
// - Prefix: 'st' (geen streepje bij storage accounts!)
var storageAccountName = 'yourname' // TODO: Pas aan
```

**Issues:**
- Tells them `uniqueString()` exists
- Tells them exact prefix 'st'
- Tells them no hyphens
- Copy-paste: just replace 'yourname'

#### v2 (Improved) - Storage Account Naming
```bicep
// TODO: Definieer een unieke naam voor het storage account
// Hints:
// - Storage accounts mogen max 24 karakters
// - Geen streepjes, alleen lowercase letters en cijfers
// - Moet globally unique zijn
// - Documentatie: https://learn.microsoft.com/azure/storage/common/storage-account-overview
// - Tip: `uniqueString(resourceGroup().id)` genereert een unieke hash

var storageAccountName = ''  // TODO: Implementeer
```

**Improvements:**
- Doesn't mention uniqueString() initially
- Students discover it from docs or previous examples
- Doesn't specify prefix (they learn it from Azure naming conventions)
- Must write actual code, not just replace a placeholder

---

#### v1 (Original) - Storage Account Resource
```bicep
// TODO: Maak het Storage Account resource
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts
//
// Vereisten:
// - name: gebruik de variabele storageAccountName (max 24 chars)
// - location: gebruik de parameter
// - sku.name: 'Standard_LRS'
// - kind: 'StorageV2'
// - properties:
//   - accessTier: 'Hot'
//   - minimumTlsVersion: 'TLS1_2'
//   - supportsHttpsTrafficOnly: true
//   - allowBlobPublicAccess: false

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take(storageAccountName, 24)
  location: location
  // TODO: Voeg sku toe (name: 'Standard_LRS')
  // TODO: Voeg kind toe ('StorageV2')
  // TODO: Voeg properties toe
}
```

**Issues:**
- Lists ALL properties needed
- Students just copy the structure
- No explanation of WHAT these mean
- No WHY (why Hot tier? Why TLS 1.2?)

#### v2 (Improved) - Storage Account Resource
```bicep
// TODO: Maak het Storage Account resource
// Vereisten:
// - Het moet StorageV2 zijn (niet Storage v1)
// - SKU moet Standard_LRS zijn
// - Hot tier voor frequent access
// - Security: HTTPS only, minimale TLS versie, geen public blob access
// 
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts
// Hint: Kijk naar de bestaande main.bicep/eventhub.bicep voor structuur voorbeelden

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  // TODO: Implementeer
}
```

**Improvements:**
- Explains WHY each requirement exists (security, performance)
- Doesn't list property names
- Must read docs to find correct structure
- Hints at learning from other examples (pattern recognition)

---

### File 3: function.bicep (The Most Important Change)

#### v1 (Original) - Managed Identity Pattern
```bicep
// TODO: Voeg appSettings toe
// Dit zijn de environment variables voor de Function App
//
// Belangrijke settings:
// 1. AzureWebJobsStorage__accountName = storageAccountName
//    (Let op de dubbele underscore! Dit is voor Managed Identity)
//
// 2. FUNCTIONS_EXTENSION_VERSION = '~4'
//
// 3. FUNCTIONS_WORKER_RUNTIME = 'python'
//
// 4. EventHubConnection__fullyQualifiedNamespace = eventHubNamespace
//    (Dubbele underscore voor Managed Identity!)
//
// 5. EventHubName = eventHubName
//
// 6. StorageAccountName = storageAccountName

appSettings: [
  // TODO: Voeg alle app settings toe als objects:
  // { name: 'SETTING_NAME', value: 'setting_value' }
]
```

**Issues:**
- Explicitly lists all setting names
- Just says "copy these"
- Doesn't explain WHY double underscore
- Students don't learn about Managed Identity security benefits

#### v2 (Improved) - Managed Identity Pattern
```bicep
// TODO: Maak de Function App met SystemAssigned Managed Identity
// Dit is het centraal onderdeel - het voert de Python code uit.
// Vereisten:
// - kind: 'functionapp,linux' (Linux + serverless)
// - identity.type: 'SystemAssigned' (Dit is Managed Identity!)
// - siteConfig.linuxFxVersion: 'PYTHON|3.11'
// - App Settings (zie hints hieronder)
//
// App Settings hints:
// - AzureWebJobsStorage__accountName = storageAccountName
//   (Dubbele underscore = Managed Identity auth, niet connection string!)
// - FUNCTIONS_EXTENSION_VERSION = '~4'
// - FUNCTIONS_WORKER_RUNTIME = 'python'
// - EventHubConnection__fullyQualifiedNamespace = eventHubNamespace
//   (Dubbele underscore = Managed Identity auth!)
// - EventHubName = eventHubName
// - StorageAccountName = storageAccountName
//
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.web/sites
// Vraag: Waarom dubbele underscore in plaats van connection strings?
```

**Improvements:**
- Explains what Managed Identity IS
- Contrasts with insecure connection strings
- Asks critical thinking question
- Still provides hints (not hiding solution)
- Encourages understanding the security pattern

---

### File 4: rbac.bicep

#### v1 (Original) - Role Assignment
```bicep
// TODO: Ken de 'Storage Blob Data Contributor' rol toe
// Role Definition ID: ba92f5b4-2d11-453d-a403-e96b0029c9fe
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments

resource storageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionAppPrincipalId, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    // TODO: Voeg roleDefinitionId toe
    // Hint: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '<role-id>')
    principalId: functionAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}
```

**Issues:**
- Gives the exact structure
- Gives the exact hint syntax
- Just substitute the role ID

#### v2 (Improved) - Role Assignment
```bicep
// TODO: Maak de role assignment
// Vereisten:
// - name: Unieke ID (gebruik `guid()` voor deterministische generatie)
// - scope: Het storage account
// - roleDefinitionId: subscriptionResourceId(...) met de role ID
// - principalId: De Managed Identity van de Function App
// - principalType: 'ServicePrincipal'
//
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
// Vraag: Waarom moet dit resource APART zijn en niet in de Function App?
// Antwoord: RBAC moet NA de Function App (omdat we de principalId nodig hebben)

resource storageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // TODO: Implementeer
}
```

**Improvements:**
- Explains WHY guid() is needed (deterministic ID)
- Explains WHY this is separate (dependency ordering)
- Includes the answer to the question (learning opportunity)
- Doesn't give exact structure
- Students must piece together from hints

---

## 📈 Learning Progression

### v1 Path (Copy-Paste)
1. Read comment
2. See example code
3. Copy the structure
4. ❌ No understanding gained

### v2 Path (Learning)
1. Read learning objective
2. Check Azure documentation link
3. Find the correct properties
4. Implement the resource
5. Test with `az bicep build`
6. Fix errors based on feedback
7. ✅ Deep understanding gained

---

## 🎯 Measurable Differences

| Metric | v1 | v2 | Impact |
|--------|----|----|--------|
| **Lines of comments per TODO** | 8-10 | 12-15 | More context |
| **Number of reflection questions** | 0 | 8-10 | Critical thinking |
| **Documentation links** | 1-2 | 4-5 | Research skills |
| **Exact solutions in comments** | Yes | Partial | Problem-solving |
| **Estimated time** | 20-30 min | 55-70 min | Workshop pacing |
| **Student engagement** | Low | High | Better outcomes |

---

## 🚀 Recommendation

### Use v1 if:
- Students have very limited programming experience
- Time is extremely constrained
- Goal is just to "see deployment work"
- Following a tightly scripted trainer delivery

### Use v2 if:
- Students have basic programming knowledge (as stated)
- Goal is real learning outcomes
- Time allows for ~60 minutes per workshop
- Want to build Bicep expertise
- **Planning to use Bicep professionally afterward**

---

## 📚 Additional Teaching Notes

### Trainer Tips for v2

**When a student asks "How do I do X?"**
- First response: "What does the documentation say?"
- Second response: "Look at module Y, which already does something similar"
- Third response: "Here's a hint..." (only if truly stuck)
- Last resort: "Let me show you the pattern..."

**Common mistakes to watch for:**

1. **Variable naming**: Students might forget `uniqueString()` entirely
   - Hint: "What happens if two people use this template?"

2. **App Settings structure**: Might miss `{ name: '', value: '' }` object pattern
   - Hint: "Look at how propertyies are structured in Bicep arrays"

3. **RBAC roleDefinitionId**: Might forget `subscriptionResourceId()` wrapper
   - Hint: "The role ID needs to be scoped to the subscription level"

4. **Module dependencies**: Might forget to pass outputs as parameters
   - Hint: "The Function App needs to know which storage account to use - how would you tell it?"

---

## ✅ Validation Checklist for Trainers

When using v2, ensure:
- [ ] Students are encouraged to read Azure docs
- [ ] Students get feedback on their implementations
- [ ] You don't give away exact solutions
- [ ] Error messages are part of the learning
- [ ] Time allocation allows for ~60 minutes
- [ ] Students can explain WHY each property exists
- [ ] Success is measured by understanding, not just completion

---

**This comparison was created to help educators choose the best skeleton file version for their learning objectives.**

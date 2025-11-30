# 📖 Deployment Notes & Best Practices for Part 1

This document supplements the main README with additional context about Bicep patterns, deployment considerations, and explanations for design choices.

---

## 🏗️ Architecture Decisions Explained

### Why Managed Identity?

**The Old Way (Still Used, But Insecure):**
```bicep
// ❌ NOT RECOMMENDED - Secrets in code/config
appSettings: [
  { name: 'AzureWebJobsStorage', value: 'DefaultEndpointProtocol=https;...' }
  { name: 'EventHubConnection', value: 'Endpoint=sb://...' }
]
```

**Problems:**
- Connection strings contain credentials
- If code is leaked, credentials are leaked
- Credentials must be rotated manually
- Each app needs separate credentials

**The New Way (What We're Using):**
```bicep
// ✅ RECOMMENDED - Managed Identity
identity: {
  type: 'SystemAssigned'  // Azure creates a secure identity automatically
}

appSettings: [
  { name: 'AzureWebJobsStorage__accountName', value: storageAccountName }
  { name: 'EventHubConnection__fullyQualifiedNamespace', value: eventHubNamespace }
]
```

**Benefits:**
- No credentials in code at all
- Azure manages the identity and certificates
- Credentials rotated automatically
- Each resource gets its own identity
- Audit trail in Azure AD

**The Magic: Double Underscore `__`**

When Azure Functions sees a setting like `AzureWebJobsStorage__accountName`, it knows:
1. This is a Managed Identity authentication request
2. Connect to the storage account with THIS NAME
3. Use the Function App's system-assigned identity
4. Azure automatically handles the authentication

---

### Why This Module Structure?

**Modules are like functions in code:**

```
main.bicep (orchestrator)
├── storage.bicep (creates storage account)
├── eventhub.bicep (creates event hub)
├── function.bicep (creates function app, depends on storage/eventhub)
└── rbac.bicep (assigns permissions, depends on function app)
```

**Benefits:**
- ♻️ **Reusable**: Use `storage.bicep` in multiple projects
- 📦 **Modular**: Each module has one responsibility
- 🔧 **Testable**: Can deploy modules independently
- 👥 **Team-friendly**: Different team members work on different modules
- 📚 **Documented**: Each module is self-contained

**Dependency Order Matters:**

```
Storage ─────┐
            └─> Function App ──> RBAC
Event Hub ──┘
```

Why this order?
1. **Storage** must exist before RBAC can grant permissions
2. **Event Hub** must exist before Function App can be configured
3. **Function App** must exist before we can get its principalId for RBAC
4. **RBAC** is last because it depends on principalId from Function App

---

## 🔍 Understanding What-If Output

When you run:
```bash
az deployment sub what-if --location westeurope \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

You see:
```
Resource changes: 10 to create, 2 unsupported.
```

**What this means:**
- `10 to create` = 10 resources will be deployed ✅
- `2 unsupported` = 2 role assignments can't be analyzed yet ⚠️

**Why are RBAC assignments "unsupported"?**

The what-if tool can't know the exact resource IDs until deployment runs:
- Role assignment ID includes the Function App's principalId
- Function App doesn't exist yet, so what-if can't calculate the ID
- But deployment will work fine! ✅

This is expected and normal.

---

## 🏷️ Naming Convention Deep Dive

### Why Unique Names?

**Resource names must be globally unique in Azure** (for some resources):

```bicep
// ❌ BAD - Everyone would get name conflict
var storageAccountName = 'iotdata'

// ✅ GOOD - Unique across all Azure accounts
var storageAccountName = 'st${uniqueString(resourceGroup().id)}'
```

`uniqueString()` generates a hash based on:
- Your subscription ID
- Your resource group ID
- So everyone's name will be different: `stx4b7p9q1yz`, `str6gnmdionupzg`, etc.

### Why Not Just "My-App-Name"?

Try deploying twice with `storageAccountName = 'mystorageaccount'`:
1. First deployment: ✅ Works
2. Second deployment: ❌ ERROR - Name already taken!

### The Prefix Pattern

| Resource | Prefix | Why | Example |
|----------|--------|-----|---------|
| Storage Account | `st` | No hyphens allowed (max 24 chars, no special chars) | `stx4b7p9q1yz` |
| Event Hub Namespace | `evhns-` | Hyphens OK, helps readability | `evhns-iot-workshop-cc` |
| Function App | `func-` | Hyphens OK, descriptive | `func-iot-workshop-cc` |
| App Service Plan | `asp-` | Hyphens OK, follows convention | `asp-iot-workshop-cc` |

---

## 🔐 Security Best Practices Applied

### 1. HTTPS Only
```bicep
httpsOnly: true  // All traffic encrypted
```

### 2. Minimum TLS Version
```bicep
minimumTlsVersion: '1.2'  // Reject weak connections
```

### 3. No Public Blob Access
```bicep
allowBlobPublicAccess: false  // Blobs require authentication
```

### 4. Managed Identity (Not Connection Strings)
```bicep
identity: { type: 'SystemAssigned' }  // No secrets needed
```

### 5. RBAC with Least Privilege
```bicep
// Function App can only:
// - READ from Event Hub
// - WRITE to Blob Storage
// Nothing else!
```

---

## 📊 Resource Sizing Explained

### Event Hub: Basic Tier vs Standard

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| **Throughput Units** | 1 | 1-100 | 1-100 |
| **Partitions** | Max 32 | Max 100 | Max 128 |
| **Retention** | Max 1 day | Max 7 days | Max 90 days |
| **Cost** | $ (Workshop) | $$ | $$$ |
| **Use Case** | Learning ✅ | Production | Enterprise |

**Why Basic for workshop?**
- Sufficient for testing
- Costs pennies to run
- Real production would use Standard or Premium

### Function App: Consumption vs Dedicated

| Feature | Consumption | App Service Plan |
|---------|-------------|------------------|
| **Scaling** | Auto-scale (0-∞) | Manual/Auto-scale (1-∞) |
| **Pricing** | Pay per execution | Pay per hour |
| **Cost** | Cheap for low volume | More predictable |
| **Best for** | Testing/Low traffic | Production/Stable traffic |

**Why Y1 Consumption tier for workshop?**
- Starts at 0 instances
- Only pay when code runs
- Free tier available (limited)
- Perfect for learning

---

## 🧪 Testing Your Infrastructure

### After Deployment

**1. Check resources exist:**
```bash
az resource list --resource-group rg-iot-workshop-cc
```

**2. Get Function App info:**
```bash
az functionapp show --name func-iot-workshop-cc-xxx \
  --resource-group rg-iot-workshop-cc
```

**3. Check RBAC assignments:**
```bash
az role assignment list --scope /subscriptions/.../resourceGroups/rg-iot-workshop-cc
```

**4. Send test events:**
```bash
./scripts/send_events.sh --connection-string "..." --count 10
```

**5. Check events in storage:**
```bash
az storage blob list --container-name iot-data \
  --account-name <storage-name> --recursive
```

---

## 🐛 Common Issues & Troubleshooting

### Issue 1: "Storage account name already taken"
**Cause:** Another deployment used the same name
**Fix:** The `uniqueString()` should prevent this. Check if workloadName parameter is unique.

### Issue 2: "Cannot reference principalId during what-if"
**Cause:** What-if can't analyze RBAC assignments
**Fix:** This is normal! Deploy for real and it will work.

### Issue 3: "Function App can't access storage"
**Cause:** RBAC assignment failed or hasn't been applied
**Fix:** Check role assignments with:
```bash
az role assignment list --scope <resource-id>
```

### Issue 4: "Event Hub has too many partitions"
**Cause:** Basic tier max is 32 partitions
**Fix:** Check `partitionCount: 2` in eventhub.bicep

### Issue 5: Variables showing as unused parameters
**Cause:** Variables are empty but not used yet
**Fix:** This is expected for skeleton files!

---

## 📈 Scalability Considerations

### For Production (After Workshop)

**Upgrade checklist:**

- [ ] Event Hub: Upgrade to Standard tier for 7-day retention
- [ ] Function App: Switch to App Service Plan (more control, better performance)
- [ ] Storage: Add geo-redundant replication (GRS) instead of LRS
- [ ] RBAC: Add separate identities per environment (dev/test/prod)
- [ ] Monitoring: Add Application Insights for tracing
- [ ] Networking: Add private endpoints and VNet integration

---

## 📚 Key Concepts Recap

| Concept | Definition | Example |
|---------|-----------|---------|
| **Module** | Reusable Bicep template | storage.bicep |
| **Parameter** | Input to a module | workloadName, location |
| **Output** | Value exported from module | storageAccountName |
| **Resource** | Azure resource being created | storageAccount |
| **Child Resource** | Resource within another resource | container within storage |
| **Managed Identity** | Auto-managed credentials | SystemAssigned |
| **RBAC** | Access control via roles | Storage Blob Data Contributor |
| **What-If** | Preview of changes | See what WILL be deployed |
| **uniqueString()** | Generate unique values | st${uniqueString(...)} |
| **Consumer Group** | Event Hub reader group | function-consumer |

---

## 🎓 Learning Objectives Alignment

By completing Part 1 with understanding, students should be able to:

✅ **Explain** why each Azure resource is needed
✅ **Describe** the module dependency order and why it matters
✅ **Compare** Managed Identity vs connection strings
✅ **Design** resource naming for multi-team environments
✅ **Troubleshoot** common deployment issues
✅ **Predict** what what-if output means
✅ **Justify** tier/SKU choices for different scenarios
✅ **Implement** similar infrastructure for different workloads

---

## 🔗 Recommended Reading

### Azure Documentation
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Managed Identity Best Practices](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations)
- [Event Hubs Concepts](https://learn.microsoft.com/azure/event-hubs/event-hubs-features)
- [Azure Functions Bindings](https://learn.microsoft.com/azure/azure-functions/functions-bindings-event-hubs-trigger)

### Bicep Documentation
- [Bicep Modules](https://learn.microsoft.com/azure/azure-resource-manager/bicep/modules)
- [Bicep Functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [RBAC in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/scenarios-rbac)

---

**Questions? Revisit the hints in the skeleton files or check the Azure documentation links!**

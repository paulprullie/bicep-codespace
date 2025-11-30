# 📂 Improved Bicep Workshop - File Structure & Guide

This folder contains an enhanced version of the IaC workshop with improved learning outcomes.

## 📁 Structure

```
bicep-codespace/
├── infra/                          # ✅ ORIGINAL (v1) - Easy, copy-paste friendly
│   ├── main.bicep
│   ├── main.bicepparam
│   └── modules/
│       ├── storage.bicep
│       ├── eventhub.bicep
│       ├── function.bicep
│       └── rbac.bicep
│
├── infra-v2-improved/              # 🎓 IMPROVED (v2) - Learning-focused
│   ├── main.bicep
│   ├── main.bicepparam
│   ├── README-v2.md               # How to use v2
│   └── modules/
│       ├── storage.bicep
│       ├── eventhub.bicep
│       ├── function.bicep
│       └── rbac.bicep
│
├── COMPARISON.md                   # 📊 Detailed diff between v1 and v2
├── DEPLOYMENT-NOTES.md            # 📖 Deep-dive explanations
└── README.md                       # 📘 Original workshop guide
```

---

## 🎯 Quick Start: Which Version Should I Use?

### Choose **v1 (infra/)** if:
- ⏱️ Time is very limited (< 30 minutes)
- 👶 Students are completely new to Bicep
- 🎬 You want a scripted, fast demo
- ✅ Goal: "Just show that it works"

### Choose **v2 (infra-v2-improved/)** if:
- 📚 Goal: Real learning outcomes
- 👨‍💻 Students have basic programming knowledge
- ⏱️ Time allows ~60 minutes (Deel 1: Bicep)
- 🔧 Students will use Bicep professionally
- 🧠 You want critical thinking, not copy-paste

---

## 📖 Documentation Map

### For Trainers

| Document | Purpose | Audience |
|----------|---------|----------|
| **COMPARISON.md** | v1 vs v2 detailed comparison | Trainers choosing version |
| **DEPLOYMENT-NOTES.md** | Deep explanations of patterns | Trainers preparing content |
| **infra-v2-improved/README-v2.md** | How to use v2 files | Trainers using v2 |

### For Students

| Document | Purpose | Audience |
|----------|---------|----------|
| **README.md** | Original workshop guide | All students |
| **DEPLOYMENT-NOTES.md** | Deployment context & patterns | Students wanting deeper understanding |
| **TODOs in skeleton files** | Learning prompts | Students implementing v2 |

---

## 🚀 Running the Workshop

### Using v1 (Quick Path - ~30 min)

```bash
# 1. Navigate to original files
cd infra/

# 2. Files are already implemented
# 3. Just validate
az bicep build --file main.bicep

# 4. Run what-if
az deployment sub what-if \
  --location westeurope \
  --template-file main.bicep \
  --parameters main.bicepparam
```

### Using v2 (Learning Path - ~60 min)

```bash
# 1. Copy improved files
cp -r infra-v2-improved your-workspace/

# 2. Read README-v2.md
cat infra-v2-improved/README-v2.md

# 3. Implement TODOs in each module
# - Start with storage.bicep
# - Follow hints and documentation links
# - Run `az bicep build` to validate

# 4. Complete all four modules
# - storage.bicep
# - eventhub.bicep
# - function.bicep
# - rbac.bicep

# 5. Final validation
az bicep build --file infra-v2-improved/main.bicep

# 6. What-if analysis
az deployment sub what-if \
  --location westeurope \
  --template-file infra-v2-improved/main.bicep \
  --parameters infra-v2-improved/main.bicepparam
```

---

## 🎓 Learning Outcomes by Version

### v1 Outcomes (Copy-Paste)
✅ Understand Bicep syntax (modules, resources, outputs)
✅ See deployment in action
✅ Familiar with Azure resource types
❌ Don't understand WHY properties are chosen
❌ Can't modify for different requirements
❌ Limited retention

### v2 Outcomes (Problem-Solving)
✅ Everything from v1, PLUS:
✅ Can read Azure documentation
✅ Understand security patterns (Managed Identity)
✅ Know why each property exists
✅ Can design infrastructure for new scenarios
✅ Higher retention and confidence

---

## 📊 Time Breakdown

### v1 (Copy-Paste)
```
Reading comments:    5 min
Understanding code:  5 min
Copying structure:  10 min
Validation:         5 min
─────────────────────────
TOTAL:             ~25 min ⏱️
```

### v2 (Learning)
```
Reading objectives: 10 min
Reading docs:       20 min
Implementing:       20 min
Testing/fixing:     10 min
─────────────────────────
TOTAL:             ~60 min ⏱️
```

---

## 🔄 Comparison at a Glance

| Aspect | v1 | v2 |
|--------|----|----|
| Comments | Prescriptive | Guiding |
| Property names | Listed | Student discovers |
| Variables | Pre-filled | Empty to implement |
| Resource code | Partially shown | Skeleton to fill |
| Reflection questions | 0 | 8+ |
| Documentation links | 2 | 5+ |
| Time to complete | ~25 min | ~60 min |
| Learning depth | Shallow | Deep |
| Retention | Low | High |
| Suitable for basics | ✅ | ✅ |
| Suitable for expertise | ❌ | ✅ |

---

## 📚 Additional Resources

### Core Documentation
- **Bicep Fundamentals**: https://learn.microsoft.com/azure/azure-resource-manager/bicep/
- **Azure Resource Templates**: https://learn.microsoft.com/azure/templates/
- **Managed Identity**: https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/
- **RBAC Roles**: https://learn.microsoft.com/azure/role-based-access-control/built-in-roles

### Workshop Files
- **Original README**: `/README.md`
- **Deployment Deep-Dive**: `/DEPLOYMENT-NOTES.md`
- **Version Comparison**: `/COMPARISON.md`

---

## ✅ Success Metrics

### For v1
- [ ] Files compile without errors
- [ ] What-If shows 10 resources
- [ ] Students can deploy to Azure
- [ ] Total time < 30 minutes

### For v2
- [ ] All TODOs are completed
- [ ] Files compile without errors
- [ ] What-If shows 10 resources
- [ ] Students can deploy to Azure
- [ ] Students can explain WHY each property exists
- [ ] Students can compare v1 vs v2 approaches
- [ ] Total time ~60 minutes (Deel 1: Bicep)

---

## 🎬 Example Workshop Flow (v2)

**0:00 - 0:15 | Intro & Architecture**
- Explain the IoT data pipeline
- Show the 4 modules and why they're separate
- Discuss Managed Identity concept

**0:15 - 0:35 | storage.bicep Implementation**
- Students read the README-v2
- Follow hints, consult Azure docs
- Implement storage account naming and resources

**0:35 - 0:50 | eventhub.bicep Implementation**
- Same process with Event Hub
- Discuss tier choices (Basic vs Standard)
- Explain consumer groups

**0:50 - 1:05 | function.bicep Implementation**
- Focus on Managed Identity pattern
- Explain why no connection strings
- Discuss app settings with `__` notation

**1:05 - 1:20 | rbac.bicep Implementation**
- Explain role assignments
- Discuss principal IDs and why RBAC comes last
- Implement two role assignments

**1:20 - 1:30 | Validation & Wrap-Up**
- Run `az bicep build` 
- Run what-if analysis
- Discuss deployment strategy

---

## 🤝 Trainer Recommendations

### Before the Workshop
- [ ] Read both `infra/` and `infra-v2-improved/` versions
- [ ] Read `COMPARISON.md` to understand differences
- [ ] Read `DEPLOYMENT-NOTES.md` to prepare explanations
- [ ] Run both versions to ensure they work
- [ ] Decide which version fits your goals

### During the Workshop (v2)
- [ ] Don't give away exact solutions
- [ ] Guide students to documentation
- [ ] Let them discover property names
- [ ] Celebrate when they figure it out
- [ ] Use errors as teaching moments
- [ ] Ask "Why?" questions frequently

### Common Trainer Moves
```
Student: "How do I name the storage account?"
Trainer: "Check the Azure naming conventions. What's unique about storage accounts?"
Student: "They need to be globally unique"
Trainer: "Exactly! So how would you make a unique name?"
Student: "Oh, I could use uniqueString()!"
Trainer: "Perfect! Where would you find that?"
```

---

## 📞 Support

### If students get stuck:
1. **First**: Guide to the documentation link in the TODO
2. **Second**: Reference a similar pattern in another module
3. **Third**: Ask guiding questions ("What does X property do?")
4. **Last resort**: Show the solution from v1

### Common obstacles:
- **"I don't know what property names to use"** → Azure docs has full schema
- **"Why double underscore?"** → DEPLOYMENT-NOTES.md explains it
- **"What's uniqueString()?"** → It's mentioned in storage.bicep hints
- **"Why isn't RBAC first?"** → Dependency ordering section in main.bicep

---

## 🎓 Assessment Ideas

### For v2 Completion
- [ ] All modules compile (`az bicep build`)
- [ ] Student explains 3 design choices
- [ ] Student can modify workload name and re-deploy
- [ ] Student identifies what each RBAC role allows

---

**Choose your version, pick a time slot, and let's build infrastructure-as-code skills!** 🚀

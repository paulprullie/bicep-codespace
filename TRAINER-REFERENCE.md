# 🎯 Trainer Quick Reference: v1 vs v2

A one-page decision guide for workshop organizers.

---

## Decision Matrix

```
                           v1 (infra/)        v2 (infra-v2-improved/)
─────────────────────────────────────────────────────────────────────
Handholding Level          High               Low (guided learning)
Copy-Paste Friendly        ✅ Yes             ❌ No (by design)
Time to Complete           ~25 min            ~60 min
Learning Retention         Low                High
Manages Identity           ✅ Included        ✅ Included
Security Best Practices    ✅ Included        ✅ Included + Explained

Best For:
  Quick demo              ✅ Ideal           ❌ Not ideal
  Bootcamp track          ❌ Not ideal       ✅ Ideal
  Professional training   ❌ Not ideal       ✅ Ideal
  Beginners               ✅ Good            ⚠️  Challenging
  Intermediate dev        ⚠️  Too easy       ✅ Perfect
```

---

## Version Selection Quick Guide

### Pick v1 if ANY of these apply:
- 🏃 Workshop must finish in <35 minutes total
- 👶 Students are 100% new to Bicep/Azure/IaC
- 📺 You're doing a product demo at a conference
- ⏰ Limited trainer availability for Q&A
- 🎬 You want a scripted, repeatable demo

### Pick v2 if ANY of these apply:
- 👨‍💻 Students have basic programming background
- ⏱️ You have 60+ minutes allocated
- 📚 Goal is real competency (not just awareness)
- 🔧 Students will use Bicep professionally
- 🧠 You want higher engagement
- 🏆 You want better learning outcomes
- 💼 This is professional development (not marketing)

---

## Pre-Workshop Checklist

### Both Versions
- [ ] Clone the repo and test `az bicep build`
- [ ] Verify Azure CLI is installed: `az version`
- [ ] Read the original README.md
- [ ] Have credentials ready (AZURE_CREDENTIALS secret)

### For v1
- [ ] (No special prep needed)

### For v2
- [ ] Read infra-v2-improved/README-v2.md
- [ ] Read COMPARISON.md (understand the differences)
- [ ] Read DEPLOYMENT-NOTES.md (prepare explanations)
- [ ] Work through v2 yourself to anticipate questions
- [ ] Prepare hints for common questions

---

## Timing Reference

### v1 Workshop Timing
```
0:00 - 0:05   | Explain architecture
0:05 - 0:15   | Show completed skeleton files
0:15 - 0:20   | Students copy/paste implementations
0:20 - 0:25   | Run `az bicep build` and what-if
0:25 - 0:30   | Q&A, discuss next steps (CI/CD)
───────────────
Total:        ~30 minutes
```

### v2 Workshop Timing
```
0:00 - 0:10   | Intro: Architecture + Azure setup
0:10 - 0:25   | storage.bicep (read docs, implement)
0:25 - 0:38   | eventhub.bicep (guided implementation)
0:38 - 0:50   | function.bicep (Managed Identity focus)
0:50 - 1:00   | rbac.bicep (role assignments)
───────────────
DEEL 1 TOTAL:  ~60 minutes

1:00 - 1:30   | DEEL 2: CI/CD Pipeline (essentials only)
───────────────
FULL WORKSHOP: ~90 minutes

Challenges (VNET, App Insights, etc.): OPTIONAL for fast finishers
```

---

## Common Student Questions by Version

### v1 Questions
- "Where do I paste this code?"
- "What do these parameters mean?"
- "How does Managed Identity work?" (deep dive)
- "Why do I need all these roles?"

### v2 Questions
- "What's the exact syntax for X?"
- "Where do I find the property names?"
- "Why are there two underscores?"
- "Does this need to be in a specific order?"

**Trainer Note:** v2 questions are more about problem-solving, v1 about mechanics.

---

## Key Talking Points by Version

### v1 - Emphasize
✅ "This is production-ready code"
✅ "All resources are properly configured"
✅ "Now you see how Bicep orchestrates deployment"
⚠️ "In real projects, you'll read docs to understand each property"

### v2 - Emphasize
✅ "You're reading Azure documentation"
✅ "Understanding WHY each choice matters"
✅ "The actual workflow for IaC development"
✅ "Security best practices (Managed Identity)"
⚠️ "This is harder, which means you'll learn more"

---

## Troubleshooting Guide

### Issue: Students don't understand output references
**Symptom:** Can't figure out how to pass `eventHub.outputs.namespaceName` to function app
**Fix (v1):** Point to the example in main.bicep comments
**Fix (v2):** Guide them to "Module" section in DEPLOYMENT-NOTES.md, ask "What does the function app need from Event Hub?"

### Issue: What-if shows "2 unsupported"
**Symptom:** Students think deployment will fail
**Fix:** Explain this is normal for RBAC. Check DEPLOYMENT-NOTES.md section on what-if.

### Issue: Storage account name already exists
**Symptom:** Deployment fails with "name already taken"
**Fix:** Unique string generation failed. Check workloadName is unique. Change workloadName parameter.

### Issue: Managed Identity auth failing
**Symptom:** Function can't access storage after deployment
**Fix:** RBAC assignments take a minute to propagate. Wait and retry. Check role assignments with `az role assignment list`.

### Issue: Event Hub has too many partitions
**Symptom:** Bicep error "partition count must be between 1 and 32 for Basic tier"
**Fix:** Basic tier max is 32. Remind student about tier limitations.

---

## Facilitation Tips

### For v1
- Move quickly through explanations (focus on deployment success)
- Let them focus on seeing the infrastructure get created
- Use what-if output as the "proof it works"
- Save deep questions for v2 or follow-up sessions

### For v2
- Encourage reading documentation (no Google!)
- Celebrate when they discover something
- Use errors as teaching moments
- Ask "Why does this property exist?" frequently
- Let them struggle a bit (learning!), but not too much

### Universal Tips
- Have v2 DEPLOYMENT-NOTES.md open during workshop
- Keep a terminal ready to show `az bicep build` output
- Share links frequently
- Take breaks every 30 minutes
- Allow pairs/groups (learning together is good)

---

## Post-Workshop Next Steps

### After v1
→ Use as foundation for Part 2: CI/CD Pipeline
→ Show how GitHub Actions automates this
→ Optional: Move to v2 for deeper learning

### After v2
→ Students are ready for production Bicep work
→ Part 2: CI/CD will feel natural
→ Challenge: Modify for different scenarios (databases, etc.)
→ Real project: Apply to their own infrastructure

---

## Recommended Preparation

### Minimal (Quick v1 Workshop)
- [x] Read original README.md
- [x] Test `az bicep build`
- [x] Skim skeleton files
- Time: ~30 min prep

### Standard (v2 Workshop)
- [x] Read original README.md
- [x] Read COMPARISON.md
- [x] Read DEPLOYMENT-NOTES.md
- [x] Work through v2 yourself
- [x] Prepare 3-5 key talking points
- Time: ~2 hours prep

### Thorough (Train-the-Trainer)
- [x] All standard prep, plus:
- [x] Work through BOTH versions
- [x] Create cheat sheet for common issues
- [x] Plan Q&A responses in advance
- [x] Record yourself explaining key concepts
- Time: ~4 hours prep

---

## Success Criteria

### v1 Success
- ✅ All students' code compiles
- ✅ What-if shows 10 resources
- ✅ Students understand Azure deployment concepts
- ✅ Workshop completes on time
- ⏱️ < 40 minutes total

### v2 Success
- ✅ All students' code compiles
- ✅ What-if shows 10 resources
- ✅ Students can explain each resource's purpose
- ✅ Students understand Managed Identity benefits
- ✅ Students used documentation effectively
- ✅ Engagement level is high
- ⏱️ ~80 minutes total

---

## One-Liner Descriptions

**Use this when deciding:**

- **v1:** "Here's how Bicep orchestrates Azure infrastructure (15 min + Q&A)"
- **v2:** "Let's learn to read Bicep docs and build infrastructure professionally (60 min + Q&A)"

---

## Backup Plans

### If students are ahead of schedule
- Ask them to modify workloadName and re-deploy
- Have them compare v1 vs v2 code
- Discuss scaling (upgrade to Standard tier Event Hub)
- Show Azure portal visualizations

### If students are behind schedule
- v1: Keep moving, quality over perfection
- v2: Skip some modules (focus on storage + function)
- Focus on understanding, not completion

### If students are very confused
- Go back to architecture diagram
- Re-explain Managed Identity concept
- Show completed v1 code as reference
- Break into smaller groups for help

---

## Final Recommendation

**For Professional Development: Use v2** 🎓

The extra time investment pays dividends in:
- Deeper understanding
- Better retention
- Practical problem-solving skills
- Confidence to modify code
- Real professional competency

**For Quick Product Demo: Use v1** 🚀

Fast, visual, impressive result in 30 minutes.

---

**Questions? Check COMPARISON.md or DEPLOYMENT-NOTES.md** 📚

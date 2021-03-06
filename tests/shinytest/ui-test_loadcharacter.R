library(shinytest)

TestSeed <- 1233
app <- ShinyDriver$new("../../R", seed = TestSeed)
app$snapshotInit("ui-test_loadcharacter")

app$setInputs(uiTabset = "Setup")
app$uploadFile(CharFile = "../character/_Test_Magie+Karma.json")
app$snapshot()
app$setInputs(uiTabset = "Kämpfe")
app$setInputs(chbPredefinedWeapon = TRUE)
app$setInputs(cmbCombatSelectWeapon = "Jagdmesser")
app$snapshot()
app$setInputs(uiTabset = "Handle")
app$setInputs(rdbSkillSource = "CharSkill")
app$setInputs(lbCharSkills = "Körperbeherrschung")
app$snapshot()
app$setInputs(lbSkillClasses = "Magische Fertigkeiten")
app$setInputs(lbCharSkills = "Oculus Illusionis")
app$snapshot()
app$setInputs(lbSkillClasses = "Karmale Fähigkeiten")
app$setInputs(lbCharSkills = "Geisterblick")
app$snapshot()
app$setInputs(uiTabset = "Sei")
app$setInputs(rdbAbilitySource = "CharAbility")
app$setInputs(rdbCharacterAbility = "ATTR_6")
app$snapshot()
app$stop() # Shiny-App stoppen

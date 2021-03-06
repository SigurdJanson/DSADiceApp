# Test skill sets
library(jsonlite)
library(shiny)

.testdir <- getwd()
  setwd("../../R")
  .srcdir <- getwd()
  source("./skillset.R")
setwd(.testdir)
  


# Skill import
sk <- "\"talents\": {\"TAL_3\": 1, \"TAL_4\": 2, \"TAL_8\": 6, \"TAL_9\": 7,
  \"TAL_10\": 4, \"TAL_16\": 3, \"TAL_18\": 5, \"TAL_19\": 6,
  \"TAL_20\": 7, \"TAL_21\": 4, \"TAL_23\": 8, \"TAL_27\": 4,
  \"TAL_31\": 1, \"TAL_32\": 4, \"TAL_33\": 5, \"TAL_34\": 6,
  \"TAL_35\": 1, \"TAL_36\": 8, \"TAL_38\": 5, \"TAL_39\": 4,
  \"TAL_40\": 4, \"TAL_41\": 6, \"TAL_42\": 4, \"TAL_46\": 6,
  \"TAL_47\": 2, \"TAL_48\": 1, \"TAL_50\": 1, \"TAL_54\": 4,
  \"TAL_44\": 1, \"TAL_22\": 2, \"TAL_6\": 3, \"TAL_13\": 1,
  \"TAL_17\": 2}"
ab <- structure(list(ATTR_1 = 12L, ATTR_2 = 11L, ATTR_3 = 13L, ATTR_4 = 14L, 
                     ATTR_5 = 13L, ATTR_6 = 16L, ATTR_7 = 11L, ATTR_8 = 11L), 
                class = "data.frame", row.names = c(NA, -1L))

  
test_that("Empty Skill Set", {
  setwd(.srcdir)
  Set <- SkillSet$new(1)
  setwd(.testdir)
  expect_error(Set$CanRoutineCheck(), "Skill must be identified")
  
  # 
  # Routine Checks
  Set$SetSkill(SkillIdent = 1L, Abilities = c(12, 11, 10), SkillValue = 10)
  # No routine checks, even with unrealistic high modifier (because abilities < 13)
  expect_false(Set$CanRoutineCheck(1L, 99)) 
  Set$SetSkill(SkillIdent = 1L, Abilities = c(13, 13, 12), SkillValue = 10)
  # No routine checks, even with unrealistic high modifier (because abilities < 13)
  expect_false(Set$CanRoutineCheck(1L, 0L))
  expect_false(Set$CanRoutineCheck(1L, 99L))
  # A few edge cases
  o <- Set$SetSkill(SkillIdent = 1L, Abilities = c(13, 13, 13), SkillValue = 10)
  e <- c(abval1 = 13, abval2 = 13, abval3 = 13, value = 10)
  storage.mode(e) <- "integer" # coerce to integer without losing attrs
  expect_identical(o, e)
  expect_true(Set$CanRoutineCheck(1L, 0L))
  expect_false(Set$CanRoutineCheck(1L, -1L))
  Set$SetSkill(SkillIdent = 1L, Abilities = c(13, 13, 13), SkillValue = 9)
  o <- Set$SetSkill(SkillIdent = 1L, SkillValue = 9) # change skill ONLY
  e <- c(abval1 = 13L, abval2 = 13L, abval3 = 13L, value = 9L)
  expect_identical(o, e)
  expect_false(Set$CanRoutineCheck(1L, 0L))
  expect_true(Set$CanRoutineCheck(1L, 1L))

  # Skill index
  expect_identical(Set$GetSkillIndex(1L), 1L)
  expect_identical(Set$GetSkillIndex("ANY"), 1L)
  expect_identical(Set$GetSkillIndex(2L), NA_integer_) # Invalid - only 1 skill available
  expect_identical(Set$GetSkillIndex("TAL_1"), NA_integer_) # Invalid
  
  # Abilities
  expect_identical(Set$GetAbilities(1L), c(abval1 = 13L, abval2 = 13L, abval3 = 13L))
  expect_error(Set$GetAbilities(2L), "Invalid skill index")
  expect_silent(Set$SetAbility(1L, c(NO = 9, AB = 10, CD = 11)))
  # check values
  expect_identical(Set$GetAbilities(1L), c(abval1 = 9L, abval2 = 10L, abval3 = 11L))
  # check "attrIDs" that shall not be used because they do not match "ATTR_"
  expect_identical(unlist(Set$Skills[1, c("ab1", "ab2", "ab3")]), 
                   c(ab1 = "", ab2 = "", ab3 = ""))
  # again but with valid attrIDs
  expect_silent(Set$SetAbility(1L, c(ATTR_97 = 1L, ATTR_98 = 19L, ATTR_99 = 2L)))
  expect_identical(Set$GetAbilities(1L), c(abval1 = 1L, abval2 = 19L, abval3 = 2L))
  expect_identical(unlist(Set$Skills[1, c("ab1", "ab2", "ab3")]), 
                   c(ab1 = "ATTR_97", ab2 = "ATTR_98", ab3 = "ATTR_99"))
  # No abilities to check against
  expect_silent(Set$SetAbility(1L, c(-1L, -1L, -1L)))
  expect_false(Set$CanRoutineCheck(1L, 99L))
  expect_silent(Set$Roll(1L, 99L, Routine = FALSE))
  expect_identical(Set$VerifyLastRoll(), 
                   list(Message = "", QL = "-", Remainder = NA))
  
  # reset to avoid follow-up errors
  expect_silent(Set$SetAbility(1L, c(13L, 13L, 13L)))
  
  # Skill values
  e <- c(abval1 = 13L, abval2 = 13L, abval3 = 13L, value = 9L) # see above
  expect_identical(Set$GetSkillValues(1L, 0L), e)
  expect_identical(Set$GetSkillValues(1L, 0L, NoSkill = TRUE), e[1:3])
  expect_identical(Set$GetSkillValues(2L, 0L), NA)
  expect_identical(Set$GetSkillValues(2L, 0L, NoSkill = TRUE), NA)
  expect_identical(Set$GetSkillValues("TAL_1", 0L), NA)
  
  # Rolling and results
  for (r in 1L:20L) {
    Set$SetSkill(SkillIdent = 1L, Abilities = c(r, 21L-r, 13L), SkillValue = r %/% 2)
    expect_true(all(Set$Roll(1L, 0L, Routine = FALSE)$LastRoll > 0L))
    expect_true(all(Set$LastRoll < 21L))
    expect_identical(Set$LastSkill, 1L)
  }
  
  # Success and quality levels
  Set$SetSkill(SkillIdent = 1L, Abilities = c(13L, 13L, 13L), SkillValue = 0L)
  Set$LastRoll <- c(13L, 13L, 13L)
  Set$LastModifier <- 0L
  
  o <- Set$VerifyLastRoll()
  expect_identical(o, list(Message = "Success", QL = 1L, Remainder = 0L))
  Set$LastRoll <- c(13L, 14L, 13L)
  o <- Set$VerifyLastRoll()
  expect_identical(o, list(Message = "Fail", QL = 0L, Remainder = -1L))
  expect_identical(Set$GetLastQL(), 0L)
  
  Set$LastModifier <- 1L
  o <- Set$VerifyLastRoll()
  expect_identical(o, list(Message = "Success", QL = 1L, Remainder = 0L))
  expect_identical(Set$GetLastQL(), 1L)
  
  Set$LastRoll <- c(1L, 1L, 13L)
  Set$LastModifier <- 0L
  o <- Set$VerifyLastRoll()
  expect_identical(o, list(Message = "Critical", QL = 1L, Remainder = 0L))
  expect_identical(Set$GetLastQL(), 1L)
  
  Set$LastRoll <- c(20L, 1L, 20L)
  o <- Set$VerifyLastRoll()
  expect_identical(o, list(Message = "Fumble", QL = 0L, Remainder = 0L))
  expect_identical(Set$GetLastQL(), 0L)
})


test_that("Profane Skill Set", {
  setwd(.srcdir)
  Set <- SkillSet$new(1L, sk, ab)
  setwd(.testdir)
  
  expect_silent(o <- Set$GetSkillIndex("TAL_1"))
  expect_identical(o, 1L)
  expect_identical(Set$GetSkillName("TAL_1"), "Fliegen")
  expect_identical(Set$GetSkillName("Fliegen"), "Fliegen")
  expect_identical(Set$GetSkillName(1), "Fliegen")
  
  expect_silent(o <- Set$GetSkillIndex("TAL_59"))
  expect_identical(o, 59L)
  expect_identical(Set$GetSkillName("TAL_59"), "Stoffbearbeitung")
  expect_identical(Set$GetSkillName("Stoffbearbeitung"), "Stoffbearbeitung")
  expect_identical(Set$GetSkillName(59), "Stoffbearbeitung")

  expect_identical(Set$GetSkillID("TAL_30"), "TAL_30")
  expect_identical(Set$GetSkillID("Wildnisleben"), "TAL_30")
  expect_identical(Set$GetSkillID(30), "TAL_30")
  
  o <- Set$GetSkillIndex(c("TAL_1", "TAL_59"))
  expect_identical(o, c(1L, 59L))
  
  #
  o <- Set$GetSkillName("All")
  expect_length(o, 59)
  expect_type(o, "character")
  
  # 
  o <- Set$GetClasses()
  e <- c("Körpertalente","Gesellschaftstalente", "Naturtalente", 
         "Wissenstalente", "Handwerkstalente")
  expect_identical(o, e)
})
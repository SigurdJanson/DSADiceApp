# ABILITY TAB

LastAbilityRoll <- reactiveVal()
LastAbilityConfirmationRoll <- reactiveVal()


# Panel: Ability Source: Selection buttons for ability source ----
output$ShowAbilitySoureSelection <- reactive({
  return( !is.null(Character$Attr) )
})
outputOptions(output, 'ShowAbilitySoureSelection', suspendWhenHidden = FALSE)


# Panel: Character Abilities: Selection buttons for ability source ----
output$ShowCharacterAbilities <- reactive({
  return( !is.null(Character$Attr) & input$rdbAbilitySource ==  "CharAbility" )
})
outputOptions(output, 'ShowCharacterAbilities', suspendWhenHidden = FALSE)


# user clicked on specific ability
observeEvent(input$rdbCharacterAbility, {
  Abilities <- Character$Attr
  ActiveAbility <- Abilities[1, names(Abilities) == input$rdbCharacterAbility ]
  # Update (isolate because a change directly triggers result rendering)
  isolate(
    updateSliderInput(session, "inpAbility", value = ActiveAbility)
  )
  # Directly trigger next roll
  isolate(LastAbilityConfirmationRoll(NULL))
  LastAbilityRoll(AbilityRoll())
}, ignoreNULL = TRUE, ignoreInit = TRUE)


# user changed ability value slider
observeEvent(input$inpAbility, {
  isolate(
    updateRadioGroupButtons(session = session, inputId = "rdbCharacterAbility", selected = character(0))
  )
  LastAbilityConfirmationRoll(NULL) # is invalid after change of ability
}, ignoreNULL = TRUE, ignoreInit = TRUE)



# Main Panel ----

# Initiate ability roll and store die result
observeEvent(input$doAbilityRoll, {
  isolate(LastAbilityConfirmationRoll(NULL)) # is invalid after re-roll
  LastAbilityRoll(AbilityRoll())
  RollInProgress("doAbilityRoll", TRUE)
}, ignoreInit = TRUE)


# initiate confirmation roll
observeEvent(input$doAbilityConfirmationRoll, {
  LastAbilityConfirmationRoll( AbilityRoll() )
})


# Display result of skill roll
output$AbilityRoll <- renderText({
  Value <- req(LastAbilityRoll(), cancelOutput = TRUE)

  # Restore the buttons
  Sys.sleep(0.05)
  shinyjs::delay(700, RollInProgress("doAbilityRoll", FALSE))

  Confirmation <- LastAbilityConfirmationRoll()
  SuccessStr   <- VerifyAbilityRoll(Value, input$inpAbility, input$inpAbilityMod)

  # Critical or Fumble waiting for confirmation
  if (SuccessStr == "Critical" || SuccessStr == "Fumble") {
    if (!is.null(Confirmation)) {
      ConfirmationResult <- VerifyAbilityRoll(Confirmation, input$inpAbility, input$inpAbilityMod)
      SuccessStr <- VerifyConfirmation( SuccessStr, ConfirmationResult )
      ConfirmationStr <- RenderRollConfirmation(SuccessStr, Confirmation, i18n)
    } else {
      Label <- i18n$t(ifelse(SuccessStr == "Critical", "Confirm!", "Avert!"))
      ConfirmationStr <- actionLink("doAbilityConfirmationRoll", Label)
    }
  } else {
    ConfirmationStr <- NULL
  }

  Result <- RenderRollKeyResult(SuccessStr, Value)
  if (!is.null(ConfirmationStr)) # add confirmation <div/>
    Result <- div(Result, div( ConfirmationStr ),
                  class = "shiny-html-output shiny-bound-output roll")

  return(paste((Result), collapse=""))
})


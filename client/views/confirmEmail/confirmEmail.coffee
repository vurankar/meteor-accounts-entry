Template.entryConfirmEmail.helpers
  error: ->
    if Session.get('entryError')?
      Session.get('entryError')

  logo: ->
    AccountsEntry.settings.logo

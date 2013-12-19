Template.entryForgotPassword.helpers
  error: -> Session.get('entryError')

  logo: ->
    #Meteor.call('entryLogo')
    AccountsEntry.settings.logo

  processing: ->
    Session.get('_accountsEntryProcessing')

Template.entryForgotPassword.events
  'submit #forgotPassword': (event) ->
    event.preventDefault()
    Session.set('email', $('input[type="email"]').val())

    if Session.get('email').length is 0
      Session.set('entryError', 'Email is required')
      return

    Session.set('_accountsEntryProcessing', true)
    
    Accounts.forgotPassword({
      email: Session.get('email')
      }, (error)->
        if error
          Session.set('entryError', error.reason)
        else
          Router.go AccountsEntry.settings.homeRoute
        Session.set('_accountsEntryProcessing', false)
    )

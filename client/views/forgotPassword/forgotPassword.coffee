Template.entryForgotPassword.helpers
  error: ->
    if Session.get('entryError')?
      Session.get('entryError')

  logo: ->
    AccountsEntry.settings.logo

  processing: ->
    Session.get('_accountsEntryProcessing')


Template.entryForgotPassword.events
  'submit #forgotPassword': (event) ->
    event.preventDefault()
    Session.set('email', $('input[name="forgottenEmail"]').val())

    if Session.get('email').length is 0
      Session.set('entryError', 'Email is required')
      return

    Session.set('_accountsEntryProcessing', true)

    if Meteor.settings.public.useIDP == "local"
      #reset local password
      Accounts.forgotPassword
        email: Session.get('email')
      , (error)->
        if error
          Session.set('entryError', error.reason)
        else
          Router.go AccountsEntry.settings.homeRoute
        Session.set('_accountsEntryProcessing', false)
    else
      #reset okta password
      Meteor.call('entryForgotPassword',Session.get('email'), (err, data) ->
        if err
          Session.set('entryError', "Failed to reset password")
        else
          Session.set('_accountsEntryProcessing', false)
          Router.go('/confirm-email');

      )


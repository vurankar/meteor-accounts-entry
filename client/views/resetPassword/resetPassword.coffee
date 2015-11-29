Template.entryResetPassword.helpers
  error: ->
    Session.get('entryError')

  logo: ->
    AccountsEntry.settings.logo

Template.entryResetPassword.events

  'submit #resetPassword': (event) ->
    event.preventDefault()
    password = $('input[name="password"]').val()
    confirmPassword = $('input[name="confirmPassword"]').val()

    passwordErrors = do (password)->
      errMsg = []
      msg = false
      if password.length < 7
        errMsg.push T9n.get("error.minChar")
      if password.search(/[a-z]/i) < 0
        errMsg.push T9n.get("error.pwOneLetter")
      if password.search(/[0-9]/) < 0
        errMsg.push T9n.get("error.pwOneDigit")
      if password != confirmPassword
        errMsg.push T9n.get("error.confirmPasswordNotMatch")

      if errMsg.length > 0
        msg = ""
        errMsg.forEach (e) ->
          msg = msg.concat "#{e}\r\n"

        Session.set 'entryError', msg
        return true

      return false

    if passwordErrors then return

    Accounts.resetPassword Session.get('resetToken'), password, (error) ->
      if error
        Session.set('entryError', (error.reason || "Unknown error"))
      else
        Session.set('resetToken', null)
        if not Meteor.user().profile?.onboarding?.gettingStarted
          Router.go "/docs/getting-started.html"
          Meteor.users.update(Meteor.user()._id, {$set: {"profile.onboarding.gettingStarted": true}})
        else
          Router.go AccountsEntry.settings.dashboardRoute

# Template.entryResetPassword.helpers
#   error: ->
#     Session.get('entryError')

#   logo: ->
#     AccountsEntry.settings.logo

# Template.entryResetPassword.events

#   'submit #resetPassword': (event) ->
#     event.preventDefault()
#     password = $('input[name="password"]').val()
#     confirmPassword = $('input[name="confirmPassword"]').val()

#     passwordErrors = do (password)->
#       errMsg = []
#       msg = false
#       if password.length < 8
#         errMsg.push T9n.get("error.minChar")
#       if password.length > 24
#         errMsg.push T9n.get("error.maxChar")
#       if password.search(/[a-z]/) < 0
#         errMsg.push T9n.get("error.pwOneLowercaseLetter")
#       if password.search(/[A-Z]/) < 0
#         errMsg.push T9n.get("error.pwOneUppercaseLetter")
#       if password.search(/[0-9]/) < 0
#         errMsg.push T9n.get("error.pwOneDigit")
#       if password.search(/[\!\@\#\$\%\^\&\.]/) < 0
#         errMsg.push T9n.get("error.pwOneSpecialCharacter")
#       if password != confirmPassword
#         errMsg.push T9n.get("error.confirmPasswordNotMatch")

#       if errMsg.length > 0
#         msg = ""
#         errMsg.forEach (e) ->
#           msg = msg.concat "#{e}\r\n"

#         Session.set 'entryError', msg
#         return true

#       return false

#     if passwordErrors then return

#     Accounts.resetPassword Session.get('resetToken'), password, (error) ->
#       if error
#         Session.set('entryError', (error.reason || "Unknown error"))
#       else
#         Session.set('resetToken', null)
#         if not Meteor.user().profile?.onboarding?.gettingStarted
#           # Router.go "/docs/getting-started.html"
#           Router.go AccountsEntry.settings.dashboardRoute
#           Meteor.users.update(Meteor.user()._id, {$set: {"profile.onboarding.gettingStarted": true}})
#         else
#           Router.go AccountsEntry.settings.dashboardRoute

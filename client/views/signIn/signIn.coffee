# AccountsEntry.entrySignInHelpers = {
#   emailInputType: ->
#     if AccountsEntry.settings.passwordSignupFields is 'EMAIL_ONLY'
#       'email'
#     else
#       'string'

#   emailPlaceholder: ->
#     fields = AccountsEntry.settings.passwordSignupFields

#     if _.contains([
#       'USERNAME_AND_EMAIL'
#       'USERNAME_AND_OPTIONAL_EMAIL'
#       ], fields)
#       return T9n.get("usernameOrEmail")
#     else if fields == "USERNAME_ONLY"
#       return T9n.get("username")

#     return T9n.get("email")

#   logo: ->
#     AccountsEntry.settings.logo

#   isUsernameOnly: ->
#     return AccountsEntry.settings.passwordSignupFields == 'USERNAME_ONLY'

# }

# AccountsEntry.entrySignInEvents = {
#   'submit #signIn': (event) ->
#     console.log("sign in")
#     event.preventDefault()

#     email = $('input[name="email"]').val()
#     if (AccountsEntry.isStringEmail(email) and AccountsEntry.settings.emailToLower) or
#      (not AccountsEntry.isStringEmail(email) and AccountsEntry.settings.usernameToLower)
#       email = email.toLowerCase()

#     Session.set('email', email)
#     Session.set('password', $('input[name="password"]').val())

#     Meteor.loginWithPassword(Session.get('email'), Session.get('password'), (error)->
#       Session.set('password', undefined)
#       if error
#         console.log("error on login", error)
#         Session.set('entryError', T9n.get(error.reason))
#         #T9NHelper.accountsError error
#       else if not Meteor.user().profile?.onboarding?.gettingStarted
#         # Router.go "/docs/getting-started.html"
#         Router.go AccountsEntry.settings.dashboardRoute
#         Meteor.users.update(Meteor.user()._id, {$set: {"profile.onboarding.gettingStarted": true}})
#       else if Session.get('fromWhere')
#         Router.go Session.get('fromWhere')
#         Session.set('fromWhere', undefined)
#       else
#         Router.go AccountsEntry.settings.dashboardRoute
#     )
# }

# Template.entrySignIn.helpers(AccountsEntry.entrySignInHelpers)

# Template.entrySignIn.events(AccountsEntry.entrySignInEvents)


# AccountsEntry.hashPassword = (password) ->
#   digest: SHA256(password),
#   algorithm: "sha-256"


# AccountsEntry.entrySignUpHelpers =
#   showEmail: ->
#     fields = AccountsEntry.settings.passwordSignupFields

#     _.contains([
#       'USERNAME_AND_EMAIL',
#       'USERNAME_AND_OPTIONAL_EMAIL',
#       'EMAIL_ONLY'], fields)

#   showUsername: ->
#     fields = AccountsEntry.settings.passwordSignupFields

#     _.contains([
#       'USERNAME_AND_EMAIL',
#       'USERNAME_AND_OPTIONAL_EMAIL',
#       'USERNAME_ONLY'], fields)

#   showSignupCode: ->
#     AccountsEntry.settings.showSignupCode

#   logo: ->
#     AccountsEntry.settings.logo

#   privacyUrl: ->
#     AccountsEntry.settings.privacyUrl

#   termsUrl: ->
#     AccountsEntry.settings.termsUrl

#   both: ->
#     AccountsEntry.settings.privacyUrl &&
#     AccountsEntry.settings.termsUrl

#   neither: ->
#     !AccountsEntry.settings.privacyUrl &&
#     !AccountsEntry.settings.termsUrl

#   emailIsOptional: ->
#     fields = AccountsEntry.settings.passwordSignupFields

#     _.contains(['USERNAME_AND_OPTIONAL_EMAIL'], fields)

#   processing: ->
#     Session.get('_accountsEntryProcessing')

#   emailAddress: ->
#     Session.get('email')



# AccountsEntry.entrySignUpEvents =
#   'submit #signUp': (event, t) ->
#     event.preventDefault()
#     $(".has-error").removeClass('has-error')

#     username =
#       if t.find('input[name="username"]')
#         t.find('input[name="username"]').value  # .value.toLowerCase() # TEP: WHY DID THEY HAVE THIS?@?@?@!?
#       else
#         undefined
#     if username and AccountsEntry.settings.usernameToLower then username = username.toLowerCase()

#     signupCode =
#       if t.find('input[name="signupCode"]')
#         t.find('input[name="signupCode"]').value
#       else
#         undefined

#     trimInput = (val)->
#       val.replace /^\s*|\s*$/g, ""

#     email =
#       if t.find('input[type="email"]')
#         trimInput t.find('input[type="email"]').value
#       else
#         undefined

#     if AccountsEntry.settings.emailToLower and email then email = email.toLowerCase()

#     if email and not /\@/.test(email)
#       Session.set('entryError', T9n.get("error.invalidEmail"))
#       t.$('input[type="email"]').parent().addClass('has-error')
#       return

#     formValues = SimpleForm.processForm(event.target)
#     extraFields = _.pluck(AccountsEntry.settings.extraSignUpFields, 'field')
#     filteredExtraFields = _.pick(formValues, extraFields)
#     # password = t.find('input[name="password"]').value
#     # confirmPassword = t.find('input[name="confirmPassword"]').value

#     fields = AccountsEntry.settings.passwordSignupFields


#     emailRequired = _.contains([
#       'USERNAME_AND_EMAIL',
#       'EMAIL_ONLY'], fields)

#     usernameRequired = _.contains([
#       'USERNAME_AND_EMAIL',
#       'USERNAME_ONLY'], fields)

#     if usernameRequired && username.length is 0
#       Session.set('entryError', T9n.get("error.usernameRequired"))
#       t.$('input[name="username"]').parent().addClass('has-error')
#       return

#     if username && AccountsEntry.isStringEmail(username)
#       Session.set('entryError', T9n.get("error.usernameIsEmail"))
#       return

#     if emailRequired && email.length is 0
#       Session.set('entryError', T9n.get("error.emailRequired"))
#       t.$('input[type="email"]').parent().addClass('has-error')
#       return

#     errMsg = []
#     msg = false
#     # if password.length < 7
#     #   errMsg.push T9n.get("error.minChar")
#     # if password.search(/[a-z]/i) < 0
#     #   errMsg.push T9n.get("error.pwOneLetter")
#     # if password.search(/[0-9]/) < 0
#     #   errMsg.push T9n.get("error.pwOneDigit")
#     # if password != confirmPassword
#     #   errMsg.push T9n.get("error.confirmPasswordNotMatch")

#     if errMsg.length > 0
#       msg = ""
#       errMsg.forEach (e) ->
#         msg = msg.concat "#{e}\r\n"

#       Session.set 'entryError', msg
#       t.$('input[type="password"]').parent().addClass('has-error')
#       return

#     if AccountsEntry.settings.showSignupCode && signupCode.length is 0
#       Session.set('entryError', T9n.get("error.signupCodeRequired"))
#       t.$('input[name="signupCode"]').parent().addClass('has-error')
#       return

#     Session.set('_accountsEntryProcessing', true)

#     # Meteor.call 'entryValidateSignupCode', signupCode, (err, valid) ->
#     #   if valid
#     #     newUserData =
#     #       username: username
#     #       email: email
#     #       #password: AccountsEntry.hashPassword(password)
#     #       profile: filteredExtraFields
#     #     console.log("call entryCreateUser")
#     #     Meteor.call 'entryCreateUser', newUserData, (err, data) ->
#     #       console.log("entryCreateUser returned")
#     #       if err
#     #         console.log err
#     #         Session.set('entryError', err.reason)
#     #         #T9NHelper.accountsError err
#     #         Session.set('_accountsEntryProcessing', false)
#     #         return
#     #       else
#     #         Session.set('_accountsEntryProcessing', false)
#     #         Router.go "/confirm-email"
#     #         return
#     #       #login on client
#     #       # isEmailSignUp = _.contains([
#     #       #   'USERNAME_AND_EMAIL',
#     #       #   'EMAIL_ONLY'], AccountsEntry.settings.passwordSignupFields)
#     #       # userCredential = if isEmailSignUp then email else username
#     #       # Meteor.loginWithPassword userCredential, password, (error) ->
#     #       #   Session.set('_accountsEntryProcessing', false)
#     #       #   if error
#     #       #     console.log err
#     #       #     Session.set('entryError', err.reason)
#     #       #     #T9NHelper.accountsError error
#     #       #   else if Session.get 'fromWhere'
#     #       #     Router.go Session.get('fromWhere')
#     #       #     Session.set 'fromWhere', undefined
#     #       #   else
#     #       #     Router.go AccountsEntry.settings.dashboardRoute
#     #   else
#     #     console.log err
#     #     Session.set 'entryError', T9n.get("error.signupCodeIncorrect")
#     #     Session.set('_accountsEntryProcessing', false)
#     #     return

#     Meteor.call 'entryValidateDomain', email, (err, org) ->
#       if org
#         newUserData =
#           username: username
#           email: email
#           #password: AccountsEntry.hashPassword(password)
#           profile: filteredExtraFields
#         console.log("call entryCreateUser")
#         Meteor.call 'entryCreateUser', newUserData, (err, data) ->
#           console.log("entryCreateUser returned")
#           if err
#             console.log err
#             Session.set('entryError', err.reason)
#             #T9NHelper.accountsError err
#             Session.set('_accountsEntryProcessing', false)
#             return
#           else
#             Session.set('_accountsEntryProcessing', false)
#             Router.go "/confirm-email"
#             return
#       else
#         console.log err
#         Session.set 'entryError', T9n.get("error.domainNotRegistered")
#         Session.set('_accountsEntryProcessing', false)
#         return


# Template.entrySignUp.rendered = ->
#   $('[rel="tooltip"]').tooltip()
#   $('[rel="popover"]').popover()

# Template.entrySignUp.helpers(AccountsEntry.entrySignUpHelpers)

# Template.entrySignUp.events(AccountsEntry.entrySignUpEvents)

Meteor.startup ->
  Accounts.urls.resetPassword = (token) ->
    Meteor.absoluteUrl('reset-password/' + token)

  Accounts.urls.enrollAccount = (token) ->
    Meteor.absoluteUrl('reset-password/' + token)

  Accounts.urls.verifyEmail = (token) ->
    Meteor.absoluteUrl('verify-email/' + token)

  Accounts.emailTemplates.enrollAccount.subject = (user) ->
    'Welcome to Riffyn, ' + user.profile.name

  ##On Meteor startup save okta service config including client id and secret
  oktaService = Meteor.settings.private.oAuth.okta
  if oktaService
    ServiceConfiguration.configurations.upsert( { service: "okta" }, {
      $set: oktaService})
  # Accounts.emailTemplates.enrollAccount.html = (user, url) ->
  #   "
  #   <html><body>
  #   Hello #{user.profile.name}
  #   We’re so excited for you to start exploring the Riffyn app. To finish your account creation
  #   you need to set your password by clicking the link below. Once you’ve set your password,
  #   we hope you’ll spend some time getting to know Riffyn. If you have any questions please feel
  #   free to drop us a line by replying to this email.
  #
  #   Set your password here: <a href=\"#{url}\">here</a>
  #
  #   Thank you,
  #   The Riffyn Team
  #   </body></html>
  #   "

  AccountsEntry =
    settings: {}

    config: (appConfig) ->
      @settings = _.extend(@settings, appConfig)

  @AccountsEntry = AccountsEntry

  Meteor.methods
    entryValidateSignupCode: (signupCode) ->
      check signupCode, Match.OneOf(String, null, undefined)
      not AccountsEntry.settings.signupCode or signupCode is AccountsEntry.settings.signupCode

    entryValidateDomain: (email) ->
      check email, String
      domain = email.split("@")[1]
      org = Organizations.findOne({domain: domain})
      unless org and org.deactivated != true and org.selfRegister == true
        return false
      return true

    entryCreateUser: (user) ->
      check user, Object
      domain = user.email.split("@")[1]
      org = Organizations.findOne({domain: domain})
      profile = AccountsEntry.settings.defaultProfile or {}
      if user.username
        userId = Accounts.createUser
          username: user.username,
          email: user.email,
          org: {_id: org._id, name: org.name}
          profile: _.extend(profile, user.profile)
      else
        userId = Accounts.createUser
          email: user.email
          org: {_id: org._id, name: org.name}
          profile: _.extend(profile, user.profile)

      #Send local user activation email.
      #specially useful when there is no internet connection
      if process.env.USE_IDP == "local"
        Accounts.sendEnrollmentEmail(userId, user.email)
      # if (user.email && Accounts._options.sendVerificationEmail)
      #   Meteor.defer ->
      #     console.log("Send Verification Email")
      #     Accounts.sendVerificationEmail(userId, user.email)
      #     console.log("Verification Email Sent")

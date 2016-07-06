Meteor.startup ->
  Accounts.urls.resetPassword = (token) ->
    Meteor.absoluteUrl('reset-password/' + token)

  Accounts.urls.enrollAccount = (token) ->
    Meteor.absoluteUrl('reset-password/' + token)

  Accounts.urls.verifyEmail = (token) ->
    Meteor.absoluteUrl('verify-email/' + token)

  Accounts.emailTemplates.enrollAccount.subject = (user) ->
    'Welcome to Riffyn, ' + user.profile.name

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
      unless org and org.deactivated != true
        return false
      return true

    entryCreateUser: (user) ->
      check user, Object
      profile = AccountsEntry.settings.defaultProfile or {}
      if user.username
        userId = Accounts.createUser
          username: user.username,
          email: user.email,
          #password: user.password,
          profile: _.extend(profile, user.profile)
      else
        userId = Accounts.createUser
          email: user.email
          #password: user.password
          profile: _.extend(profile, user.profile)

      Accounts.sendEnrollmentEmail(userId, user.email)
      # if (user.email && Accounts._options.sendVerificationEmail)
      #   Meteor.defer ->
      #     console.log("Send Verification Email")
      #     Accounts.sendVerificationEmail(userId, user.email)
      #     console.log("Verification Email Sent")

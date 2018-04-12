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
  oktaService = Meteor.settings.public.okta

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
      if Meteor.settings.public.useIDP == "local"
        Accounts.sendEnrollmentEmail(userId, user.email)

    ###
    TODO: move this method to the new package along with accounts-entry migration
    ###
    entryForgotPassword: (email) ->
      if not email
        throw new Meteor.Error(500, "Email cannot be blank")

      user = Meteor.users.findOne({"emails.address": email});

      if !user
        throw new Meteor.Error(500, "User not found")

      syncResetPassword = Meteor.wrapAsync(OktaClient.resetPassword)

      OktaClient.forgotPassword email, (err, forgotPwd) ->
        if err
          if err.errorCode == "E0000017" or err.errorCode == "E0000034"
            console.log "Forgot password failed for user #{email} trying reset password"
            resetPwd = syncResetPassword email

        if forgotPwd and forgotPwd.resetPasswordUrl
          link = "#{forgotPwd.resetPasswordUrl}?fromURI=#{Meteor.absoluteUrl()}"
        else if resetPwd and resetPwd.resetPasswordUrl
          link = "#{resetPwd.resetPasswordUrl}?fromURI=#{Meteor.absoluteUrl()}"
        else
          console.log "Forgot password and Reset password failed for #{email}"
          throw new Meteor.Error(500, "Forgot password failed")

        emailBody = Accounts.emailTemplates.forgotPasswordOkta
        emailBody = emailBody.replace("FIRSTNAME", user.profile.name).replace("USERNAME", email).replace("PASSWORDRESET_LINK", link)

        Email.send({
          to: email,
          from: "no-reply@riffyn.com",
          subject: "Riffyn forgot password",
          html: emailBody
        })

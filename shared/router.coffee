

Router.map ->

  @route "entrySignIn",
    path: "/sign-in"
    onBeforeAction: ->
      if Meteor.settings.public.useIDP != 'local'
        @render 'OktaSignIn'
        return
      #Session.set('entryError', undefined)
      Session.set('buttonText', 'in')
      # TEP:  Added to make things work !?!?!
      #if Router.current().route?.getName() not in AccountsEntry.routeNames
      #  Session.set('fromWhere', Router.current().path)
      @next()
    onRun: ->
      Session.set('entryError', undefined)
      if Meteor.userId()
        Router.go AccountsEntry.settings.dashboardRoute
      else
        if AccountsEntry.settings.signInTemplate
          @template = AccountsEntry.settings.signInTemplate

          # If the user has a custom template, and not using the helper, then
          # maintain the package Javascript so that OpenGraph tags and share
          # buttons still work.
          pkgRendered= Template.entrySignIn.rendered
          userRendered = Template[@template].rendered

          if userRendered
            Template[@template].rendered = ->
              pkgRendered.call(@)
              userRendered.call(@)
          else
            Template[@template].rendered = pkgRendered

          Template[@template].events(AccountsEntry.entrySignInEvents)
          Template[@template].helpers(AccountsEntry.entrySignInHelpers)
        @next()
    onStop: ->
      Session.set('entryError', undefined)



  @route "entrySignUp",
    path: "/sign-up"
    onBeforeAction: ->
      #Session.set('entryError', undefined)
      Session.set('buttonText', 'up')
      @next()
    onRun: ->
      Session.set('entryError', undefined)
      if AccountsEntry.settings.signUpTemplate
        @template = AccountsEntry.settings.signUpTemplate

        # If the user has a custom template, and not using the helper, then
        # maintain the package Javascript so that OpenGraph tags and share
        # buttons still work.
        pkgRendered= Template.entrySignUp.rendered
        userRendered = Template[@template].rendered

        if userRendered
          Template[@template].rendered = ->
            pkgRendered.call(@)
            userRendered.call(@)
        else
          Template[@template].rendered = pkgRendered

        Template[@template].events(AccountsEntry.entrySignUpEvents)
        Template[@template].helpers(AccountsEntry.entrySignUpHelpers)
      @next()
    onStop: ->
      Session.set('entryError', undefined)


  @route "entryForgotPassword",
    path: "/forgot-password"
    onRun: ->
      Session.set('entryError', undefined)
      @next()
    onStop: ->
      Session.set('entryError', undefined)


  @route 'entrySignOut',
    path: '/sign-out'
    onRun: ->
      console.log("AE:onRun")
      Session.set('entryError', undefined)
      @next()
    onBeforeAction: ->
      #Session.set('entryError', undefined)
      if AccountsEntry?.settings?.homeRoute?
        Meteor.logout () ->
          Router.go AccountsEntry.settings.homeRoute
      else
        @next()
    onStop: ->
      Session.set('entryError', undefined)


  @route 'entryResetPassword',
    path: 'reset-password/:resetToken'
    onRun: ->
      console.log("AE:onRun")
      Session.set('entryError', undefined)
      @next()
    onBeforeAction: ->
      #Session.set('entryError', undefined)
      Session.set('resetToken', @params.resetToken)
      @next()
    onStop: ->
      Session.set('entryError', undefined)


  # TEP:  Add for it seems the normal URL gets swallowed
  @route 'entryVerifyEmail',
    path: 'verify-email/:token'
    onBeforeAction: ->
      try
        Accounts.verifyEmail @params.token, ->
          console.log("Email Verified")
          AccountsEntry?.settings?.verifyEmailCallback?()
      catch e
        console.log("Email verify error", e)
        AccountsEntry?.settings?.verifyEmailCallback?(e)
      if AccountsEntry?.settings?.homeRoute?
        Router.go AccountsEntry.settings.homeRoute
      else
        @next()
    onStop: ->
      Session.set('entryError', undefined)

  @route "entryConfirmEmail",
    path: "/confirm-email"
    onRun: ->
      Session.set('entryError', undefined)
      @next()
    onStop: ->
      Session.set('entryError', undefined)


###
if Meteor.isClient
  # Get all the accounts-entry routes one time
  exclusions = []
  _.each Router.routes, (route)->
    exclusions.push route.getName()
  # Change the fromWhere session variable when you leave a path
  Router.onStop ->
    Tracker.nonreactive ->
      # If the route is an entry route, no need to save it
      if (!_.contains(exclusions, Router.current()?.route?.getName?()))
        console.log("set fromWhere", Iron.Location.get().path, Router.current()?.route?.getName?(), exclusions)
        Session.set('fromWhere', Iron.Location.get().path)
###


if Meteor.isClient
  #catch onlogin failures and redirect to static error page
  Accounts.onLoginFailure (err) ->
    console.log("on login error:" + JSON.stringify(err))
    errno = err?.error?.error
    if errno == 418 or errno == 401
      Router.go 'othervpc'

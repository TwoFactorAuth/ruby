==============================================================================

To finish setting up FidoLogin:

1. Ensure you have flash :alert messages in your layout (probably
   `app/views/layouts/application.html.erb`) for error messages.

2. Ensure your page has a div with the class 'fidologin-status' for
   client-side errors (like if the user attaches the wrong authentication
   device, or none at all). This is independent of the flash alert, but you
   can put it on the same div if you make sure the 'fidologin-status' div
   exists and is visible even without any flash alerts/errors set. Example:

    <div class="alert fidologin-status"><%= alert %></div>

2. Run `rails generate fido_login:install && rake db:migrate` and edit
   config/initializers/fido_login.rb to include your app's domain name.

3. If you roll your own Registrations/Authentications controller, remember to
   never ever show the error messages from the Verifiers in production. The
   messages are useful for debugging FidoLogin, your app, or your JavaScript,
   but they would also be very useful to an attacker trying to bypass or break
   your two-factor authentication.

==============================================================================

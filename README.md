TwoFactorAuth
=============

You know your users reuse passwords. Their account on your site is only as
safe as the least-secure site they've ever reused their password on... so, not
very safe at all.

Two factor authentication ("2FA") is a step up for your site's security. Users
provide their password and then connect a USB security key. Stolen passwords are
no longer a disaster.

Google started an industry alliance called FIDO to create a very smart standard
called Universal Second Factor ("U2F").

 * GMail, PayPal, and Salesforce.com already support it
 * Security keys are cheap ($6-18 USD) and available from many vendors
 * Users can use a single security key on any number of sites
 * ...without installing drivers or typing random numbers
 * ...and reusing a key doesn't let sites track the user betwen them
 * Sites don't have to authenticate any external service
 * ...or pay a licensing fee to FIDO or a patent holder

U2F is young and growing. Google Chrome supports it fully. Mozilla Firefox is
developing support now. Microsoft has joined the Board of Directors for FIDO
Alliance, so Internet Explorer should support it soon. (Safari support seems
likely, but Apple is famouly hard to predict.)

The TwoFactorAuth gem drops into your site to add support for U2F. You don't
have to learn the crypto behind it, you just integrate it into your user
interface. This should take an hour or two.

Install
-------

The steps below assume you're using TwoFactoAuth with Ruby on Rails. I will
write non-Rails instructions later.

1.  Add it to your Gemfile and run `bundle install`:

    ```ruby
    gem "two_factor_auth"
    ```

2.  Show server-side errors (like a failed authentication) by displaying flash
    `:alert` messages, usually in `app/views/layouts/application.html.erb`. See
    [the Rails Guide](http://guides.rubyonrails.org/action_controller_overview.html#the-flash)
    for more information.

3.  Show client-side errors (like using the wrong device) from the security key
    by including a div with the class `twofactorauth-status`. This div must exist
    and be visible even **without** any flash alerts/errors from the server.

    If your flash[:alert] div is always present, you can combine these two steps:

    ```html
    <div class="alert twofactorauth-status"><%= flash[:alert] %></div>
    ```

4.  Generate the initializer and run the migration:

    ```bash
    rails generate two_factor_auth:install
    rake db:migrate
    rake db:migrate RAILS_ENV=test
    ```

    Edit `config/initializers/two_factor_auth.rb` to include your app's domain
    name. For security reasons, U2F won't authenticate against "localhost" or
    fake top-level domains like ".dev", so you may need to add an alias to
    `/etc/hosts` and use that when developing locally:

    ```
    127.0.0.1 dev.myapp.com
    ```

5.  When you want to require registration or authentication in your
    controllers, call the filter:

    ```
    before_action :two_factor_auth_registration
    before_action :two_factor_auth_authentication
    ```

    If you only want to require users authenticate if they've registered a key:

    ```
    before_action :two_factor_auth_authentication, if: :user_two-factor_auth_registered?
    ```

6.  TwoFactorAuth ships with a RegistrationsController and AuthenticationsController,
    use `rake routes` to see how to link into them.

7.  If you roll your own Registrations/Authentications controller, remember to
    **never ever show the error messages from the Verifiers in production**. The
    messages are useful for debugging TwoFactorAuth, your app, or your
    JavaScript, but they would also be very useful to an attacker trying to
    bypass or break your two-factor authentication.

Is it any good?
---------------

Yes!

Integrating TwoFactorAuth is an hour or two, mostly front-end coding. You get
well-tested code to keep your users safer.

Implementing it yourself is... frustrating. U2F is well-designed and robust, but
the specification is 34,000 words of dense, fairly confusing documentation. For
example, it took me five hours to track down a parameter that had to be
formatted a single character differently from every example. This was never
explained, but a link in a single footnote led to another spec that defined it
implicitly after about 4,500 words. And that's before integrating with finicky,
magical code like Rails and Devise. Save yourself four weeks of senior dev time
and use TwoFactorAuth.

Contributing
------------

See TODO for what's planned and might affect your code. I'd love to hear what
you're thinking of writing by email (run `git log --format="format:%an <%ae>"`)
or on IRC as `pushcx` on [Freenode](https://freenode.net).

Fork the repo, make your change in a branch, don't forget to run the tests, and
send a pull request. Because of the dual-licensing (explained below), you'll
need to sign a Contrubutor License Agreement. I'll post that soon.

License
-------

TwoFactorAuth is available at no charge under the Affero General Public
License v3 (note that section 13 will apply to the codebase you use this in),
see LICENSE for details.

https://www.twofactorauth.io/rails

If you don't want to publish your app's code, visit the gem's homepage for a
commercial license that includes support and, if you want, installation.

If you would like to have a licensing flamewar, please contact me on Slashdot
in 1998, as that is the only time and place I have had the interest in one.
Even RMS approves of selling exceptions to the GPL.

# Set facet_domain to the domain name your users see in the URL bar
if Rails.env.production?
  FidoLogin.facet_domain = "https://www.example.com"

  # Optional: If you have in-depth knowledge of the U2F spec and wnat to
  # generate your own Trusted Facet List, delete the production facet_domain
  # setting above and customize this: (you can still use facet_domain in dev)
  # FidoLogin.trusted_facet_list_url = 'https://www.example.com/ExampleAppId'
elsif Rails.env.staging?
  FidoLogin.facet_domain = "https://staging.example.com"
else
  # The standard prohibits "localhost" or "local.dev", add an alias to /etc/hosts and use that
  FidoLogin.facet_domain = "http://local2fa.example.com:3000"
end

# Optional: if you want your users to be able to authenticate against multiple
# domains names or apps, they will *all* have to be served via https and
# listed here. Yes, 'www.example.com' and 'example.com' count as different.
FidoLogin.facets = [
  # 'https://example.com',
  # 'https://www.example.com',
  # 'https://www.example.net',
  # 'https://blog.example.com',
  # 'https://admin.example.com',
  # 'https://staging.example.com',
  # 'https://account.example.com',

  # Use this format for iOS apps:
  # 'ios:bundle-id:example-ios-bundle-id',

  # Use this format for Android apps, inserting the sha1 (see below):
  # 'android:apk-key-hash:example-sha1-hash-of-apk-signing-cert',
  # To get the sha1, edit this command to include your keystore path and run
  # it in Linux, BSD, or OS X to export the signing certificate in DER format,
  # hash, base64 encode and trim trailing '=':
  # keytool -exportcert -alias androiddebugkey -keystore <your-path-to-apk-signing-keystore> &>2 /dev/null | openssl sha1 -binary | openssl base64 | sed 's/=//g'
]


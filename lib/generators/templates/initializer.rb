# Set app_domain to the domain name your server uses in production and in
# development.


if Rails.production?
  FidoLogin.app_domain = "https://www.example.com"

  # Optional: If you have in-depth knowledge of the U2F spec and wnat to
  # generate your own Trusted Facet List, delete the production app_domain
  # setting above and customize this: (you can still use app_domain in dev)
  # FidoLogin.trusted_facet_list_url = 'https://www.example.com/ExampleAppId'
else
  FidoLogin.app_domain = "http://local.dev:3000"
end

# Optional: if you want your users to be able to authenticate against multiple
# domains names or apps, they will *all* have to be served via https and
# listed here.
FidoLogin.app_domains = [
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


# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_back_to_care_session',
  :secret      => '96b331c809e1e0301d7dc23fc5f146a0b3ae57ad10c6fb92d77deb2a45420453cf6aca1cb229bc303d98c07ef30819126b8f6c0914a13a0aac534228e418b13c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

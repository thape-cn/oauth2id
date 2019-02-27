class User::RegistrationsController < Devise::RegistrationsController
  layout 'sessions', only: %i[new create]
end

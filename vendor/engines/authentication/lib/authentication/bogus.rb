module Authentication

  # A fake authentication system for use in a development environments.
  # This is ideal for cases where the productino environment uses some
  # complex authentication that cannot be simulated in the development
  # environment easily.
  class Bogus

    # Any password will authenticate. This is to encourage people
    # to not use this in the production environment.
    def authenticate(user, password); true end
  end
end
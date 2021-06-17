# frozen_string_literal: true

module DatabaseURL
  def self.build(env, rails_env)
    scheme = env["DB_ADAPTER"] || URI.parse(env["DATABASE_URL"] || "").scheme

    username = env["POSTGRES_USER"]
    password = env["POSTGRES_PASSWORD"]

    if username.present?
      userinfo = username.to_s + \
                 (":#{password}" if password.present?).to_s
    end
    userinfo = URI.parse(env["DATABASE_URL"] || "").userinfo if userinfo.blank?

    host = env["POSTGRES_HOST"] || URI.parse(env["DATABASE_URL"] || "").host

    if (rails_env.eql? "test") && env["TEST_POSTGRES_DB"].present?
      database = env["TEST_POSTGRES_DB"]
    else
      database = env["POSTGRES_DB"] || URI.parse(env["DATABASE_URL"] || "").path&.delete("/")
    end

    # POSTGRES_PORT can be something like `tcp://172.17.0.5:5432` in CI, so
    # don't involve it in the DB URL string
    port = URI.parse(env["DATABASE_URL"] || "").port

    scheme + \
      "://" + \
      ("#{userinfo}@" if userinfo.present?).to_s + \
      host.to_s + \
      (":#{port}" if port.present?).to_s + \
      "/" + \
      database.to_s
  end
end

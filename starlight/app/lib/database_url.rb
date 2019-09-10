# frozen_string_literal: true

module DatabaseURL
  def self.build(env)
    scheme = env["DB_ADAPTER"] || URI.parse(env["DATABASE_URL"] || "").scheme
    scheme = "sqlite3" if scheme.blank?

    username = env["POSTGRES_USER"]
    password = env["POSTGRES_PASSWORD"]

    if username.present?
      userinfo = username.to_s + \
                 (":#{password}" if password.present?).to_s
    end
    userinfo = URI.parse(env["DATABASE_URL"] || "").userinfo if userinfo.blank?

    host = env["POSTGRES_HOST"] || URI.parse(env["DATABASE_URL"] || "").host
    database = env["POSTGRES_DB"] || URI.parse(env["DATABASE_URL"] || "").path&.delete("/")

    # POSTGRES_PORT can be something like `tcp://172.17.0.5:5432` in CI, so
    # don't involve it in the DB URL string
    port = URI.parse(env["DATABASE_URL"] || "").port

    if scheme == "sqlite3"
      database = if env["DATABASE_URL"].blank?
                   "db/#{Rails.env}.sqlite3"
                 else
                   env["DATABASE_URL"].sub(/^sqlite3\:/, "")
                 end

      "sqlite3:#{database}"
    else
      scheme + \
        "://" + \
        ("#{userinfo}@" if userinfo.present?).to_s + \
        host.to_s + \
        (":#{port}" if port.present?).to_s + \
        "/" + \
        database.to_s
    end
  end
end

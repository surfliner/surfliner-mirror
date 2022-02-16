##
# Provides parsing and methods for dealing with HTTP Accept headers.
class AcceptReader
  ##
  # Creates a new reader for the provided Accept header.
  #
  # @param [String] accept_header
  def initialize(accept_header)
    @types = self.class.parse_accept_header accept_header.to_s
  end

  ##
  # Returns the most preferred JSON‐LD profile of those provided.
  #
  # @param [Array<String>] allowed_profiles
  # @return [String, nil]
  def best_jsonld_profile(allowed_profiles)
    @types.filter_map { |t|
      next unless t[:type] == "application/ld+json" && t[:weight] > 0
      profile = t[:parameters][:profile]
      next unless profile && allowed_profiles.include?(profile)
      profile
    }.min { |a, b| b[:weight] <=> a[:weight] }
  end

  ##
  # Returns the most preferred type of those provided, ignoring JSON‐LD types with profiles.
  #
  # Parameters are ignored.
  # This isn’t really suitable for full and proper content negotiation which takes into account all of a consumer’s preferences.
  #
  # @param [Array<String>] allowed_types
  # @return [String, nil]
  def best_type(allowed_types)
    @types.select { |t|
      next unless allowed_types.include?(t[:type]) && t[:weight] > 0
      next if t[:type] == "application/ld+json" && t[:parameters][:profile]
      true
    }.min { |a, b| b[:weight] <=> a[:weight] }
  end

  class << self
    TOKEN = "[-!#$%&'*+.^_`|~0-9A-Za-z]+"
    QUOTED_PAIR = "(?:\\\\[\\t\\x20\\x21-\\x7E\\u0080-\\u00FF])"
    QUOTED_STRING = "(?:\"(?:[\\t\\x20!\\x23-\\x5B\\x5D-\\x7E\\u0080-\\u00FF]|#{QUOTED_PAIR})*\")"
    PARAMETER_SEPARATOR = "[\\x20\\t]*;[\\x20\\t]*"
    MEDIA_SEPARATOR_RE = /\G[\x20\t]*,[\x20\t]*/
    MEDIA_RANGE_RE = /
      \G(?<media_type_or_wildcard>
        \*\/\*             # double wildcard
      |
        #{TOKEN}\/\*       # type wildcard
      |
        #{TOKEN}\/#{TOKEN} # type and subtype
      )(?<parameters>
        (?:
          #{PARAMETER_SEPARATOR}
          (?!q=)#{TOKEN}(?:=(?:#{TOKEN}|#{QUOTED_STRING}))?
        )*
      )(?<accept_params>
        (?:
          (?<weight>
            #{PARAMETER_SEPARATOR}
            q=(?<qvalue>
              0(?:\.[0-9]{0,3})?|1(?:\.0{0,3})?
            )
          )(?<accept_ext>
            (?:
              #{PARAMETER_SEPARATOR}
              #{TOKEN}(?:=(?:#{TOKEN}|#{QUOTED_STRING}))?
            )*
          )
        )?
      )
    /x
    PARAMETER_SEPARATOR_RE = /\G[\x20\t]*;[\x20\t]*/
    PARAMETER_RE = /\G
      (?<name>
        #{TOKEN}
      )(?:
        =
        (?:
          (?<unquoted>
            #{TOKEN}
          )|(?<quoted>
            #{QUOTED_STRING}
          )
        )
      )?
    /x

    ##
    # Parses the value of an Accept header and returns a list of type
    # hashes with `type`, `parameters`, `weight`, and `extensions`
    # properties.
    #
    # @param [String] header_value
    # @return [Array<Hash>]
    def parse_accept_header(header_value)
      index = 0
      types = []
      loop do
        # parse out types while possible
        match = MEDIA_RANGE_RE.match header_value, index
        raise BadAcceptError, "Invalid Accept header: #{accept_header}" unless match
        types << {
          type: match[:media_type_or_wildcard],
          parameters: parse_parameters(match[:parameters]),
          weight: (match[:qvalue] || 1.0).to_f,
          extensions: parse_parameters(match[:accept_ext])
        }
        index = match.offset(0).last
        if index >= header_value.length
          # end of string
          return types
        else
          # there is more to process; ensure a proper separator and continue
          sep = MEDIA_SEPARATOR_RE.match header_value, index
          raise BadAcceptError, "Invalid Accept header: #{accept_header}" unless sep
          index = sep.offset(0).last
        end
      end
    end

    ##
    # Parses a list of media type parameters and returns a hash of
    # parameter names and values.
    #
    # @param [String] parameter_value
    # @return [Hash]
    def parse_parameters(parameter_value)
      return {} unless !parameter_value.to_s.empty?
      index = 0
      parameters = {}
      loop do
        # parse out parameters while possible
        sep = PARAMETER_SEPARATOR_RE.match parameter_value, index
        return {} unless sep # should always match
        index = sep.offset(0).last
        match = PARAMETER_RE.match parameter_value, index
        return {} unless match # should always match
        parameters[
          match[:name].to_sym
        ] = match[:quoted].gsub(/\A"|"\z/, "") || match[:unquoted]
        index = match.offset(0).last
        return parameters if index >= parameter_value.length
      end
    end
  end

  ##
  # An error indicating an invalid Accept header.
  class BadAcceptError < StandardError
  end
end

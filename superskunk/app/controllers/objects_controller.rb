##
# Support API actions for PCDM Objects
class ObjectsController < ApplicationController
  def self.supported_renderers
    {
      "tag:surfliner.github.io,2022:api/oai_dc" => :render_oai_dc
    }
  end

  def show
    types = self.class.parseAcceptHeader(request.headers["Accept"].to_s)
    return render(plain: "Bad Accept Header", status: 400) unless types
    profile = types
      .select { |t| t[:type] == "application/ld+json" && t[:weight] > 0 }
      .map { |t| t[:parameters][:profile] }
      .select { |p| p && self.class.supported_renderers.has_key?(p) }
      .min { |a, b| b[:weight] <=> a[:weight] }
    return render(plain: "Unknown Accept Type", status: 406) unless profile
    response.headers["Content-Type"] = "application/ld+json; profile=\"#{profile}\""
    send(self.class.supported_renderers[profile])
  end

  def render_oai_dc
    render json: GenericObject.new
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

    # Parses the value of an Accept header and returns a list of type
    # hashes with `type`, `parameters`, `weight`, and `extensions`
    # properties, or `nil` if the header is invalid.
    def parseAcceptHeader(header_value)
      index = 0
      types = []
      loop do
        # parse out types while possible
        match = MEDIA_RANGE_RE.match header_value, index
        return nil unless match
        types << {
          type: match[:media_type_or_wildcard],
          parameters: parseParameters(match[:parameters]),
          weight: (match[:qvalue] || 1.0).to_f,
          extensions: parseParameters(match[:accept_ext])
        }
        index = match.offset(0).last
        if index >= header_value.length
          # end of string
          return types
        else
          # there is more to process; ensure a proper separator and continue
          sep = MEDIA_SEPARATOR_RE.match header_value, index
          return nil unless sep
          index = sep.offset(0).last
        end
      end
    end

    # Parses a list of media type parameters and returns a hash of
    # parameter names and values.
    def parseParameters(parameter_value)
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
end

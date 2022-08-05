# frozen_string_literal: true

##
# This file generated automatically using rdf vocabulary format from http://pcdm.org/use#
require "rdf"
module Valkyrie::Vocab
  # @!parse
  #   # Vocabulary for <http://pcdm.org/use#>
  #   class PCDMUseExtesion < RDF::Vocabulary
  #   end
  class PCDMUseExtesion < RDF::Vocabulary("http://pcdm.org/use#")
    # Ontology definition
    ontology :"http://pcdm.org/use#",
      comment: %(Ontology for a PCDM extension to add subclasses of PCDM File for the
      different roles files have in relation to the Object they are attached to.),
      "dc:modified": %(2015-05-12),
      "dc:publisher": %(http://www.duraspace.org/),
      "dc:title": %(Portland Common Data Model: Use Extension),
      "owl:versionInfo": %(2015/05/12),
      "rdfs:seeAlso": [%(https://github.com/duraspace/pcdm/wiki), %(https://wiki.duraspace.org/display/hydra/File+Use+Vocabulary)]

    # Class definitions
    term :GeoShapeFile,
      comment: %(A shape file in GeoData.),
      label: "Shape file",
      "rdf:subClassOf": %(http://pcdm.org/resources#File),
      "rdfs:isDefinedBy": %(pcdmuse:),
      type: "rdfs:Class"
  end
end

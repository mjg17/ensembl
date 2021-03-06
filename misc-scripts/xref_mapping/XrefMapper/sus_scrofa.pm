=head1 LICENSE

Copyright [1999-2013] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package XrefMapper::sus_scrofa;

use  XrefMapper::BasicMapper;
use  XrefMapper::SubmitMapper;
use strict;
use vars '@ISA';

@ISA = qw{ XrefMapper::BasicMapper };


sub gene_description_filter_regexps {

  return ('^BA\S+\s+\(NOVEL PROTEIN\)\.?',
	  '^DJ\S+\s+\(NOVEL PROTEIN\)\.?',
	  '^LOC\d+\s*(PROTEIN)?\.?',
	  '^Putative uncharacterized protein.*',
	  '^ORF.*',
	  '^PROTEIN C\d+ORF\d+\.*',
	  '\(CLONE \S+\)\s+',
	  '^BC\d+\_\d+\.?',
	  '^CGI\-\d+ PROTEIN\.?\;?',
	  '[0-9A-Z]{10}RIK PROTEIN[ \.]',
	  'R\d{5}_\d[ \.,].*',
	  'PROTEIN KIAA\d+[ \.].*',
	  'RIKEN CDNA [0-9A-Z]{10}[ \.]',
	  '^\(*HYPOTHETICAL\s+.*',
	  '^UNKNOWN\s+.*',
	  '^DKFZP[A-Z0-9]+\s+PROTEIN[\.;]?.*',
	  '^CHROMOSOME\s+\d+\s+OPEN\s+READING\s+FRAME\s+\d+\.?.*',
	  '^FKSG\d+\.?.*',
	  '^HSPC\d+\s+PROTEIN\.?.*',
	  '^KIAA\d+\s+PROTEIN\.?.*',
	  '^KIAA\d+\s+GENE\s+PRODUCT\.?.*',
	  '^HSPC\d+.*',
	  '^PRO\d+\s+PROTEIN\.?.*',
	  '^PRO\d+\.?.*',
	  '^FLJ\d+\s+PROTEIN.*',
	  '^PRED\d+\s+PROTEIN.*',
	  '^WUGSC:.*\s+PROTEIN\.?.*',
	  '^SIMILAR TO GENE.*',
	  '^SIMILAR TO PUTATIVE[ \.]',
	  '^SIMILAR TO HYPOTHETICAL.*',
	  '^SIMILAR TO (KIAA|LOC).*',
	  '^SIMILAR TO\s+$',
          '^WUGSC:H_.*',
          '^\s*\(?PROTEIN\)?\.?\s*$',
	  '^\s*\(?FRAGMENT\)?\.?\s*$',
          '^\s*\(?GENE\)?\.?\s*$',
	  '^\s*\(\s*\)\s*$',
          '^\s*\(\d*\)\s*[ \.]$');

}


sub get_official_name{
   return "PIGGY";
}

sub get_canonical_name{
   return "PIGGY";
}

# Not running transcript_names_from_gene for merged species
# as this is already beng done in the OfficialNaming mapper
sub transcript_names_from_gene {
  return;
}


# For merged species, display xref assigned from the stable_table
# which has been populated by the OfficialNaming mapper
sub set_display_xrefs{
  my $self = shift;
  my $display = XrefMapper::DisplayXrefs->new($self);
  $display->set_display_xrefs_from_stable_table();

}




1;

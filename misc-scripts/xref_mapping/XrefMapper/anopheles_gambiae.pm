package XrefMapper::anopheles_gambiae;

use  XrefMapper::BasicMapper;

use vars '@ISA';

@ISA = qw{ XrefMapper::BasicMapper };

sub get_set_lists {

  return [["ExonerateGappedBest1", ["anopheles_gambiae","*"]]];

}

# transcript, gene display_xrefs can use defaults
# since anopheles_symbol is "before" Uniprot

# If there is an Anopheles_symbol xref, use its description
sub gene_description_sources {

  return ("Anopheles_symbol",
	  "Uniprot/SWISSPROT"
	  "RefSeq_peptide",
	  "RefSeq_dna",
	  "Uniprot/SPTREMBL",
	  "RefSeq_peptide_predicted",
	  "RefSeq_dna_predicted");

}

# regexps to match any descriptons we want to filter out
sub gene_description_filter_regexps {

  return ();

}


1;

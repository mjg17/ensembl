#!/usr/local/bin/perl

=head1 NAME - clone2embl

 provides flat file formats from EnsEMBL databases

=head1 SYNOPSIS - 

    clone2embl dJ271M21

    clone2embl -gff dJ271M21
   
    clone2embl -dbtype ace dJ271M21

    clone2embl -dbtype rdb -host mysql.server.somewhere dJ271M21

    clone2embl -dbtype timdb AL035541           # dump as accession
    clone2embl -dbtype timdb dJ718J7            # dump as accession
    clone2embl -dbtype timdb -noacc dJ718J7     # dump as clone

=head1 OPTIONS

    -verbose   print to STDERR on each clone to dump

    -dbtype    database type (rdb, ace, timdb)

    -dbhost    host name for database

    -dbname    For RDBs, what name to connect to

    -dbuser    For RDBs, what username to connect as

    -dbpass    For RDBs, what password to use

    -nodna     don't write dna part of embl file (for testing)

    -format    [gff/ace/pep] dump in gff/ace/peptides format, not EMBL

    -pepformat What format output to dump to. NB gene2flat is a better
               script now for dumping translations.

    -noacc     [only timdb] by default, regardless of specifing the
               accession for a sanger clone or its clonename, it will
               dump as its accession.  Use -noacc to dump by clonename

    -test      use test database rather than live [only timdb]
               clones in testdb are listed with a T below

    -getall    all clones from the database [no applicable to timdb]

    -usefile   read in on stdin a list of clones, one clone per line

    -start     start point in list of clones (useful with -getall)

    -end       end point in list of clones (useful with -getall)

    -outfile   write output into file instead of to STDOUT

=head1 EXAMPLE CLONES

    dJ271M21/AL031983   T  single contig, mainly forward strand genes, but one reverse

    dJ718J7                single contig, single reverse strand gene with partial transcripts

    C361A3/AL031717     T  unfinished sanger, 3 contigs, 2 ordered by gene predictions

    C367G8/Z97634       T  unfinished sanger, 2 contigs, not ordered by gene predictions

    AP000228               External finished clone

    AC005776               External finished clone

    AC010144               External unfinished clone

=cut

# to find more things in TimDB use:
#~humpub/scripts.devel/set_dbm.pl -f ~/th/unfinished_ana/unfinished_clone -l 10

use strict;

# comment out ace as most people don't have aceperl.
# need a run-time loader really.
#use Bio::EnsEMBL::AceDB::Obj;
use Bio::EnsEMBL::DBSQL::Obj;
use Bio::EnsEMBL::TimDB::Obj;
use Bio::EnsEMBL::EMBL_Dump;
use Bio::AnnSeqIO;
use Bio::SeqIO;

use Getopt::Long;

# global defaults
my $host;
# default is for msql
my $dbtype    = 'rdb';
my $format    = 'embl';
my $nodna     = 0;
my $help;
my $noacc     = 0;
my $aceseq;
my $fromfile  = 0;
my $getall    = 0;
my $pepformat = 'Fasta';
my $test;
my $part;
my $verbose   = 0;
my $cstart    = 0;
my $cend      = undef;
my $outfile;

# defaults for msql (rdb) access
# msql was 'croc'
my $host1     = 'obi-wan';
# msql was 'ensdev'
my $dbname    = 'ens2';
my $dbuser    = 'humpub';
my $dbpass    = 'ens2pass';

# defaults for acedb (humace)
my $host2     = 'humsrv1';
my $port      = '410000';

# this doesn't have genes (finished)
#my $clone  = 'dJ1156N12';
# this does have genes (finished)
#my $clone  = 'dJ271M21';
# this does have genes (unfinished)
# my $clone = '217N14';

&GetOptions( 'dbtype:s'  => \$dbtype,
	     'dbuser:s'  => \$dbuser,
	     'dbpass:s'  => \$dbpass,
	     'host:s'    => \$host,
	     'port:n'    => \$port,
	     'dbname:s'  => \$dbname,
	     'format:s'  => \$format,
	     'nodna'     => \$nodna,
	     'h|help'    => \$help,
	     'noacc'     => \$noacc,
	     'aceseq:s'  => \$aceseq,
	     'pepform:s' => \$pepformat,
	     # usefile to be consistent with other scripts
	     'usefile'   => \$fromfile,
	     'getall'    => \$getall,
	     'test'      => \$test,
	     'part'      => \$part,
	     'verbose'   => \$verbose,
	     'start:i'   => \$cstart,
	     'end:i'     => \$cend,
	     'outfile:s' => \$outfile,
	     );

if($help){
    exec('perldoc', $0);
}

my $db;

my @clones;

if( $fromfile == 1 ) {
    while( <> ) {
	my ($cloneid) = split;
	push(@clones,$cloneid);
    }
} else {
    @clones = @ARGV;
}

if( $dbtype =~ 'ace' ) {
    $host=$host2 unless $host;
    $db = Bio::EnsEMBL::AceDB::Obj->new( -host => $host, -port => $port);
} elsif ( $dbtype =~ 'rdb' ) {
    $host=$host1 unless $host;
    $db = Bio::EnsEMBL::DBSQL::Obj->new( -user => $dbuser, -db => $dbname , 
					 -host => $host, -password => $dbpass );
} elsif ( $dbtype =~ 'timdb' ) {

    # EWAN: no more - you should be able to load as many clones as you like!
    if( $#ARGV == -1 ) {
	push(@clones,'dJ271M21');
    }

    # don't specify clone list if want to do getall, so whole db loads
    my $raclones;
    if(!$getall){
	$raclones=\@clones;
    }

    # clones required are passed to speed things up - cuts down on parsing of flat files
    $db = Bio::EnsEMBL::TimDB::Obj->new($raclones,$noacc,$test,$part);
} else {
    die("$dbtype is not a good type (should be ace, rdb or timdb)");
}

# test report number of clones in db
my $debug_lists=0;
if($debug_lists){
    # all clones
    my @list=$db->get_all_Clone_id();
    print scalar(@list)." clones returned in list\n";
    # clones updated from before when I first started updating
    my @list=$db->get_updated_Clone_id('939220000');
    # clones updated from now (should be none)
    my @list=$db->get_updated_Clone_id(time);
    exit 0;
}

if ( $getall == 1 ) {
    @clones = $db->get_all_Clone_id();
    print STDERR scalar(@clones)." clones found in DB\n";
}

if( defined $cend ) {
    print STDERR "splicing $cstart to $cend\n";

    my @temp = splice(@clones,$cstart,($cend-$cstart));
    @clones = @temp;
}

# set output file
my $OUT;
if($outfile){
    open(OUT,">$outfile") || die "cannot write to $outfile";
    $OUT=\*OUT;
}else{
    $OUT=\*STDOUT;
}

foreach my $clone_id ( @clones ) {

    if( $verbose >= 1 ) {
	print STDERR "Dumping $clone_id\n";
    }


    #
    # wrap in eval to protect from exceptions being
    # thrown. One problem here is that if the exception
    # is thrown during the feature table dumping, then it
    # has still dumped part of the entry. Bad news.
    #

    eval {
	my $clone = $db->get_Clone($clone_id);
	my $as = $clone->get_AnnSeq();
	# choose output mode
	
	
	
	if( $format =~ /gff/ ) {
	    foreach my $contig ( $clone->get_all_Contigs )  {
		my @seqfeatures = $contig->as_seqfeatures();
		foreach my $sf ( @seqfeatures ) {
		    print $OUT $sf->gff_string, "\n";
		}
	    }
	} elsif ( $format =~ /fastac/ ) {
	    my $seqout = Bio::SeqIO->new( -format => 'Fasta' , -fh => $OUT);
	    
	    foreach my $contig ( $clone->get_all_Contigs ) {
		$seqout->write_seq($contig->seq());
	    }
	} elsif ( $format =~ /embl/ ) {
	    &Bio::EnsEMBL::EMBL_Dump::add_ensembl_comments($as);
	    my $emblout = Bio::AnnSeqIO->new( -format => 'EMBL', -fh => $OUT);
	    &Bio::EnsEMBL::EMBL_Dump::ensembl_annseq_output($emblout);
	    if( $nodna == 1 ) {
		$emblout->_show_dna(0);
	    }
	    
	    $emblout->write_annseq($as);
	} elsif ( $format =~ /pep/ ) {
	    my $seqout = Bio::SeqIO->new ( '-format' => $pepformat , -fh => $OUT ) ;
	    my $cid = $clone->id();
	    
	    foreach my $gene ( $clone->get_all_Genes() ) {
		my $geneid = $gene->id();
		foreach my $trans ( $gene->each_Transcript ) {
		    my $tseq = $trans->translate();
		    if( $tseq->seq =~ /\*/ ) {	
			print STDERR $trans-id," got stop codons. Not dumping. on $cid\n";
		    }
		    $tseq->desc("Clone:$cid Gene:$geneid");
		    $seqout->write_seq($tseq);
		}
	    }
	} elsif ( $format =~ /ace/ ) {
	    foreach my $contig ( $clone->get_all_Contigs() ) {
		$contig->write_acedb($OUT,$aceseq);
	    }
	}
    };
    if( $@ ) {
	print STDERR "Dumping Error! Cannot dump $clone_id\n$@\n";
    }
}
    


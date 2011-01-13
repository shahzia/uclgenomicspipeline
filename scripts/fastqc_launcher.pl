=head1 CONTACT

  Please email comments or questions to authors  
 
=cut

=head1 NAME

fastqc_launcher.pl - A script to launch the FastQC QC software

=head1 SYNOPSIS

	perl fastqc_launcher.pl -workplacelist list.txt -ext fq
	
=head1 DESCRIPTION

This script will launch the FastQC analysis software on a series of samples.
Each sample should be in a different folder, and the list of folders should be provided
in the workplacelist text file, one directory per line, absolute path.

The ext option has to be specified to identify the file extension of the FASTQ sequence files

=cut


use strict;
use warnings;
use Getopt::Long;
use IO::File;

#Pick up script name automatically for usage message
my $script=substr($0, 1+rindex($0,'/'));

#Set usage message
my $usage="Usage: $script -workplacelist directoryfilename -ext reads_extension \nPlease try again.\n\n\n";

#Declare all variables needed by GetOpt
my ($workplacelist, $extension);

#Get command-line parameters with GetOptions, and check that all needed are there, otherwise die with usage message
die $usage unless 
	&GetOptions(	'workplacelist:s' => \$workplacelist,
					'ext:s' => \$extension
				)
	&& $workplacelist && $extension;


my $directories = open (DIR, $workplacelist);

while (<DIR>) {

	chomp();
	my $directory = $_;
	print STDERR "moving to directory ".$directory."\n\n";
	chdir $directory;
	
	my $list =`ls *$extension`;
	chomp ($list);
	my @fastqlist = split (/\n/, $list);
	
	
	foreach my $fastqfile (@fastqlist) {
		#Currently hardcoded to Francesco's home, needs move to CONF file
		my $command = "qsub /home/rehbfle/applications/scripts/fastqc.job -v workplace=\"".$directory."\",filename=\"".$fastqfile."\"";
		system ($command);
	}
}
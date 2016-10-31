use strict;
use Cwd;
my $currDir = cwd;

my $session = $ARGV[0];
my $file = $ARGV[1]; #path to file

#open file to read the content
open(FILE,"<".$file) or die "Error: can't open file $file at preProcessor $!\n";
	my @lines = <FILE>;
close(FILE);
print "Pre-processing...\n";

open(TEXT,">temp/text".$session.".txt") or die "Error: can't create text $!\n";
foreach(@lines)
{
	my $tokenized = tokenizeSegment($_);
	$tokenized =~ s/_\s+/ /gi;
	$tokenized =~ s/\s+/ /gi;

	print TEXT trim($tokenized)." ";
}
close(TEXT);


open(META,">temp/metaInfos_".$session.".met") or die "Error: can't create metafile metaInfos.met $!\n";

#processing of the text, line by line (i.e., paragraph by paragraph)
my $paragraphs = 1;
my $sentences = 1;

foreach(@lines)
{
	my $line = $_;
	if (length($line) > 30)
	{
		#$line =~ s/\"//gi;
		print META "--Paragraph $paragraphs\n";

		#process the content of a line of the file through the parser Palavras
		open(TEMP,">temp/temp".$session.".txt") or die "Error writing temp file \n";
		print TEMP $line;
		close(TEMP);
		
		my $commandPalavras = "(cat temp/temp".$session.".txt | /opt/palavras/por.pl | /opt/palavras/bin/dep2tree | perl -wnpe 's/^=//;' | /opt/palavras/bin/visl2tiger.pl | /opt/palavras/bin/extra2sem > temp/AS_".$session.".xml) >/dev/null 2>&1";
	
		system($commandPalavras);
		
		open(FILE,'<:encoding(UTF-8)', "temp/AS_".$session.".xml") or die "Error: can't open the Palavras file $!\n";
		my @AS = <FILE>;
		close(FILE);
		
		my $flag_in_sentence = 0;
		foreach(@AS)
		{
			#controll when in or out the sentence
			if ($_ =~ /<s id="/)
			{
				open (FILE_SENTENCE,">temp/sentence_".$sentences."_".$session.".xml") or die "Error: can't create file to sentence $sentences for $session $!\n";
				print META "temp/sentence_".$sentences."_".$session.".xml\n";
				
				open(SENTENCETEXT,">:utf8","temp/sentenceComplete".$sentences.".txt") or die "Error: can't create file to text of the sentence $sentences $!\n";
				my @partes = split(/text\=\"/,$_);
				$partes[1] =~ s/\"\>$//;
				print SENTENCETEXT $partes[1];
				close(SENTENCETEXT);
				$flag_in_sentence = 1;
			}
			elsif ($_ =~ /<\/s>/)
			{
				print FILE_SENTENCE $_;
				close(FILE_SENTENCE);
				$flag_in_sentence = 0;
				$sentences++;
				print META "--End of Sentence\n";
			}
			
			#print the content of a sentence in the file
			if ($flag_in_sentence == 1)
			{
				print FILE_SENTENCE $_;
			}
		}
		$paragraphs++;
		print META "--End of Paragraph\n";
	}
}
close(META);

sub tokenizeSegment
{
	my $segment = shift;
	open(TOK,">".$currDir."/temp/toTokenize.txt") or die "Error creating 0000toTokenize.txt $!\n";
	print TOK $segment;
	close(TOK);
	
    	system("cat ".$currDir."/temp/toTokenize.txt | /home/nilc/LX_Parser/Tokenizer/run-Tokenizer.sh > ".$currDir."/temp/tokenized.txt");
    	open(TOKENS,"<".$currDir."/temp/tokenized.txt");
    	my @lines =<TOKENS>;
    	close(TOKENS);
    
    	$lines[0] =~ s/\*\// /gi;
   	$lines[0] =~ s/\\\*/ /gi;
    
     	return $lines[0];
}

sub trim($){
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

use strict;
use Cwd;
my $currDir = cwd;


my $instance = <>;
my @segments = split(/\*\*\*/,$instance);
my $s1 = $segments[0];
$s1 = replaces($s1);
my $s2 = $segments[1];
$s2 = replaces($s2);
my $sentenceComplete = $segments[2];
$sentenceComplete = replaces($sentenceComplete);
my $parsedFile = $segments[3];
my $session = trim($segments[4]);

my @relations;
my @totalAttributes;


print "Extracting features...\n";

#source texts
open(FEATURES, ">temp/featuresRelation".$session.".arff") or die "Error: can't creat file to write the features to session $session $!\n";

print FEATURES "
\@RELATION RSTParser\n\n
\@ATTRIBUTE n1 numeric
\@ATTRIBUTE n2 numeric
\@ATTRIBUTE n3 numeric
\@ATTRIBUTE n4 numeric
\@ATTRIBUTE n5 numeric
\@ATTRIBUTE n6 numeric
\@ATTRIBUTE n7 numeric
\@ATTRIBUTE n8 numeric
\@ATTRIBUTE n9 numeric
\@ATTRIBUTE n10 numeric
\@ATTRIBUTE n11 numeric
\@ATTRIBUTE n12 numeric
\@ATTRIBUTE n13 numeric
\@ATTRIBUTE n14 numeric
\@ATTRIBUTE n15 numeric
\@ATTRIBUTE n16 numeric
\@ATTRIBUTE n17 numeric
\@ATTRIBUTE n18 numeric
\@ATTRIBUTE n19 numeric
\@ATTRIBUTE n20 numeric
\@ATTRIBUTE n21 numeric
\@ATTRIBUTE n22 numeric
\@ATTRIBUTE n23 numeric
\@ATTRIBUTE n24 numeric
\@ATTRIBUTE n25 numeric
\@ATTRIBUTE n26 numeric
\@ATTRIBUTE n27 numeric
\@ATTRIBUTE n28 numeric
\@ATTRIBUTE n29 numeric
\@ATTRIBUTE n30 numeric
\@ATTRIBUTE n31 numeric
\@ATTRIBUTE n32 numeric
\@ATTRIBUTE n33 numeric
\@ATTRIBUTE n34 numeric
\@ATTRIBUTE n35 numeric
\@ATTRIBUTE n36 numeric
\@ATTRIBUTE n37 numeric
\@ATTRIBUTE n38 numeric
\@ATTRIBUTE s1 string
\@ATTRIBUTE s2 string
\@ATTRIBUTE s3 string
\@ATTRIBUTE s4 string
\@ATTRIBUTE s5 string
\@ATTRIBUTE s6 string
\@ATTRIBUTE s7 string
\@ATTRIBUTE s8 string
\@ATTRIBUTE s9 string
\@ATTRIBUTE s10 string
\@ATTRIBUTE s11 string
\@ATTRIBUTE s12 string
\@ATTRIBUTE s13 string
\@ATTRIBUTE s14 string
";



open(TMP,"<temp/textAndEDUs".$session.".txt") or die "Error: can't open textAndEDUs file $session $!\n";
my @EDUs = <TMP>;
close(TMP);

print FEATURES "\@ATTRIBUTE class {antithesis_concession_contrast, background_circumstance, interpretation_evaluation_conclusion, evidence_justify_explanation, enablement_motivation_purpose, condition_otherwise, cause_result, attribution, comparison, elaboration, restatement, same_unit, sequence, list, summary, means, joint, solutionhood}\n\n";

print FEATURES "\@DATA\n";


	my @attributes = ();	
	
	#FEATURE 1 - Same sentence
	push(@attributes,"1");
	
	#FEATURE 2 - Sentence borders
	#S1
	push(@attributes,"0");
	#S2
	push(@attributes,"0");
	
	#FEATURE 3 - Tokens of the segments
	#S1
	my @tokens1 = split(/\s+/,$s1);
	push(@attributes,($#tokens1+1));
	#S2
	my @tokens2 = split(/\s+/,$s2);
	push(@attributes,($#tokens2+1));
	
	#FEATURE 4 - number of EDUs
	#S1
	push(@attributes,"1");
	#S2
	push(@attributes,"1");
			
	#FEATURE 5 - Segments over sentence in tokens
	my @tokensSentence = split(/\s+/,$sentenceComplete);
	
	if (($#tokensSentence+1) > 0)
	{
		push(@attributes,(($#tokens1+1)/($#tokensSentence+1)));
	}
	else
	{
		push(@attributes,"0");
	}
	if (($#tokensSentence+1) > 0)
	{
		push(@attributes,(($#tokens2+1)/($#tokensSentence+1)));
	}
	else
	{
		push(@attributes,"0");
	}
	
	#FEATURE 6 - both segments over sentence in tokens
	if (($#tokensSentence+1)>0)
	{
		push(@attributes,((($#tokens1+1)+($#tokens2+1))/($#tokensSentence+1)));
	}
	else
	{
		push(@attributes,"0");
	}
	
	#FEATURE 7 - distance to begin of the sentence in tokens
	my @tokensToBeginSentence1 = split(/$s1/,$sentenceComplete);
	my @tokensToBeginSentence2 = split(/$s2/,$sentenceComplete);
	my @tokensToBeginS1 = split(/\s+/,$tokensToBeginSentence1[0]);
	my @tokensToBeginS2 = split(/\s+/,$tokensToBeginSentence2[0]);
	push(@attributes,($#tokensToBeginS1+1));
	push(@attributes,($#tokensToBeginS2+1));
	
	#FEATURE 8 - distance to begin of the sentence in EDUs
	my $edusToBeginSentence1 = 0;
	my $edusToBeginSentence2 = 0;
	my $distanceInEDUs1 = 0;
	my $distanceInEDUs2 = 0;
	my $pushOK1 = 0;
	my $pushOK2 = 0;
	foreach(@EDUs)
	{
		my $tempEDU = replaces(trim($_));
		if ($s1 eq $tempEDU)
		{
			push(@attributes,$distanceInEDUs1);		
			$pushOK1 = 1;
		}
		elsif ($s2 eq $tempEDU)
		{
			push(@attributes,$distanceInEDUs2);		
			$pushOK2 = 1;
		}
		$distanceInEDUs1++;
		$distanceInEDUs2++;
	}
	if ($pushOK1 == 0)
	{
		push(@attributes,"0");
	}
	if ($pushOK2 == 0)
	{
		push(@attributes,"0");
	}
		
	#FEATURE 9 - distance to the end of the sentence in tokens
	my @tokensToEndS1 = split(/\s+/,$tokensToBeginSentence1[1]);
	my @tokensToEndS2 = split(/\s+/,$tokensToBeginSentence2[1]);
	push(@attributes,($#tokensToEndS1+1));
	push(@attributes,($#tokensToEndS2+1));
	
	#FEATURE 10 - same paragraph
	push(@attributes,"1");	
	
	#FEATURE 11 - paragraph borders
	push(@attributes,"0");
	push(@attributes,"0");
	
	#FEATURE 12 - distance to begin of text in tokens
	open(TEXT,"<temp/text".$session.".txt") or die "Error: can't open text $!\n";
	my @text = <TEXT>;
	close(TEXT);
	my $wholeText = $text[0];
	$wholeText = replaces($wholeText);
	
	my @tokensToBeginText1 = split(/$s1/,$wholeText);
	my @tokensToBeginText2 = split(/$s2/,$wholeText);
	my @tokensToBeginT1 = split(/\s+/,$tokensToBeginText1[0]);
	my @tokensToBeginT2 = split(/\s+/,$tokensToBeginText2[0]);
	push(@attributes,($#tokensToBeginT1+1));
	push(@attributes,($#tokensToBeginT2+1));
	

	############################################################
	#SYNTAX FEATURES 16 to 26
	####################################
	my $parsed = parse($sentenceComplete);
	open(TEMP,">temp/args".$session.".tmp") or die "Error $!\n";
	print TEMP trim($s1)."\n".trim($s2)."\n".trim($parsed)."\n".trim($#tokens1)."\n".trim($#tokens2)."\n";
	close(TEMP);
	
	system("perl extractFeaturesSyntax.pl temp/args".$session.".tmp temp/syntaxFeatures".$session.".tmp");
	
	open(TEMP,"<temp/syntaxFeatures".$session.".tmp") or die "Error $!\n";
	my $synAttr = <TEMP>;
	close(TEMP);
	
	push(@totalAttributes,join(",",@attributes).",".$synAttr.",?\n");
	print FEATURES @totalAttributes;
	#print "\n\n".join(",",@attributes).",".$synAttr.",?\n";
close(FEATURES);



sub parse
{
    my $sentence = shift;
    my $tokenized = tokenizeSegment($sentence);
    
    open(FILE,">".$currDir."/temp/tokenized.txt") or die "Error: cannot write33 tokenized.txt\n";
    print FILE trim($tokenized);
    close(FILE);
    
    my $commandLX_Parser = "(java -Xmx1000m -cp /home/nilc/LX_Parser/stanford-parser-2010-11-30/stanford-parser.jar edu.stanford.nlp.parser.lexparser.LexicalizedParser -tokenized -sentences newline -outputFormat oneline -uwModel edu.stanford.nlp.parser.lexparser.BaseUnknownWordModel /home/nilc/LX_Parser/stanford-parser-2010-11-30/cintil.ser.gz ".$currDir."/temp/tokenized.txt > ".$currDir."/temp/parsed.txt) >/dev/null 2>&1";	
	system($commandLX_Parser);
    
    open(P,"<".$currDir."/temp/parsed.txt") or die "Error: can't open parsed file $1\n";
    my $parsing = <P>;
    close(P);
    return($parsing);
}

sub tokenizeSegment
{
    my $segment = shift;
    open(TOK,">".$currDir."/temp/toTokenize.txt") or die "Error creating t222oTokenize.txt $!\n";
    print TOK $segment;
    close(TOK);
    
    system("cat ".$currDir."/temp/toTokenize.txt | /home/nilc/LX_Parser/Tokenizer/run-Tokenizer.sh > ".$currDir."/temp/tokenized.txt");
    open(TOKENS,"<".$currDir."/temp/tokenized.txt") or die "Error opening tokenized.txt $!\n";
    my @lines =<TOKENS>;
    close(TOKENS);
    
    $lines[0] =~ s/\*\// /gi;
   	$lines[0] =~ s/\\\*/ /gi;
    
    return $lines[0];
}


sub replaces
{
	my $string = shift;
	$string =~ s/\(|\)|\{|\}|\[|\]|\-|\+|\$|\^|\~|\`|\"|\'|\.|\;|\://gi;
	return $string;
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
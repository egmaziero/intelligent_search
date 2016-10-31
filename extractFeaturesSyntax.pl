use strict;
use Cwd;
my $currDir = cwd;

my @tuples;
my @node;
my @mapS1;
my @mapS2;
my $Nw = 'nul';
my $Np = 'nul';
my $Nr = 'nul';
my $lastS1;
my $firstS2;
my $lastS2;


my $verbs1 = 0;
my @verbs1 = ();
my @verbsLemma1 = ();
my $verbs2 = 0;
my @verbs2 = ();
my @verbsLemma2 = ();
my $nouns1 = 0;
my @nouns1 = ();
my @nounsLemma1 = ();
my $nouns2 = 0;
my @nouns2 = ();
my @nounsLemma2 = ();
my $adjs1 = 0;
my @adjs1 = ();
my @adjsLemma1 = ();
my $adjs2 = 0;
my @adjs2 = ();
my @adjsLemma2 = ();
my $advs1 = 0;
my @advs1 = ();
my @advsLemma1 = ();
my $advs2 = 0;
my @advs2 = ();
my @advsLemma2 = ();
my $conjs1 = 0;
my @conjs1 = ();
my $conjs2 = 0;
my @conjs2 = ();
my @contentWords1 = ();
my @contentWords2 = ();

#TeP
open(TeP,"<resources/tep2.txt") or die "Error: cant open tep\n";
my @TEP = <TeP>;
close(TeP);

open(CONJS,"<resources/listConjunctions.txt") or die "Error openning list of Conjunctions $!\n";
my @typesConj = <CONJS>;
close(CONJS);


my $file = $ARGV[0];
my $fileOut = $ARGV[1];

open(FILE,"<$file") or die "Error openning file $file $!\n";
my @args = <FILE>;
close(FILE);

my $s1 = $args[0];
my @tokens1 = split(/\s+/,$s1);
my $s2 = $args[1];
my @tokens2 = split(/\s+/,$s2);
my $parseResult = $args[2];
my $tokensS1 = $args[3];
my $tokensS2 = $args[4];

open(OUT,">$fileOut") or die "Error creating output file $!\n";

my @init;
push(@init,2);


if ($parseResult =~ /ROOT/)
{
	#load structure
	createTreeStructure($parseResult);
	#map bondaries
	mapBoundaries($s1,$s2);
	if ($mapS1[$#mapS1] ne "")
	{
	#search Nw Np Nr
	searchElements();
	if ($Nw ne 'nul')
	{
		#lexical head projection
		lexicalHeadProjection(@init);
		#extract features and create the model
		#open(OUT,">".$fileOut) or die "Error creating $fileOut $!\n";
	
		#FEATURE 16
		print OUT distanceToRoot($Nw).",".distanceToRoot($Nr);
		#FEATURE 17
		my $commonAncestral = 0;
		$commonAncestral = commonAncestral($Nw,$Nr);
		print OUT ",".distanceToCommonAncestral($Nw,$commonAncestral).",".distanceToCommonAncestral($Nr,$commonAncestral); 
		#FEATURE 18
		print OUT ",".((distanceToCommonAncestral($Nw,$commonAncestral)+distanceToCommonAncestral($Nr,$commonAncestral))/2);
		
		#MORPHO FEATURES
	   	calcMorphNumbers();
            	print OUT ",".printMorphNumbers();
            	            
            	@contentWords1 = ();
            	@contentWords2 = ();
            	push(@contentWords1,@verbs1); push(@contentWords1,@nouns1); 			
            	push(@contentWords1,@adjs1); push(@contentWords1,@advs1); 
            	push(@contentWords1,@conjs1);
            	push(@contentWords2,@verbs2); push(@contentWords2,@nouns2); 
            	push(@contentWords2,@adjs2); push(@contentWords2,@advs2); 
            	push(@contentWords2,@conjs2);

	    	print OUT ",".commonTokens("1").",".commonTokens("2");

		print OUT ",".lexicalHeadNode($Nw).",".lexicalHeadNode($Nr);
		print OUT ",".posTagNode($commonAncestral);
		print OUT ",".lexicalHeadNode($commonAncestral);
		print OUT ",".posTagNode($Nw).",".posTagNode($Nw);
		#BROTHERS AND SISTERS
		my $father = $node[$Nw]->{father};
		my @brother = @{ $node[$father]->{kids} };
		my $browNw;
		for(my $i=0; $i<=$#brother; $i++)
		{
			if ($Nw == $brother[$i])
			{
				$browNw = $brother[($i+1)];
				last;
			}
		}
		$father = $node[$Nr]->{father};
		@brother = @{ $node[$father]->{kids} };
		my $browNr;
		for(my $i=0; $i<=$#brother; $i++)
		{
			if ($Nr == $brother[$i])
			{
				$browNr = $brother[($i-1)];
				last;
			}
		}
		print OUT ",".posTagNode($browNw).",".posTagNode($browNr);
		print OUT ",".lexicalHeadNode($browNw).",".lexicalHeadNode($browNr); 
		
		#START type CONJ
    		print OUT ",".typeConj("begin",@tokens1).",".typeConj("begin",@tokens2);

    		#END type CONJ
		print OUT ",".typeConj("end",@tokens1).",".typeConj("end",@tokens2);

		close(OUT);
	}
	else
	{
		print OUT "Error attributes";
	}
}
}
else
{
	print "Error parsing";
}

sub typeConj
{
    my $side = shift;
    my @tokens = @_;
    
    foreach(@typesConj)
    {
        my @parts = split(/,/,trim($_));
        my $conjunction = lc($parts[0]);
        my @count = split(/\s+/,$conjunction);
        my $indexTokens = 0;
        my @beginning;
        my @ending;
        foreach(@count)
        {
            push(@beginning,lc($tokens[$indexTokens]));
            push(@ending,lc($tokens[($#tokens-$indexTokens)]));
            $indexTokens++;
        }
        my $begin = join(" ",@beginning);
        my $end = join(" ",@ending);
        if ($side eq "begin")
        {
            #print "->".$begin." vs ".$conjunction."\n";
            if ($begin eq $conjunction)
            {
                return $parts[2];
            }
        }
        elsif ($side eq "end")
        {
            if ($end eq $conjunction)
            {
                return $parts[2];
            }
        }
    }
    return "noConj";
}


sub printMorphNumbers
{
    if (($tokensS1 > 0) and ($tokensS2 > 0))
    {
        return ($verbs1/$tokensS1).",".($verbs2/$tokensS2).",".($nouns1/$tokensS1).",".($nouns2/$tokensS2).",".($advs1/$tokensS1).",".($advs2/$tokensS2).",".($adjs1/$tokensS1).",".($adjs2/$tokensS2).",".($conjs1/$tokensS1).",".($conjs2/$tokensS2);
    }
    else
    {
        return "Error Attributes";
    }
}

sub commonTokens
{
    my $s = shift;
    my $commonTokens = 0;
    
    foreach(@contentWords1)
    {
        my $tok1 = trim(lc($_));
        foreach(@contentWords2)
        {
            my $tok2 = trim(lc($_));
            if ($tok1 eq $tok2)
            {
                $commonTokens++;
                last;
            }
        }
    }
    if ($s eq "1")
    {
        if ($#contentWords1 > 0)
        {
            return ($commonTokens/$#contentWords1);
        }
        else
        {
            return 0;
        }
    }
    if ($s eq "2")
    {
        if ($#contentWords2 > 0)
        {
            return ($commonTokens/$#contentWords2);
        }
        else
        {
            return 0;
        }
    }
    
}

sub calcMorphNumbers
{
 $verbs1 = 0;
 @verbs1 = ();
 @verbsLemma1 = ();
 $verbs2 = 0;
 @verbs2 = ();
 @verbsLemma2 = ();
 $nouns1 = 0;
 @nouns1 = ();
 @nounsLemma1 = ();
 $nouns2 = 0;
 @nouns2 = ();
 @nounsLemma2 = ();
 $adjs1 = 0;
 @adjs1 = ();
 @adjsLemma1 = ();
 $adjs2 = 0;
 @adjs2 = ();
 @adjsLemma2 = ();
 $advs1 = 0;
 @advs1 = ();
 @advsLemma1 = ();
 $advs2 = 0;
 @advs2 = ();
 @advsLemma2 = ();
 $conjs1 = 0;
 @conjs1 = ();
 $conjs2 = 0;
 @conjs2 = ();
   
    for(my $i=0; $i<=$lastS1; $i++)
    {
        if (trim($node[$i]->{posTag}) eq "V"){
            $verbs1++; push(@verbs1,trim($node[$i]->{word}));
        }elsif (trim($node[$i]->{posTag}) eq "N"){
            $nouns1++;push(@nouns1,trim($node[$i]->{word}));
        }elsif (trim($node[$i]->{posTag}) eq "ADV"){
            $advs1++;push(@advs1,trim($node[$i]->{word}));
        }elsif (trim($node[$i]->{posTag}) eq "A"){
            $adjs1++;push(@adjs1,trim($node[$i]->{word}));
        }elsif (trim($node[$i]->{posTag}) eq "CONJ"){
            $conjs1++;
        }
    }
    for(my $i=$firstS2; $i<=$lastS2; $i++)
    {
        if (trim($node[$i]->{posTag}) eq "V"){
            $verbs2++;push(@verbs2,trim($node[$i]->{word}));
        }elsif (trim($node[$i]->{posTag}) eq "N"){
            $nouns2++;push(@nouns2,trim($node[$i]->{word}));
        }elsif (trim($node[$i]->{posTag}) eq "ADV"){
            $advs2++;push(@advs2,trim($node[$i]->{word}));
        }elsif (trim($node[$i]->{posTag}) eq "A"){
            $adjs2++;push(@adjs2,trim($node[$i]->{word}));
        }elsif (trim($node[$i]->{posTag}) eq "CONJ"){
            $conjs2++;
        }
    }
}


sub posTagNode
{
	my $node = shift;
	#print "posTag commonAncestral node ".$node[$node]->{posTag}."\n";
	return trim($node[$node]->{posTag});
}

sub lexicalHeadNode
{
	my $node = shift;
	#print "Lexical node ".$node[$node]->{word}."\n";
	if (trim(lc($node[$node]->{word})) eq ",")
	{
		$node[$node]->{word} = "comma";
	}
	return lc($node[$node]->{word});
}

sub distanceToRoot
{
	my $nodeID = shift;
	#print "searching distance to $nodeID\n";
	my $distance = 0;
	
	while ((trim($node[$nodeID]->{posTag}) ne "ROOT") and (trim($node[$nodeID]->{posTag}) ne ""))
	{
		#print "--".trim($node[$nodeID]->{posTag})."--\n";
		$nodeID = $node[$nodeID]->{father};
		$distance++;
	}
	
	return $distance;
}

sub commonAncestral
{
	my $nodeID1 = shift;
	my $nodeID2 = shift;
	my @chain1 = ();
	my @chain2 = ();
	while ((trim($node[$nodeID1]->{posTag}) ne "ROOT") and ($nodeID1 > 1))
	{
		$nodeID1 = $node[$nodeID1]->{father};
        #print $nodeID1." 1\n";
		push(@chain1,$nodeID1);
	}
	while ((trim($node[$nodeID2]->{posTag}) ne "ROOT") and ($nodeID2 > 1))
    {
		$nodeID2 = $node[$nodeID2]->{father};
        #print $nodeID1." 2\n";
		push(@chain2,$nodeID2);
	}
	for(my $i=0; $i<=$#chain1; $i++)
	{
		for(my $j=0; $j<=$#chain2; $j++)
		{
			if ($chain1[$i] == $chain2[$j])
			{
				return $chain1[$i];
			}
		}
	}
}

sub distanceToCommonAncestral
{
	my $nodeID = shift;
	my $commonAncestral = shift;
	#print "searching distance to commonAncestral $commonAncestral\n";
	my $distance = 0;
	
	while (trim($node[$nodeID]->{father}) ne $commonAncestral)
	{
		$nodeID = $node[$nodeID]->{father};
		$distance++;
	}
	
	return $distance;
}

sub showTreeStructure
{
	my @kids = @_;
	#print "Current: ".$kids[0]."==================================with $#kids\n";
	if ($#kids >= 0)
	{
		foreach(@kids)
		{
			my $n = $_;
			print $node[$n]->{posTag}." ".$node[$n]->{word}."\n";
			my @kids2 = @{ $node[$n]->{kids} };
			print "KIDS: ";
			for(my $i=0; $i<=$#kids2; $i++)
			{
				print $kids2[$i]."\t";
			}
			print "\n";
			showTreeStructure(@{ $node[$n]->{kids} });
		}	
	}
}
sub lexicalHeadProjection
{
    my @kids = @_;
    #print "Lexical Head with $#kids\n";
	
	if ($#kids >= 0)
	{
		foreach(@kids)
		{
            #print $_."\n";
			my $n = $_;
			lexicalHeadProjection(@{ $node[$n]->{kids} });
			
			if ($#{ $node[$n]->{kids} } >= 0)
			{
				#search the children's tag
				my @kids2 = @{ $node[$n]->{kids} };
				my $fatherTag = $node[$n]->{posTag};
				my $max = 0;
				my $word = "";
				for(my $i=0; $i<=$#kids2; $i++)
				{
					my $score = scoreTag($node[$kids2[$i]]->{posTag},$fatherTag);
                    #print "Father tag $fatherTag score tag ".$node[$kids2[$i]]->{posTag}." = ".$score." and max = $max\n";
					if ($score > $max)
					{
						$max = $score;
						$word = $node[$kids2[$i]]->{word};
                        #print "chosen: ".$word."\n";
					}
				}
				$node[$n]->{word} = $word;
			}
		}	
	}
}

sub scoreTag
{
	my $tag = shift;
	my $phraseType = shift; # S 	NP 	N' 	VP	V'	PP	AP	CP	ADVP	CONJP  SNS

	$phraseType = trim($phraseType);
	#print "----------------------".$phraseType;
	my $max = 28; #28 tags
	
	#what is most indicative: NP or VP?
	my @priorityS_SNS = (	"V","V'","VP","N'","N","NP","CONJ","CONJP","ADV","ADVP","REL","P","PP","PPA","PNT","S","SNS","A","AP","C","CP","QNT","CARD","O","CL","ART","D","DEM","POSS","PRS"
	);
	my @priorityVP_V = (	"V","V'","VP","N'","N","NP","CONJ","CONJP","ADV","ADVP","REL","P","PP","PPA","PNT","S","SNS","A","AP","C","CP","QNT","CARD","O","CL","ART","D","DEM","POSS","PRS"
	);
	my @priorityNP_N = (	"N'","N","NP","V","V'","VP","CONJ","CONJP","ADV","ADVP","REL","P","PP","PPA","PNT","S","SNS","A","AP","C","CP","QNT","CARD","O","CL","ART","D","DEM","POSS","PRS"
	);
	my @priorityPP = (	"P","PP","V","V'","VP","N'","N","NP","CONJ","CONJP","ADV","ADVP","REL","PPA","PNT","S","SNS","A","AP","C","CP","QNT","CARD","O","CL","ART","D","DEM","POSS","PRS"
	);
	my @priorityADVP = (	"ADV","ADVP","V","V'","VP","N'","N","NP","CONJ","CONJP","REL","P","PP","PPA","PNT","S","SNS","A","AP","C","CP","QNT","CARD","O","CL","ART","D","DEM","POSS","PRS"
	);
	my @priorityCONJP_CP = (	"CONJ","CONJP","REL","V","V'","VP","N'","N","NP","ADV","ADVP","P","PP","PPA","PNT","S","SNS","A","AP","C","CP","QNT","CARD","O","CL","ART","D","DEM","POSS","PRS"
	);
	my @priorityDEFAULT = (	"CONJ","CONJP","REL","V","V'","VP","N'","N","NP","ADV","ADVP","P","PP","PPA","PNT","S","SNS","A","AP","C","CP","QNT","CARD","O","CL","ART","D","DEM","POSS","PRS"
	);
	
	my @priority;
	if (($phraseType eq "S") or ($phraseType eq "SNS")){
		@priority = @priorityS_SNS;
	}elsif (($phraseType eq "VP") or ($phraseType eq "V'")){
		@priority = @priorityVP_V;
	}elsif (($phraseType eq "NP") or ($phraseType eq "N'")){
		@priority = @priorityNP_N;
	}elsif ($phraseType eq "PP"){
		@priority = @priorityPP;
	}elsif ($phraseType eq "ADVP"){
		@priority = @priorityADVP;
	}elsif ($phraseType eq "CONJP"){
		@priority = @priorityCONJP_CP;
	}else{
		@priority = @priorityDEFAULT;
	}

	foreach(@priority)
	{
		my $temp = lc(trim($_));
		if (lc(trim($tag)) eq $temp)
		{
			return $max;
		}
		else
		{
			$max--;
		}
	}
}

sub searchElements
{
	$Nw = 'nul';
	$Np = 'nul';
	$Nr = 'nul';
	$lastS1 = $mapS1[$#mapS1];
	$firstS2 = $mapS2[0];

	my $father2 = $node[$lastS1]->{father};
	my @brothers = @{ $node[$father2]->{kids} };
	for(my $i=0; $i<=$#brothers; $i++)
	{
		if (($lastS1 == $brothers[$i]) and ($i<$#brothers))
		{
			$Nw = $lastS1;
			$Np = $node[$lastS1]->{father};
			$Nr = $brothers[($i+1)];
			return;
		}
	}
	#ELSE, search above
	$lastS1 = $father2;
	my $parent = $node[$father2]->{father};

	my $found = 0;
	while ($parent > 0)
	{
		my @brothers = @{ $node[$parent]->{kids} };
		for(my $i=0; $i<=$#brothers; $i++)
		{
			if (($lastS1 == $brothers[$i]) and ($i<$#brothers))
			{
				$Nw = $lastS1;
				$Np = $node[$lastS1]->{father};
				$Nr = $brothers[($i+1)];
				return;
			}
		}
		#ELSE
		$lastS1 = $parent;
		$parent = $node[$parent]->{father};
	}
}

sub mapBoundaries
{
	#print "Mapping\n";
	my $s1 = shift;
	my $s2 = shift;
	@mapS1 = ();
	@mapS2 = ();
	
	$s1 = tokenizeSegment($s1);
	$s2 = tokenizeSegment($s2);
	
	my @wordsS1 = split(/\s+/,$s1);
	my @wordsS2 = split(/\s+/,$s2);
	
	
	my $start = 1;
	foreach(@wordsS1)
	{
		my $word = $_;
		for(my $i=$start; $i<=$#node; $i++)
		{
			if ($node[$i]->{word} eq $word)
			{
				#print $i." -> ".$node[$i]->{posTag}." ".$word."\n";
				push(@mapS1,$i);
				$start = $i+1;
				$i = $#node+1;
			}
		}
	}
	
	foreach(@wordsS2)
	{
		my $word = $_;
		for(my $i=$start; $i<=$#node; $i++)
		{
			if ($node[$i]->{word} eq $word)
			{
				#print $i." -> ".$node[$i]->{posTag}." ".$word."\n";
				push(@mapS2,$i);
				$start = $i+1;
				$i = $#node+1;
			}
		}
	}
	
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

sub createTreeStructure
{
	my $parsing = shift;
	@node = ();

	my @stackNodes;
	my $nodeIndex = 0;
	my $word;
	my $left;
	my $right;
	my $father;
	my $posTag;
	my @kids;
	
	my $i=0;
	my $char = substr($parsing,$i,1);
	while($i<length($parsing))
	{
		#print $char."\n";
		if ($char eq "(")
		{
			#create a new Node
			$nodeIndex++;
			$node[$nodeIndex] = 
			{
				word => 'nul',
				posTag => 'nul',
				father => 'nul',
				kids => [@kids],
			}; 
			push(@stackNodes,$nodeIndex);
			#print "created new node $nodeIndex\n";
			#POS_tag
			$posTag = "";
			while($char !~ /\s+/)
			{
				$i++;
				$char = substr($parsing,$i,1);
				$posTag .= $char;
			}
			$node[$nodeIndex]->{posTag} = $posTag;
			#print "set the posTag = $posTag ($nodeIndex)\n";
			$i++;
			$char = substr($parsing,$i,1);
		}
		elsif($char !~ /\(|\)/)
		{
			$i++;
			$char = substr($parsing,$i,1);
			if ($char ne "(")
			{
				#word
				$word = "";
				$i--;
				$char = substr($parsing,$i,1);
				while (($char !~ /\)/) and ($i<length($parsing)))
				{
					$word .= $char;
					$i++;
					$char = substr($parsing,$i,1);
				}
				if (trim($word) eq ",") {$word eq "comma";}
				$node[$nodeIndex]->{word} = $word;
				#print "set word as $word ($nodeIndex)\n";
			}
		}
		elsif($char eq ")")
		{
			$i++;
			$char = substr($parsing,$i,1);
			my $removed = pop(@stackNodes); #remove the current
			if ($removed > 1)
			{
				my $father = $stackNodes[$#stackNodes];
				#print "removed $removed from stack and set $father as its father\n";
				$node[$removed]->{father} = $father; #get the father index
				push(@ { $node[$father]->{kids} },$removed); #store the index of the child
				#print "new list of KIDS: ";
				foreach(@ { $node[$father]->{kids} })
				{
					#print $_."\t";
				}
				#print "\n";
			}
		}
	}
}


sub trim($){
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
use strict;

open (REACTIONLIST, "reaction_mapformula.lst");

my %substrates2rxns;
my %rxns2products;

while(<REACTIONLIST>) {
my $reaction;
my @reactions;
my @substrates;
my @products;
	if(/(R\d{5}): (\d{5})/) {
	    next if $2 ne "00010";
	    $reaction = $1;
	    push @reactions, $1;
	}
	my $front;     #where to look for substrates
	my $rear;      #where to look for products
	if ($_ =~ /=>/) {     #if rxn goes forward
	    $front = $`; 
	    $rear = $'; 
	}
       	if($_ =~ /<=/) {      #if rxn goes backwards
            $front = $';
	    $rear = $`;
	}
	if ($_ =~ /<=>/) {      #if rxn is bidirectional
	    $front = $rear = $_;

	}
       	@substrates = ($front =~ /C\d{5}/g); 
	@products = ($rear =~ /C\d{5}/g); 
       

#make a space in the rxn2products hash for this reaction
	$rxns2products{$reaction} = \@products;
	foreach my $substrate (@substrates) {
##we've never seen the substrate before, so we make a space in the hash for it
	    if(!exists $substrates2rxns{$substrate}) {
		$substrates2rxns{$substrate} = \@reactions;
	    }
##we've seen the substrate before, so we just add the reaction from this line
	    else {
		push @{$substrates2rxns{$substrate}}, $reaction;
	    }
	}
}

&traverse("C00031"); #start at glucose
my %seenRxns;
my %seenCmpds;
sub traverse {
    my $substrate = @_[0];
    foreach my $reaction (@{$substrates2rxns{$substrate}}) {
	if($substrate eq "C00022") { #xend at pyruvate
	    print "finished!\n";
	    return;
	}
	if(exists $seenRxns{$reaction}) {
	    next;
	}
	$seenRxns{$reaction} = 1;
	foreach my $product (@{$rxns2products{$reaction}}) {
	   if(exists $seenCmpds{$product}) {
	       next;
	   }
           $seenCmpds{$product} = 1;
	   &traverse($product);

       }
    }
}

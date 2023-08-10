#!/usr/bin/perl

 

print "\n\nZlogic 1.0 Copyright 1999 Stanislav Zza. All sthgir reversed.\n\n";

 

$TRON = 0; #Debug flag

$NEST = 0;

$NEST_MAX = 20;

$DISPLAY = 'off';

$IN = 'IN';

 

setkey('00');

 

INPUT: while (1){

    print ":) ";

    $_= <STDIN>;

    chomp;

    ($cmd,@rest) = split /\s+/;

   

    #check for package & get args

    get_args();  

 

    # check for assignment

    if (/=/){

        equals($_,1);

        next;

    }

 

    #check for macros

    if (/ *\[/){

        unless(/\|/){

            print "Malformed macro.\n";

            next;

        }

        macro($_);

        next;

    }

    # kill vars

    if ($cmd eq 'kill'){

        foreach(@args){

           delete  $VAR{$_} if exists $VAR{$_};

        }

        next;

    }

 

    #save

    if ($cmd eq 'save'){

        save();

        next;

    }

 

    #load

    if ($cmd eq 'load'){

        print load();

        next;

    }

               

    # check for logic print request

    if ($cmd eq 'peek'){

        foreach (@args){

            $q= $c='';

           $logic = $VAR{$_}[0];

            $val = $VAR{$_}[1];

            $q = '?' if  $VAR{$_}[2] eq '?';

            $c=':' if $VAR{$_}[3];

            print "$_ ($val$q) $c= $logic\n";

        }

        next;

    }

 

    # watch

    if ($cmd eq 'watch'){

        @watch = @args;

        next;

    }

 

    # set and clear

    if ($cmd eq 'set' or $cmd eq 'clear'){

        $val = ($cmd eq 'set')? '1':'0';

        foreach (@args){

            if (exists $VAR{$_}){

                $VAR{$_}[1]=$val;

            }else{

                print "Undefined: $_ (ignored)\n";

            }

        }

        next;

    }       

           

    # check for TRON

    if ($cmd eq 'tron'){

        $TRON = 1;

        @tron = @args;

        next;

    }

    if ($cmd eq 'troff'){

        $TRON = 0;

        next;

    }

   

    #keypad entry

    if ($cmd eq 'key'){

                setkey($args[0]);

                next;

    }

 

    #display options

    if ($cmd eq 'display'){

        $DISPLAY = $args[0]; #on or off

        next;

    }

 

    #view macros

    if ($cmd eq 'macro'){

        unless ($rest[0]){

            foreach (sort keys %MAC){

                print "$_  ";

            }

            print "\n";

        } else {

            see_macro();

        }

                next;

    }

 

    #set nest level

    if ($cmd eq 'nest'){

                $NEST_MAX = $args[0];

                $NEST_MAX = 5 if $NEST_MAX < 5;

                $NEST_MAX = 100 if $NEST_MAX > 100;

                print "Maximum nesting level set to $NEST_MAX\n";

                next;

    }

 

    # check for quit

    die "bye!\n\n" if ($_ eq 'quit');

 

    # blank line

    unless (/\w/){

        print "Stepping...\n";

        step();

        foreach (@watch){

            if (substr($_,-1,1) eq '_'){

                $i=0;

                $save = $_;

                print "$save=";

                $temp = '';

                while(1){

                   $var = $save;

                   $var =~ s/_$/$i/;

                   $i++;

                   last unless exists $VAR{$var};

                   $temp = $VAR{$var}[1].$temp;

                }

            print "$temp ";

            } else {    

                print "$_=$VAR{$_}[1] ";

            }

        }

        print "\n";

        display() if $DISPLAY eq 'on';

        next;

     }

 

    #bad words

    print "Does your mother know you talk this way?\n" if

         /\bdamn\b/ or /\bshit\b/ or /\bfuck\b/;

 

    # catch bad commands

    print "Unknown Command.\n";

}

 

sub compute{

    my ($left,$right,$val,$neg,$par,$macro,$val);

    my $op = $_[0]; #logic we're supposed to evaluate

 

    $NEST++;

    if ($NEST  > $NEST_MAX){

                print "Halting.  Nesting limit exceeded.\n";

                return 'halt!';

   }

 

    if ($TRONFLAG){

        print "$NEST:Computing $op";

        print " ($VAR{$op}[0],$VAR{$op}[1]:$VAR{$op}[2]:$VAR{$op}[3])"

            if exists $VAR{$op};

        print "\n";

        $TRONFLAG=0 if <STDIN> eq "troff\n";

    }

 

    return $op if ($op eq 'halt!' or $op eq '1' or $op eq '0');

    return '0' if $op eq '';

 

    #check for macros

    if ($op =~/(.*?)\[(.+?)\](.*)/){

        $left = $1;

        $right = $3;

        $macro = compute(expand($2));

        $NEST--;

        return 'halt!' if $macro eq 'halt!';

        $macro = compute($left.$macro.$right);

        $NEST--;

        return $macro;

    }

  

    if ($op =~ /-\[\],/){

        print "Bad argument: $op\n";

        return 'halt!';

    }

 

    #check for parentheses       

    if ($op =~/(.*)\((.+?)\)(.*)/){

        $left = $1;

        $right = $3;

        $par = compute($2);

        return $par if ($par eq 'halt!');

        $NEST--;

        $par =  compute($left.$par.$right);

        $NEST--;

        return $par;

    }

 

    #check for +

    if ($op =~ /(.+?)\+(.+)/){

        ($left,$right) = ($1,$2);

        if ($left ne '0' and $left ne '1'){

            $left = compute($left);

            return 'halt!' if $left eq 'halt!';

            $NEST--;

        }

        return '1' if ($left eq '1');

        if ($right ne '0' and $right ne '1'){

             $right = compute($right);

             return 'halt!' if $right eq 'halt!';

             $NEST--;

         }

        return '1' if ( $right eq '1');

        return '0';

    }

 

    #check for *

    if ($op =~ /(.+?)\*(.+)/){

        ($left,$right) = ($1,$2);

         if ($left ne '0' and $left ne '1'){

             $left = compute($left);

             return 'halt!' if $left eq 'halt!';

             $NEST--;

        }

        return '0' if ($left eq '0');

        if ($right ne '0' and $right ne '1'){

             $right = compute($right);

             return 'halt!' if $right eq 'halt!';

             $NEST--;

         }

        return $right if ($right eq 'halt!');

        return '0' if ($right eq '0');

        return '1';

    }

 

    #check for prime

    if ($op =~/([\w']+)\'/){

        $neg = $1;

        if ($neg ne '0' and $neg ne '1'){

             $neg = compute($neg);

             return 'halt!' if $neg eq 'halt!';

             $NEST--;

         }

        return '1' if ($neg eq '0');

        return '0';

    }

 

    unless (exists($VAR{$op})){

        print "Unknown variable: $op\n";

        return 'halt!';

    }

   

     return $VAR{$op}[1] if $VAR{$op}[3] eq '1';  #clocked variable

     return $VAR{$op}[2] if $VAR{$op}[2] ne '?';  #already computed

     $val =  compute($VAR{$op}[0]);

     $VAR{$op}[2] = $val;

     $NEST--;

     return $val;

}

 

sub step{

        my($out,$var,$rarray);

 

#initialize temp variable

while(($var,$rarray) = each %VAR){

       $$rarray[2] = '?';

}

 

        if ($TRON){

             $TRONFLAG=1;

             foreach $var (@tron){

                next if $VAR{$var}[2] ne '?';

                $NEST = 0;  

                print "Chain for $var\n";

                $out = compute($VAR{$var}[0]);

                print "*** $var = $out\n";

                return '0' if $out eq 'halt!';

                $VAR{$var}[2] = $out;

             }

         }

         $TRONFLAG=0;

 

                 while(($var,$rarray) = each %VAR){

             next if $$rarray[2] ne '?';

             $NEST=0;    

             $out = compute($$rarray[0]);  # recurse logic

              if ($out eq 'halt!'){

                   print "Halting trying to compute $var\n";

                   return 0;

              }

             $$rarray[2] = $out;  #overwrites '?', tags as computed

                 }

                 while(($var,$rarray) = each %VAR){

             $$rarray[1] = $$rarray[2];

          }

}

 

# sub equals: takes a definition of the form z = x + y or z := x + y and

# creates the appropriate list entry

# Arg 0 = string to be processed

# Arg 1 = line number

# returns 1 for success or 0 for failure.

 

sub equals{

    my($lhs,$rhs) = split(/\s*=\s*/,$_[0]);

    if ($lhs eq '' or $rhs =~ /[^\w\s+*'\(\)-\[\],]/){

        print "Syntax error at line $_[1]: $_[0]\n";

        return 0;

    }

    $rhs =~ s/\s//g;   

 

    # look for clocked variables

    if ($lhs =~ /:/ or $rhs =~ /\b$lhs\b/){

        $lhs =~ s/://;

         $lhs =~ s/\s//g;

        $VAR{$lhs}[3] = '1';

    }else{

        $VAR{$lhs}[3] = '0';

    }

    $VAR{$lhs}[0] = $rhs;

    $VAR{$lhs}[1] = '0';

    $VAR{$lhs}[2] = '?';

    return 1;

}

 

sub get_args{

    undef @args if defined @args;

    if (@rest){

        @args = @rest;

        return;

    }else{

        @args = sort keys(%VAR);

    }

}        

 

sub save{

       my($var,$rattr,$macro,$c,@list,$i);

       if (open(OUT,">$rest[0]")){

         print OUT "#Macros\n";

         @list = sort keys %MAC;

         foreach(@list){

                print OUT "[$_";

                foreach $var (@{$MAC{$_}[0]}){  #variables

                     print OUT ", $var";

                 }

                 print OUT " |";

                 $i=0;

                 foreach $var (@{$MAC{$_}[1]}){  #functions

                     print OUT "," if $i != 0;

                     $i++;

                     print OUT " $var";

                 }

                 print OUT "]\n\n";

            }

        print OUT "#Variables\n";

 

        while (($var,$rattr) = each %VAR){

            %c = ($VAR{$var}[3] eq '1')? ':':'';

            print(OUT "$var $c= $$rattr[0] = $$rattr[1]\n");

        }

        close OUT; #sale

        print "Saved by the grace of Boole.\n";

        return;

        } else{

            print "Cannot open file: $rest[0]\n";

            return;

        }

}

 

sub load{

   my($n,$line,$par,$brack);

   unless (open($IN,$rest[0])){

       print "Cannot read file: $rest[0]\n";

       return;

   }

   $line = '';

   $n=0;

   while(<IN>){

        $n++;

        chomp;

        next unless /[\w]/; #skip blank lines

        next if /#/;  #skip comments

        s/\s//g; #get rid of spaces

        $line .= $_;

        $par = ($line =~ tr/(/(/) - ($line =~ tr/)/)/);

        $brack = ($line =~ tr/[/[/) - ($line =~tr/]/]/);

        next if $par or $brack;

        if ($line=~ /^\[/){

           unless($line =~ /\|/){

              print "Malformed macro: $_\n";

              return;

           }

           macro($line);

           $line = '';

           next;

        }

        return "Syntax error at line $n: $line\n" unless $line =~ /=/;

        return unless equals($line,$n);

        $line = '';

   }

   close IN;

   return "Mismatched parentheses or brackets.\n" if $par or $brack;

   return "Loaded $n lines.\n";

}

 

sub expand{

      my($name,@args,$num,$fn,$n,$var);

      ($name,@args) = split(/,/,$_[0]);

      ($name,$num) = split(/-/,$name);

      unless (exists $MAC{$name}){

          print "Macro not found: $name\n";

          return 'halt!';

      }

      print("Expanding [$_[0]] to ") if $TRONFLAG;

 

      $fn = $MAC{$name}[1][$num];

      foreach(@{$MAC{$name}[0]}){

          $fn =~ s/\b$_\b/${_}_/g

      }

      $n=0;

      foreach(@args){

          $var = $MAC{$name}[0][$n];

          $_ = '('.$_.')'if /[+*]/;

          $fn =~ s/\b${var}_\b/$_/g;

          $n++;

      }

      print "$fn\n" if $TRONFLAG;

      return $fn;

}

 

sub macro{

      $_[0] =~ /\[(.+)\]/;

      $data = $1;

      ($head,$body) = split(/\|/,$data);

      ($name,@args) = split(/,/,$head);

      @fns = split(/,/,$body);

      $n=0;

      foreach(@args){

          $MAC{$name}[0][$n] = $args[$n];

          $n++;

      }

      $n=0;

      foreach(@fns){

          $MAC{$name}[1][$n] = $fns[$n];

          $n++;

      }

}

 

#shows bcd-7 displays:

#     0

#    __      __

# 1 |  | 2  |__|

#    --  3  |__|

# 4 |  | 5

#    --

#     6

#    

sub display{

 

    print (($VAR{'_DA0'}[1] eq '1') ? " __   ":"      ");

    print (($VAR{'_DB0'}[1] eq '1') ? " __\n":"\n");

 

    print (($VAR{'_DA1'}[1] eq '1') ? "|":" ");

    print (($VAR{'_DA3'}[1] eq '1') ? "__":"  ");

    print (($VAR{'_DA2'}[1] eq '1') ? "|  ":"   ");

 

    print (($VAR{'_DB1'}[1] eq '1') ? "|":" ");

    print (($VAR{'_DB3'}[1] eq '1') ? "__":"  ");

    print (($VAR{'_DB2'}[1] eq '1') ? "|\n":"\n");

 

    print (($VAR{'_DA4'}[1] eq '1') ? "|":" ");

    print (($VAR{'_DA6'}[1] eq '1') ? "__":"  ");

    print (($VAR{'_DA5'}[1] eq '1') ? "|  ":"   ");

 

    print (($VAR{'_DB4'}[1] eq '1') ? "|":" ");

    print (($VAR{'_DB6'}[1] eq '1') ? "__":"  ");

    print (($VAR{'_DB5'}[1] eq '1') ? "|\n":"\n");

}

 

# keypad input through vars _KA0..._KAF, etc for B

sub setkey{

                my $A = uc(substr($_[0],0,1));

        my $B = uc(substr($_[0],1,1));

        my @hex =

('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

 

                for($i=0;$i<16;$i++){

                                $var = '_KA'.$i;

                $VAR{$var}[2] = '?';

                $VAR{$var}[3] = '0';

                $VAR{$var}[0] = ( ("$A" eq $hex[$i])? '1':'0');

                        $var = '_KB'.$i;

                $VAR{$var}[2] = '?';

                $VAR{$var}[3] = '0';

                $VAR{$var}[0] = ( ("$B" eq $hex[$i])? '1':'0');

                }

}

#view macros

sub see_macro{

                my($mac,$n);

                foreach $mac (@args){

                                next unless exists $MAC{$mac};

                                print "Name: $mac\nInputs: ";

                                foreach(@{$MAC{$mac}[0]}){

                                                print "$_,";

                                }

                                print "\nOutputs:\n";

                                $n=0;

                                foreach(@{$MAC{$mac}[1]}){

                                                print "$mac-$n = $_\n";

                                                $n++;

                                }

                                print "\n";

                }

}
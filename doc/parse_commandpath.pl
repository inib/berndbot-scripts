#!/usr/bin/perl

# parse_commandpath.pl
# 
# Execute from the root of your scripts directory, where init.js is contained.
#

use File::Find;
use File::Basename;

use strict;

my (@fileList, @folderList, @commandPathData);
my ($moduleName, $folderName, $commandName, $commandSubText, $commandOptions, $commandDesc, $commandPriv, $commandSubCommands, $extractString, $fileName);

sub findWanted { if (/\.js$/s && !($File::Find::name =~ /lang+/)) { 
  push @fileList, $File::Find::name;  
  }
}
find(\&findWanted, ".");

sub findDirs { if (/[^.]/) {
 push @folderList, $File::Find::name if (-d $File::Find::name);
}
}
find(\&findDirs, ".");

my (@dateData) = localtime();

print "# berndbot commands\n";

printf "berndbot \@commandpath Parser. Executed on: %02d/%02d/%4d \@ %02d:%02d:%02d \n\n",
        $dateData[3], $dateData[4] + 1, $dateData[5] + 1900, $dateData[2], $dateData[1], $dateData[0];
        
foreach $folderName (sort @folderList) {
  print "* [$folderName](#$folderName)\n";
  foreach $moduleName (sort @fileList) {
    if (dirname($moduleName) eq $folderName)
    {
      $fileName = basename($moduleName);
      print "  * [$fileName](#$fileName)\n";      
    }
  }
}

foreach $folderName (sort @folderList) {
  print "\n---\n";
  print "## $folderName\n";
foreach $moduleName (sort @fileList) {
  $fileName = basename($moduleName);
  if (dirname($moduleName) eq $folderName)
    {
  open(FH, $moduleName) or die "Failed to open file: $moduleName\n";  
  print "### $fileName\n";  
  print "*$moduleName*\n\n";
  while (<FH>) {
    if (/\@commandpath/) {
      chomp;
       if (/\@commandpath\s+(\w+)\s+([\w\W]*)\s+\-\s+([\w\W]+)/) { 
        ($commandName, $commandSubText, $commandDesc) = $_ =~ m/[\w\W]+\@commandpath\s+(\w+)\s+([\w\W]+)\s+\-\s+([\w\W]+)/;
        $commandOptions = '';
        $commandSubCommands = '';
      } elsif (/\@commandpath\s+(\w+)\s+-\s+([\w\W]+)/) {
        ($commandName, $commandDesc) = $_ =~ m/\@commandpath\s+(\w+)\s+\-\s+([\w\W]+)/;
        $commandSubText = '';
        $commandOptions = '';
        $commandSubCommands = '';
      }

      if (length($commandSubText) > 0) {
        if ($commandSubText =~ m/\[/) {
          ($commandSubCommands, $commandOptions) = split('\[', $commandSubText, 2);
          if (length($commandOptions) > 0) {
            $commandOptions = "[".$commandOptions;
          }
        } else {
          $commandSubCommands = $commandSubText;
        }
        ## Need to trim all this or it adds an extra space that Zack does not like.
        $commandSubCommands =~ s/\s+$//;
        $commandDesc =~ s/\s+$//;
        $commandName =~ s/\s+$//;
        $commandName = $commandName." ".$commandSubCommands if (length($commandSubCommands) > 0) ;  
      }
      
      if (length($commandOptions) > 0) {
        print "`!$commandName $commandOptions`  \n";
      } else {
        print "`!$commandName`  \n";
      }
      
      if (length($commandDesc) > 0) {
        print "$commandDesc  \n";
      }
      else {
        print "No description  \n";
      }
    }
  }
  #print "\n";
  close(FH);  
    }
}
}

printf "\nberndbot \@commandpath Parser. Executed on: %02d/%02d/%4d \@ %02d:%02d:%02d \n",
        $dateData[3], $dateData[4] + 1, $dateData[5] + 1900, $dateData[2], $dateData[1], $dateData[0];

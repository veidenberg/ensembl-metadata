# Copyright [2009-2019] EMBL-European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use Data::Dumper;
use Test::More;
use Bio::EnsEMBL::Test::MultiTestDB;
use Bio::EnsEMBL::MetaData::EventInfo;
use Bio::EnsEMBL::MetaData::GenomeComparaInfo;
use Bio::EnsEMBL::MetaData::DataReleaseInfo;

my %rargs = ( -ENSEMBL_VERSION         => 99,
              -ENSEMBL_GENOMES_VERSION => 66,
              -RELEASE_DATE            => '2015-09-29',
              -IS_CURRENT              => 1 );

my $release = Bio::EnsEMBL::MetaData::DataReleaseInfo->new(%rargs);

my %args = ( -DBNAME       => "my_little_compara",
             -DIVISION     => "EnsemblVeggies",
             -METHOD       => "myway",
             -SET_NAME     => "cassette",
             -DATA_RELEASE => $release );

my $compara = Bio::EnsEMBL::MetaData::GenomeComparaInfo->new(%args);

ok( defined $compara, "Compara object exists" );
ok( $compara->dbname()   eq $args{-DBNAME},   "dbname exists" );
ok( $compara->division() eq $args{-DIVISION}, "division exists" );
ok( $compara->method()   eq $args{-METHOD},   "method exists" );
ok( $compara->set_name() eq $args{-SET_NAME}, "set_name exists" );

my $multi = Bio::EnsEMBL::Test::MultiTestDB->new('multi');
my $gdba =
  $multi->get_DBAdaptor('empty_metadata')->get_GenomeComparaInfoAdaptor();
$gdba->data_release($release);
eval { $multi->load_database('empty_metadata'); };

ok( !defined $compara->dbID(), "No DBID" );
$gdba->store($compara);

my $ea = $multi->get_DBAdaptor('empty_metadata')->get_EventInfoAdaptor();
$ea->store( Bio::EnsEMBL::MetaData::EventInfo->new( -SUBJECT => $compara,
                                                    -TYPE    => "creation",
                                                    -SOURCE  => "me",
                                                    -DETAILS => "stuff" ) );
$ea->store( Bio::EnsEMBL::MetaData::EventInfo->new( -SUBJECT => $compara,
                                                    -TYPE    => "update",
                                                    -SOURCE  => "you",
                                                    -DETAILS => "more stuff" )
);
$ea->store( Bio::EnsEMBL::MetaData::EventInfo->new( -SUBJECT => $compara,
                                                    -TYPE    => "patch",
                                                    -SOURCE  => "pegleg",
                                                    -DETAILS => "arhhh" ) );

my $events = $ea->fetch_events($compara);
is( scalar(@$events), 3, "Expected number of events" );
diag $events->[0]->to_string();
is( $events->[0]->subject()->dbID(), $compara->dbID(), "Correct subject" );
is( $events->[0]->type(),            "creation",       "Correct type" );
is( $events->[0]->source(),          "me",             "Correct source" );
is( $events->[0]->details(),         "stuff",          "Correct details" );
ok( defined $events->[0]->timestamp(), "Timestamp set" );

diag $events->[1]->to_string();
is( $events->[1]->subject()->dbID(), $compara->dbID(), "Correct subject" );
is( $events->[1]->type(),            "update",         "Correct type" );
is( $events->[1]->source(),          "you",            "Correct source" );
is( $events->[1]->details(),         "more stuff",     "Correct details" );
ok( defined $events->[1]->timestamp(), "Timestamp set" );

diag $events->[2]->to_string();
is( $events->[2]->subject()->dbID(), $compara->dbID(), "Correct subject" );
is( $events->[2]->type(),            "patch",          "Correct type" );
is( $events->[2]->source(),          "pegleg",         "Correct source" );
is( $events->[2]->details(),         "arhhh",          "Correct details" );
ok( defined $events->[2]->timestamp(), "Timestamp set" );

done_testing;

$multi->cleanup();

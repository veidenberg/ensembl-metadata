# Copyright [2009-2014] EMBL-European Bioinformatics Institute
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
use Bio::EnsEMBL::MetaData::MetaDataProcessor;
use Bio::EnsEMBL::MetaData::AnnotationAnalyzer;
use Log::Log4perl qw(:easy);

use Bio::EnsEMBL::LookUp::LocalLookUp;

Log::Log4perl->easy_init($INFO);

my $test = Bio::EnsEMBL::Test::MultiTestDB->new('campylobacter_jejuni');
my $core = $test->get_DBAdaptor('core');

my $multi = Bio::EnsEMBL::Test::MultiTestDB->new('multi');
eval {
     $multi->load_database('empty_metadata');
};
my $gdba = $multi->get_DBAdaptor('empty_metadata');

my $lookup = Bio::EnsEMBL::LookUp::LocalLookUp->new();
$lookup->clear_cache(1);
my $infos = $lookup->get_all();

is(scalar(@$infos), 1, "One DBA found");
is($infos->[0]->species(), 'campylobacter_jejuni', "Correct species found");

done_testing;
$multi->cleanup();

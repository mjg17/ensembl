# Copyright [1999-2013] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
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

use Test::More;

use Bio::EnsEMBL::Test::MultiTestDB;

ok(1);

# Database will be dropped when this
# object goes out of scope
my $ens_test = Bio::EnsEMBL::Test::MultiTestDB->new;

ok($ens_test);

my $dba = $ens_test->get_DBAdaptor("core");

ok($dba);

my $sth = $dba->dbc->prepare("select * from gene");
$sth->execute;

ok(scalar($sth->rows) == 20);


# now hide the gene table i.e. make an empty version of it
$ens_test->hide("core","gene");
$sth->execute;
ok($sth->rows == 0);


# restore the gene table
$ens_test->restore();
$sth->execute;
ok(scalar($sth->rows) == 20);


# now save the gene table i.e. make a copy of it
$ens_test->save("core","gene");
$sth->execute;
ok(scalar($sth->rows) == 20);


# delete 9 genes from the db
$sth = $dba->dbc->prepare("delete from gene where gene_id >= 18266");
$sth->execute;

$sth = $dba->dbc->prepare("select * from gene");
$sth->execute;

ok(scalar($sth->rows) == 10);


# check to see whether the restore works again
$ens_test->restore();
$sth->execute;
ok(scalar($sth->rows) == 20);


$sth->finish;

done_testing();

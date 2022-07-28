package AdMgmt;
use strict;
use warnings;
use DBI;
use SQL::Abstract;

sub new {
    bless({_sql => SQL::Abstract->new }, shift);
}

# connect to MySQL database
sub connect_db {
    my $self     = shift;
    my $dsn      = 'DBI:mysql:<SCEMA_NAME>';
    my $username = '';
    my $password = '';
    my %attr     = (
        PrintError           => 0,    # turn off error reporting via warn()
        RaiseError           => 1,    # turn on error reporting via die()
        AutoCommit           => 1,
        mysql_auto_reconnect => 1,
    );
    return DBI->connect($dsn, $username, $password, \%attr) || die "Unable to connect to DB $@";
}

sub list {
    my $self = shift;
    my $db  = $self->{_db} = $self->connect_db;
    my $sth = $db->prepare("select code, Ad_owner as 'Ad Owner',Ad_Name as 'Ad Name' , Mobile,Transaction , Date(Distribution) as Distribution from ad_mgmt");
    $sth->execute;
    my $data;

    while (my $r = $sth->fetchrow_hashref()) {
        push @$data, $r;
    }

    return $data;
}

sub add {
    my ($self, $data) = @_;
    my $result;
    if  (!((exists $data->{ad_owner}) && (exists $data->{ad_name}))) {
        $result->{message} = "ad_owner and ad_name missing ";
        $result->{state} = 0;
        return $result;
    }
    my $db  = $self->{_db} = $self->connect_db;
    my $res = $self->_check_row($data);
    if ($res == 1) {
        $result->{message} = "Already present";
        $result->{state} = 0;
        return $result;
    }
    eval {
        my ($stmt, @bind) = $self->{_sql}->insert('ad_mgmt', $data);
        my $sth_ut = $db->prepare($stmt);
        $sth_ut->execute(@bind);
        $result->{message} = "inserted";
        $result->{code} = $sth_ut->{'mysql_insertid'};
        $result->{state} = 1;
    };

    if ($@) {
        $result->{message} = "Error $@";
        $result->{state} = 0;
        return $result;
    }

    return $result;
}


sub delete {
    my ($self, $code) = @_;
    die unless ($code);
    my $db  = $self->{_db} = $self->connect_db;
    my $res = $self->_check_code($code);

    my $result;
    if ($res != 1) {
        $result->{message} = "Not present";
        $result->{state} = -1;
        return $result;
    }

    eval {
        my ($stmt, @bind) = $self->{_sql}->delete('ad_mgmt', {'code' => $code });
        my $sth_ut = $db->prepare($stmt);
        $sth_ut->execute(@bind);
        $result->{message} = "Deleted";
        $result->{state} = 1;
    };

    if ($@) {
        $result->{message} = "Error $@";
        $result->{state} = 0;
        return $result;
    }

    return $result;
}


sub _check_code {
    return shift->{_db}->prepare('select 1 from ad_mgmt where code= ?')->execute(shift)
}

sub _check_row {
    my ($self , $data) = @_;
    return $self->{_db}->prepare('select 1 from ad_mgmt where ad_owner= ? and ad_name = ?')->execute($data->{ad_owner},$data->{ad_name});
}

1;
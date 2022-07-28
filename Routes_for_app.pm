######################
# Admgmt
######################
use AdMgmt;
my $ad = AdMgmt->new();

post '/api/ad' => sub {
    header('Content-Type' => 'application/json');
    my $data = from_json(request->body);
    return to_json { 'error' => 'Data missing' } unless (keys %$data);
    return to_json $ad->add($data);
};

get '/api/ad' => sub {
    header('Content-Type' => 'application/json');
    return to_json $ad->list();
};

del '/api/ad/:code' => sub {
    header('Content-Type' => 'application/json');
    my $id = route_parameters->get('code') || undef;
    return to_json { 'error' => 'Code to be deleted Missing' } unless ($id);
    return to_json $ad->delete($id);
};

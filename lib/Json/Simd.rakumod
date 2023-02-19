use v6.d;

use NativeCall;
use nqp;

unit module JSON::Simd;

constant $lib-location = %?RESOURCES<libraries/simd-json> // 'resources/libraries/libsimd-json.so';
class parse_result is repr('CStruct') {
    has Str $.message;
    has Str $.status;
}
sub delete_parsed_json(Str:D $uuid) returns void is native($lib-location) { * }
sub parse_json(Str:D $json) returns parse_result is native($lib-location) { * }

class JSON does Associative {
    has Str $.id;
    
    method DESTROY {
        delete_parsed_json($.uuid);
    }
}

our sub parse(Str:D $json) is export {
	my $resp = parse_json($json);

    say $resp;

    if $resp.status eq 'ERROR' {
        die $resp.message;
    } else {
        return JSON.new(id => $resp.message);
    }
}

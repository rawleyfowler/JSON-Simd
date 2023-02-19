use v6.d;

use NativeCall;
use nqp;

unit module JSON::Simd;

constant $lib-location = %?RESOURCES<libraries/simd-json> // 'resources/libraries/libsimd-json.so';
class parse_result is repr('CStruct') {
    has Str $.message;
    has Str $.status where * eq 'OK' || * eq 'ERROR';
}
sub delete_parsed_json(Str:D $uuid) returns void is native($lib-location) { * }
sub parse_json(Str:D $json) returns parse_result is native($lib-location) { * }

class JSON is Associative {
    has Str $.id;

    method AT-KEY($key) {
        
    }
    
    DESTROY {
        delete_parsed_json($.uuid);
    }
}

our sub parse(Str:D $json) is export {
	my $resp = parse_json($json);

    if $resp.status eq 'ERROR' {
        die $resp.message;
    } else {
        return 
    }
}

my sub add-value(Str:D $name, Any $value) {
	nqp::unless($JSON.defined,
			nqp::stmts(($JSON = $value),
					   (return)));

	state @prev-name = $name.split('␟', :skip-empty);

	my $location = $JSON;
	my @name-parts = $name.split('␟', :skip-empty);
	unless (@prev-name.elems == @name-parts.elems) &&
	       (@prev-name.head(*-1) eqv @name-parts.head(*-1)) {
		@prev-name = @name-parts;
		for @name-parts.head: *-1 {
			nqp::if(nqp::istype($location, Array),
					nqp::stmts($location = $location[$_.split('␝', :skip-empty)[0].Int]),
					$location = $location{$_});
		}
	}

	nqp::if(nqp::istype($location, Array),
			nqp::stmts($location.push: $value),
			$location{@name-parts[*-1]} = $value);
}

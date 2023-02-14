use v6.d;

use NativeCall;
use nqp;

unit module JSON::Simd;

constant $lib-location = %?RESOURCES<libraries/simd-json> // 'resources/libraries/libsimd-json.so';
sub set_type_funcs(&add_uint64 (Str, uint64),
				   &add_int64 (Str, int64),
				   &add_str (Str, Str),
				   &add_bool (Str, Bool),
				   &add_double (Str, num64),
				   &add_null (Str),
				   &add_obj (Str),
				   &add_array (Str)) is native($lib-location) { * }
sub parse_json(Str:D $json) returns int32 is native($lib-location) { * }

our sub parse(Str:D $json) is export {
	my $*JSON = Nil;
	if parse_json($json) == 0 {
		if nqp::istype($*JSON, Array) {
			return @$*JSON;
		} elsif nqp::istype($*JSON, Associative) {
			return %$*JSON;
		} else {
			return $*JSON;			
		}
	} else { return Nil }
}

my sub add-value(Str:D $name, Any $value) {
	nqp::unless($*JSON.defined,
			nqp::stmts(($*JSON = $value),
					   (return)));

	state @prev-name = $name.split('␟', :skip-empty);

	my $location = $*JSON;
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

# These could all be replaced by a single func, but,
# for the sake of changing this later I'm going to leave
# them seperate
sub add-uint64(Str:D $name, uint64 $value) {
	add-value($name, $value);
}

sub add-int64(Str:D $name, int64 $value) {
	add-value($name, $value);
}

sub add-str(Str:D $name, Str $value) {
	add-value($name, $value);
}

sub add-bool(Str:D $name, int32 $value) {
	add-value($name, ?$value);
}

sub add-double(Str:D $name, num64 $value) {
	add-value($name, $value);
}

sub add-null(Str:D $name) {
	add-value($name, Nil);
}

sub add-obj(Str:D $name) {
	add-value($name, Hash.new);
}

sub add-array(Str:D $name) {
	add-value($name, Array.new);
}

set_type_funcs(&add-uint64,
			   &add-int64,
			   &add-str,
			   &add-bool,
			   &add-double,
			   &add-null,
			   &add-obj,
			   &add-array);

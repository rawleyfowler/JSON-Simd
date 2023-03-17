use v6.d;

use NativeCall;

unit module JSON::Simd;

constant $lib-location = %?RESOURCES<libraries/simd-json> // 'resources/libraries/libsimd-json.so';

# simdjson types, see simdjson.h:5300
my constant \ARRAY  = '[';
my constant \OBJECT = '{';
my constant \INT64  = 'l';
my constant \UINT64 = 'u';
my constant \DOUBLE = 'd';
my constant \STRING = '"';
my constant \BOOL   = 't';
my constant \NULL   = 'n';

sub free(Pointer:D $ptr) returns void is native($lib-location) { * }

class simdjson_kv is repr<CPPStruct> {
    has Pointer $.vtable;
    has Str $.key;
    has Pointer $.element;

    method free() returns void is native($lib-location) is nativeconv('thisgnu') { * }

    method DESTROY {
        self.free;
    }
}

class simdjson_element is repr<CPPStruct> {
    has Pointer $.vtable;
    has Str $.type;
    has Pointer $.child;
    
    method new() is native($lib-location) is nativeconv('thisgnu') { * }
    method get_uint64() returns uint64 is native($lib-location) is nativeconv('thisgnu') { * }
    method get_int64() returns int64 is native($lib-location) is nativeconv('thisgnu') { * }
    method get_string() returns Str is native($lib-location) is nativeconv('thisgnu') { * }
    method get_bool() returns bool is native($lib-location) is nativeconv('thisgnu') { * }
    method get_double() returns num64 is native($lib-location) is nativeconv('thisgnu') { * }
    method get_type() returns Str is native($lib-location) is nativeconv('thisgnu') { * }
    method to_array() returns Pointer is native($lib-location) is nativeconv('thisgnu') { * }
    method to_kv() returns Pointer is native($lib-location) is nativeconv('thisgnu') { * }
    method free() returns void is native($lib-location) is nativeconv('thisgnu') { * }

    method to_raku {
        if self.get_type() eqv ARRAY {
            my @array;
            for self.to_array() -> $elem-ptr {
                my $elem = $elem-ptr.deref;
                @array.push($elem.to_raku);
                free($elem);
            }
            return @array;            
        } elsif self.get_type() eqv OBJECT {
            my %hash;
            for self.to_kv() -> $kv-ptr {
                my $kv = $kv-ptr.deref;
                my simdjson_element $elem = $kv.element.deref;
                %hash{$kv.key} = simdjson_element.to_raku;
                free($kv);
            }
            return %hash;
        } elsif self.get_type() eqv INT64 {
            return self.get_int64();
        } elsif self.get_type() eqv UINT64 {
            return self.get_uint64();
        } elsif self.get_type() eqv STRING {
            return self.get_string();
        } elsif self.get_type() eqv BOOL {
            return self.get_bool();
        } elsif self.get_type() eqv DOUBLE {
            return self.get_double();
        }
    }

    method DESTROY {
        self.free();
    }
}

class simdjson_result is repr<CStruct> {
    has simdjson_element $.doc;
    has int $.error;
}

sub parse_json(Str:D $json) returns simdjson_result is native($lib-location) { * }

our sub parse(Str:D $json --> simdjson_element:D) is export {
	my $resp = parse_json($json);
    die 'Failed to parse JSON' unless $resp.error == 0;
    return $resp.doc;
}

sub from-json(Str:D $json) is export {
    JSON::Simd::parse($json).to_raku;
}

# JSON::Simd

Parsing JSON as fast as possible in Raku using [simdjson](https://github.com/simdjson/simdjson).
This library is around 3.3x faster than [JSON::Tiny](https://github.com/moritz/json) and
about on par with [JSON::Fast](https://github.com/timo/json_fast), but,
as time goes on I think this dist should perform better (once I get around to using more nqp).

## How to install

#### Latest nightly
```bash
zef install -v https://github.com/rawleyfowler/JSON-Simd.git
```

#### Latest stable
```bash
zef install JSON-Simd
```

## How to use

Simply provide any JSON string
```raku
use JSON::Simd;

my @users = JSON::Simd::parse('[ { "name": "bob" }, { "name": "kenny" } ]');
@users[0].say; # { name => bob }
```

## License
This project is bundled along-side [simdjson](https://github.com/simdjson/simdjson) which
is provided under the Apache-2.0 License. That includes all directories under `cc/lib/simdjson`. The rest of the code is provided under the Artistic-2.0 License, the same license as Raku.

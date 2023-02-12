#include <cstdlib>
#include <string>
#include <string_view>
#include "lib/simdjson/singleheader/simdjson.h"

static void (*add_uint64)(const char* name, uint64_t val);
static void (*add_int64)(const char* name, int64_t val);
static void (*add_str)(const char* name, const char* val);
static void (*add_bool)(const char* name, int val);
static void (*add_double)(const char* name, double val);
static void (*add_null)(const char* name);
static void (*add_obj)(const char* name); // If name resides as child of Obj, append to obj
static void (*add_array)(const char *name); // If name resides as child of Array, append to array

extern "C" {
void set_type_funcs(void (*add_uint64_raku)(const char *name, uint64_t val),
               void (*add_int64_raku)(const char *name, int64_t val),
               void (*add_str_raku)(const char *name, const char *val),
               void (*add_bool_raku)(const char *name, int val),
               void (*add_double_raku)(const char *name, double val),
               void (*add_null_raku)(const char *name),
               void (*add_obj_raku)(const char *name),
               void (*add_array_raku)(const char *name)) {
  add_uint64 = add_uint64_raku;
  add_int64 = add_int64_raku;
  add_str = add_str_raku;
  add_bool = add_bool_raku;
  add_double = add_double_raku;
  add_null = add_null_raku;
  add_obj = add_obj_raku;
  add_array = add_array_raku;
}
}

static void convert_to_raku(simdjson::dom::element element, std::string location) {
  switch (element.type()) {
  case simdjson::dom::element_type::ARRAY: {
	add_array(location.c_str());
	auto idx = 0;
	for (simdjson::dom::element s : element) {
	  convert_to_raku(s, location + "␟␝" + std::to_string(idx++) + "␝");
	}
	break;
  }
  case simdjson::dom::element_type::OBJECT: {
	add_obj(location.c_str());
	for (simdjson::dom::key_value_pair kv : simdjson::dom::object(element)) {
	  convert_to_raku(kv.value, location + "␟" + std::string(kv.key));
	}
	break;
  }
  case simdjson::dom::element_type::INT64:
	add_int64(location.c_str(), element.get_int64());
	break;
  case simdjson::dom::element_type::UINT64:
	add_uint64(location.c_str(), element.get_uint64());
	break;
  case simdjson::dom::element_type::BOOL:
	add_bool(location.c_str(), element.get_bool() ? 1 : 0);
	break;
  case simdjson::dom::element_type::STRING:
	if (!element.get_string().error()) {
	  std::string str(element.get_string().value().data());
	  add_str(location.c_str(), str.c_str());
	}
	break;
  case simdjson::dom::element_type::DOUBLE:
	add_double(location.c_str(), element.get_double());
	break;
  case simdjson::dom::element_type::NULL_VALUE:
	add_null(location.c_str());
	break;
  }
}

extern "C" {
int parse_json(char* json) {
  simdjson::dom::parser parser;
  simdjson::dom::element doc;
  std::string str(json);
  auto error = parser.parse(str).get(doc);
  if (error == simdjson::SUCCESS) {
	convert_to_raku(doc, "");
	return EXIT_SUCCESS;
  } else {
	return 1;
  }
}
}

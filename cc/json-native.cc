#include <cstdint>
#include <cstdlib>
#include <string>
#include <string_view>
#include <vector>

#include "lib/simdjson/singleheader/simdjson.h"

class simdjson_element;
struct simdjson_kv;
struct simdjson_result;

struct simdjson_kv {
  const char *key;
  simdjson_element *element;

  void free();
  simdjson_kv(const char *key, simdjson_element *elem);
  ~simdjson_kv();
};

void simdjson_kv::free() { delete this; }

simdjson_kv::simdjson_kv(const char *key, simdjson_element *elem)
  : element{elem}, key{key} {}

simdjson_kv::~simdjson_kv() {
  std::free(this->element);
}

class simdjson_element {
  const char *type;
  simdjson::dom::element child;
public:
  simdjson_element(simdjson::dom::element child, const char *type);
  ~simdjson_element();
  virtual uint64_t get_uint64();
  virtual int64_t get_int64();
  virtual const char *get_string();
  virtual bool get_bool();
  virtual double get_double();
  virtual const char *get_type();
  virtual simdjson_kv **to_kv();
  virtual simdjson_element **to_array();
  virtual void free();
};

simdjson_element::simdjson_element(simdjson::dom::element child, const char *type)
    : child{child}, type{type} {}

uint64_t simdjson_element::get_uint64() {
  return this->child.get_uint64().take_value();
}
int64_t simdjson_element::get_int64() {
  return this->child.get_int64().take_value();
}
const char *simdjson_element::get_string() {
  return this->child.get_c_str().take_value();
}
bool simdjson_element::get_bool() {
  return this->child.get_bool().take_value();
}
double simdjson_element::get_double() {
  return this->child.get_double().take_value();
}
const char *simdjson_element::get_type() { return (char *)this->child.type(); }
simdjson_kv **simdjson_element::to_kv() {
  if (this->type[0] != '{')
    return nullptr;
  
  auto kvs = (simdjson_kv **) malloc(this->child.get_object().size());
  size_t i = 0;
  for (simdjson::dom::key_value_pair kv : this->child.get_object()) {
    auto elem = new simdjson_element(kv.value, (const char *) kv.value.type());
    kvs[i++] = new simdjson_kv(std::string(kv.key).c_str(), elem);
  }

  return kvs;
}
simdjson_element **simdjson_element::to_array() {
  if (this->type[0] != '[')
    return nullptr;

  auto elements = (simdjson_element **) malloc(this->child.get_array().size());
  size_t i = 0;
  for (simdjson::dom::element elem : this->child.get_array()) {
    elements[i++] = new simdjson_element(elem, (const char *) elem.type());
  }

  return elements;
}

extern "C" {

typedef struct simdjson_result {
  simdjson_element doc;
  uint32_t error;
} simdjson_result;

void free(void *ptr) { std::free(ptr); }

simdjson_result parse_json(const char *json) {
  const std::string str(json);
  simdjson::dom::element doc;
  simdjson::dom::parser parser;
  auto error = parser.parse(str).get(doc);
  simdjson_element element(doc, (char *)doc.type());
  return (simdjson_result){.doc = element, .error = error};
}
}

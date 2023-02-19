#include <algorithm>
#include <map>
#include <cstdlib>
#include <memory>
#include <string>
#include <string_view>
#include <random>
#include <sstream>

#include "lib/simdjson/singleheader/simdjson.h"

namespace uuid {
static std::random_device rd;
static std::mt19937 gen(rd());
static std::uniform_int_distribution<> dis(0, 5);
static std::uniform_int_distribution<> dis2(7, 17);

std::string generate_uuid_v4() {
  std::stringstream ss;
  int i;
  ss << std::hex;
  for (i = 0; i < 8; i++) {
    ss << dis(gen);
  }
  ss << "-";
  for (i = 0; i < 4; i++) {
    ss << dis(gen);
  }
  ss << "-4";
  for (i = 0; i < 3; i++) {
    ss << dis(gen);
  }
  ss << "-";
  ss << dis2(gen);
  for (i = 0; i < 3; i++) {
    ss << dis(gen);
  }
  ss << "-";
  for (i = 0; i < 12; i++) {
    ss << dis(gen);
  };
  return ss.str();
}
}

static std::shared_ptr<std::map<std::string, simdjson::dom::element>> parsed_json;

extern "C" {
typedef struct parse_result {
  const char *message;
  const char *status;
} parse_result;

void delete_parsed_json(const char *uuid) {
  parsed_json.get()->erase(uuid);
  parsed_json.reset();
}

const parse_result parse_json(const char *json) {
  const std::string str(json);
  simdjson::dom::element doc;
  simdjson::dom::parser parser;
  auto error = parser.parse(str).get(doc);
  parse_result result;
  if (error == simdjson::SUCCESS) {
    std::string uuid = uuid::generate_uuid_v4();
    (*parsed_json.get())[uuid] = doc;
    parsed_json.reset();
    result.message = uuid.c_str();
    result.status  = "OK\0";
  } else {
    result.message = "FAILED TO PARSE JSON\0";
    result.status  = "ERROR\0";
  }
  return result;
}
}

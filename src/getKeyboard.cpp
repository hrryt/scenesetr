#include "Rcpp.h"
#include "Windows.h"
#include "vector"
// #include "string"
// 
// // [[Rcpp::export]]
// std::vector<char> GetKeys(int time_limit, std::vector<std::string> values) {
//   std::vector<char> output;
//   int time = 0;
//   while (time < time_limit) {
//     for (std::string val : values) {
//       char i = val.c_str()[0];
//       if (GetKeyState(i) & 0x8000) {
//         bool contains = false;
//         for (char j : output) {
//           if (j == i) contains = true;
//         }
//         if (!contains) output.push_back(i);
//       }
//     }
//     time++;
//   }
//   return output;
// }

// [[Rcpp::export]]
std::vector<char> GetKeyboard() {
  std::vector<char> output;
  for (int i = 0; i < 256; i++) {
    if (GetAsyncKeyState(i)) {
      bool contains = false;
      for (char j : output) {
        if (j == (char)i) contains = true;
      }
      if (!contains) output.push_back((char)i);
    }
  }
  return output;
}
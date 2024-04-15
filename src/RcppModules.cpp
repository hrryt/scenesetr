#include "GLRenderer.h"

using namespace Rcpp;

RCPP_MODULE(GLRenderer) {
  class_<GLRenderer>("GLRenderer")
  .constructor<const char*, int, int>()
  .method("InitShaderProgram", &GLRenderer::InitShaderProgram)
  .method("InitBuffers", &GLRenderer::InitBuffers)
  .method("Clear", &GLRenderer::Clear)
  .method("Render", &GLRenderer::Render)
  .method("Update", &GLRenderer::Update)
  .method("FramerateLimit", &GLRenderer::FramerateLimit)
  .method("Delete", &GLRenderer::Delete)
  .method("GetInputs", &GLRenderer::GetInputs)
  .method("SetCameraPosition", &GLRenderer::SetCameraPosition)
  .method("SetCameraOrientation", &GLRenderer::SetCameraOrientation)
  .method("SetCameraUp", &GLRenderer::SetCameraUp)
  .method("SetCameraResolution", &GLRenderer::SetCameraResolution)
  .method("saveImage", &GLRenderer::saveImage)
  ;
}

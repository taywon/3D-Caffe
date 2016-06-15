#ifdef USE_CUDNN
#include <algorithm>
#include <vector>

#include "caffe/layer.hpp"
#include "caffe/vision_layers.hpp"

namespace caffe {

template <typename Dtype>
void CuDNNTanHLayer<Dtype>::Forward_gpu(const vector<Blob<Dtype>*>& bottom,
    const vector<Blob<Dtype>*>& top) {
  const Dtype* bottom_data = bottom[0]->gpu_data();
  Dtype* top_data = top[0]->mutable_gpu_data();
  cudnnActivationDescriptor_t *activationDesc;
  CUDNN_CHECK(cudnnCreateActivationDescriptor(activationDesc ));
  CUDNN_CHECK(cudnnSetActivationDescriptor(*activationDesc,CUDNN_ACTIVATION_TANH,CUDNN_NOT_PROPAGATE_NAN,0));
  CUDNN_CHECK(cudnnActivationForward(this->handle_,
        *activationDesc,
        cudnn::dataType<Dtype>::one,
        this->bottom_desc_, bottom_data,
        cudnn::dataType<Dtype>::zero,
        this->top_desc_, top_data));
}

template <typename Dtype>
void CuDNNTanHLayer<Dtype>::Backward_gpu(const vector<Blob<Dtype>*>& top,
    const vector<bool>& propagate_down,
    const vector<Blob<Dtype>*>& bottom) {
  if (!propagate_down[0]) {
    return;
  }

  const Dtype* top_data = top[0]->gpu_data();
  const Dtype* top_diff = top[0]->gpu_diff();
  const Dtype* bottom_data = bottom[0]->gpu_data();
  Dtype* bottom_diff = bottom[0]->mutable_gpu_diff();
    cudnnActivationDescriptor_t *activationDesc;
  CUDNN_CHECK(cudnnCreateActivationDescriptor(activationDesc ));
  CUDNN_CHECK(cudnnSetActivationDescriptor(*activationDesc,CUDNN_ACTIVATION_TANH,CUDNN_NOT_PROPAGATE_NAN,0));

  CUDNN_CHECK(cudnnActivationBackward(this->handle_,
        *activationDesc,
        cudnn::dataType<Dtype>::one,
        this->top_desc_, top_data, this->top_desc_, top_diff,
        this->bottom_desc_, bottom_data,
        cudnn::dataType<Dtype>::zero,
        this->bottom_desc_, bottom_diff));
}

INSTANTIATE_LAYER_GPU_FUNCS(CuDNNTanHLayer);

}  // namespace caffe
#endif

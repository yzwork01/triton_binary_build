import triton_python_backend_utils as pb_utils
import numpy as np

class TritonPythonModel:
    def initialize(self, args):
        """Initialize the model (called once when the model is loaded)."""
        self.add_constant = 10  # Example constant to add to inputs

    def execute(self, requests):
        """Process requests and return responses."""
        responses = []
        
        for request in requests:
            # Get input tensor
            input_tensor = pb_utils.get_input_tensor_by_name(request, "INPUT")
            input_data = input_tensor.as_numpy()
            
            # Perform computation
            print("Input data shape:", input_data.shape)
            first_part = input_data[:, :10]  # First 10 columns
            second_part = input_data[:, 10:]  # Last 10 columns
            output_data = first_part + second_part 
            # output_data = output_data.astype(np.float32).reshape([10])
            print("Output data shape:", output_data.shape)

            # Create output tensor
            output_tensor = pb_utils.Tensor("OUTPUT", output_data.astype(np.float32))
            
            responses.append(pb_utils.InferenceResponse(output_tensors=[output_tensor]))
        
        return responses

    def finalize(self):
        """Clean up resources when the model is unloaded."""
        pass